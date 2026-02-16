import uuid
from datetime import timedelta

from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.db.models import Sum
from django.utils.translation import gettext_lazy as _
from django.utils.timezone import now

from car_wash.utils.constants import DEFAULT_WASHER_PERCENT, MIN_WASHER_PERCENT, MAX_WASHER_PERCENT
from iLine.settings import AUTH_USER_MODEL
from car_wash.models.box import Box
from orders.utils.enums import OrderStatus


class CarWash(models.Model):
    """Модель автомойки.

    Attributes
        owner: Owner of the car wash
        name: Название
        iin: ТОО/ИИН
        address: адрес
        is_active: Активность мойки
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(
        AUTH_USER_MODEL,
        verbose_name=_('Owner'),
        on_delete=models.CASCADE,
        related_name='owner_car_washes',
    )
    managers = models.ManyToManyField(
        AUTH_USER_MODEL,
        verbose_name=_('Managers'),
        related_name='manager_car_washes',
        related_query_name='managers',
    )
    washers = models.ManyToManyField(
        AUTH_USER_MODEL,
        verbose_name=_('Washers'),
        related_name='washer_car_washes',
        related_query_name='washers',
    )
    name = models.CharField(verbose_name=_('Name'), max_length=40, blank=False)
    address = models.CharField(verbose_name=_('Address'), max_length=300)
    location = models.CharField(verbose_name=_('Location'), null=True, default=None, max_length=300)
    created_at = models.DateTimeField(verbose_name=_('Creation Data'), auto_now_add=True)
    is_active = models.BooleanField(verbose_name=_('Is active'), default=False)
    # TODO once verified (is_active=True), add to dashboard_stats with id
    #  1,car_wash_earn,Car Wash Earn,orders,Orders,created_at,total_price,,true,2026-01-30 15:10:43.710906 +00:00,2026-01-30 15:24:30.141497 +00:00,,lineChart,31,days,,false,,false,"discreteBarChart,lineChart",days,"Count,Sum,Avg,Max,Min",false,"[{""filter"": {""status"": ""completed"", ""car_wash__id"": ""1f47925d-a297-4e3f-9c22-ecad44be0e05""}}]"

    class Meta:
        verbose_name = _('Car Wash')
        verbose_name_plural = _('Car Washes')

        indexes = [
            models.Index(fields=['owner']),
        ]

    def __str__(self):
        return f'<CarWash ({self.name}, {self.id})>'

    def create_settings(self, settings_data):
        car_types = settings_data.pop('car_types')
        settings = CarWashSettings.objects.create(car_wash=self, **settings_data)
        settings.set_car_types(car_types)
        return settings

    def create_documents(self, documents_data):
        return CarWashDocuments.objects.create(car_wash=self, **documents_data)

    def update_documents(self, documents_data):
        pass

    def create_boxes(self, amount: int):

        Box.objects.bulk_create(Box(car_wash=self, name=f'Box #{box_num + 1}') for box_num in range(amount))

    def __get_boxes_amount(self):

        return self.boxes.count()

    def __get_orders(self, current_order=None):

        return self.orders.get_waiting(current_order)

    def get_queue_data(self):

        # Get approximate wait time
        last_in_queue = self.queue_entries.order_by('-expected_start_time').first()
        wait_time = last_in_queue.expected_start_time + last_in_queue.expected_duration - now()
        wait_time_str = str(wait_time) if wait_time else '0:00:00'

        # Count cars ahead in queue
        cars_ahead = self.queue_entries.count()

        return {
            'wait_time': wait_time_str,
            'car_amount': cars_ahead,
        }
        
        # Legacy calculation (backward compatibility)
        # boxes_amount = self.__get_boxes_amount()
        # orders = self.__get_orders(current_order)
        # queue_duration = orders.aggregate(
        #     sum_duration=ExpressionWrapper(
        #         Sum("services__duration", default=timedelta(0)) / Value(boxes_amount),
        #         output_field=DurationField(),
        #     ),
        # )["sum_duration"]
        #
        # # Calculate how long the current order is late for (if applicable)
        # late_for = None
        # if current_order is not None and len(orders) == 0:
        #     # You are late if there is no one in front of you (no EN_ROUTE or ON_SITE orders ahead)
        #     if self.orders.get_active(current_order).count() < boxes_amount:
        #         last_completed_before = (
        #             self.orders.get_completed()
        #             .filter(created_at__lt=current_order.created_at)
        #             .order_by('-finished_at')
        #             .first()
        #         )
        #         if last_completed_before and last_completed_before.finished_at:
        #             late_for = now() - last_completed_before.finished_at
        #
        # return {
        #     'wait_time': str(queue_duration),
        #     'car_amount': len(orders),
        #     'late_for': late_for if late_for is None else str(late_for),
        # }

    def add_to_queue(self, order):
        """Add an order to the queue and calculate its expected start time.
        
        Args:
            order: The order to add to the queue
            
        Returns:
            QueueEntry: The created queue entry
        """
        
        # Get the next position (max position + 1)
        last_entry = self.queue_entries.order_by('-position').first()
        next_position = (last_entry.position + 1) if last_entry else 0
        
        # Calculate expected duration for this order
        services_duration = order.services.aggregate(
            total=Sum('duration', default=timedelta(0))
        )['total'] or timedelta(0)
        
        # Calculate expected start time
        expected_start = self._calculate_expected_start_time(next_position)
        
        # Create queue entry
        queue_entry = self.queue_entries.create(
            order=order,
            position=next_position,
            expected_start_time=expected_start,
            expected_duration=services_duration,
        )
        # queue_entry = QueueEntry.objects.create(
        #     car_wash=self,
        #     order=order,
        #     position=next_position,
        #     expected_start_time=expected_start,
        #     expected_duration=services_duration,
        # )
        
        return queue_entry
    
    def remove_from_queue(self, order):
        """Remove an order from the queue and reposition remaining entries.
        
        Args:
            order: The order to remove from the queue
        """
        
        # try:
        removed_position = order.queue_entry.position
        order.queue_entry.delete()

        # Shift down all entries after the removed one
        entries_to_update = self.queue_entries.filter(position__gt=removed_position)
        for entry in entries_to_update:
            entry.position -= 1
            entry.save()  # TODO bulk update?

        # Recalculate expected times for all remaining entries
        self.recalculate_queue()
        # except QueueEntry.DoesNotExist:
        #     pass
    
    def recalculate_queue(self):
        """Recalculate expected start times for all entries in the queue."""
        entries = self.queue_entries.select_related('order').prefetch_related('order__services').order_by('position')
        
        for index, entry in enumerate(entries):
            # Update position to be consecutive (0, 1, 2, ...)
            entry.position = index
            entry.expected_start_time = self._calculate_expected_start_time(entry.position)
            
            # Recalculate expected duration in case services changed
            services_duration = entry.order.services.aggregate(
                total=Sum('duration', default=timedelta(0))
            )['total'] or timedelta(0)
            entry.expected_duration = services_duration
            
            entry.save()  # TODO bulk update?
    
    def _calculate_expected_start_time(self, position):
        """Calculate expected start time for a given queue position.
        
        Args:
            position: The position in queue (0-indexed)
            
        Returns:
            datetime: The expected start time
        """
        boxes_count = self.boxes.count()
        
        # Get all entries before this position
        previous_entries = self.queue_entries.filter(position__lt=position).select_related('order').prefetch_related('order__services')
        
        # Calculate total duration of all previous orders divided by number of boxes
        total_previous_duration = timedelta(0)
        for entry in previous_entries:
            total_previous_duration += entry.expected_duration
        
        # Average wait time considering parallel processing in multiple boxes
        avg_wait_time = total_previous_duration / boxes_count
        
        # Also consider currently IN_PROGRESS orders
        in_progress_orders = self.orders.filter(status=OrderStatus.IN_PROGRESS)
        max_remaining_time = timedelta(0)
        
        for order in in_progress_orders:
            if order.started_at:
                elapsed = now() - order.started_at
                total_duration = order.services.aggregate(  # TODO move to order.duration
                    total=Sum('duration', default=timedelta(0))
                )['total'] or timedelta(0)
                remaining = total_duration - elapsed
                if remaining > max_remaining_time:
                    max_remaining_time = remaining

        return now() + max_remaining_time + avg_wait_time

    def update_car_types(self, car_types):
        # TODO finish
        return


class CarWashSettings(models.Model):
    car_wash = models.OneToOneField(
        CarWash,
        verbose_name=_('CarWash'),
        related_name='settings',
        on_delete=models.CASCADE,
        primary_key=True,
    )
    opens_at = models.TimeField(verbose_name=_('Opens at'), null=False, blank=False, default='9:00')
    closes_at = models.TimeField(verbose_name=_('Closes at'), null=False, blank=False, default='21:00')
    percent_washers = models.IntegerField(
        verbose_name=_('Washer Percent'),
        null=False,
        blank=True,
        default=DEFAULT_WASHER_PERCENT,
        validators = [MinValueValidator(MIN_WASHER_PERCENT), MaxValueValidator(MAX_WASHER_PERCENT)],
    )

    class Meta:
        verbose_name = _('Car Wash Settings')

    def __str__(self):
        return f'<CarWashSettings ({self.car_wash})>'

    def set_car_types(self, car_types):
        CarType.objects.bulk_create(CarType(settings=self, name=car_type['name']) for car_type in car_types)


class CarWashDocuments(models.Model):
    car_wash = models.OneToOneField(
        CarWash,
        verbose_name=_('CarWash'),
        related_name='documents',
        on_delete=models.CASCADE,
        primary_key=True,
    )
    iin = models.CharField(_('TOO/IIN'), max_length=12)
    # TODO add fields for relevant documents (e.g. paths at storage)

    class Meta:
        verbose_name = _('Car Wash Documents')

    def __str__(self):
        return f'<CarWashDocuments ({self.car_wash})>'


class CarType(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    settings = models.ForeignKey(CarWashSettings, on_delete=models.CASCADE, related_name='car_types')
    name = models.CharField(_('Car type'), max_length=255)
    description = models.CharField(_('Description'), max_length=255)

    class Meta:
        unique_together = ('settings', 'name')
        indexes = [
            models.Index(fields=['settings']),
        ]
