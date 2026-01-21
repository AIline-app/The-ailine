import uuid
from datetime import timedelta

from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.db.models import Sum, DurationField, Value, ExpressionWrapper
from django.utils.translation import gettext_lazy as _
from django.utils.timezone import now

from car_wash.utils.constants import DEFAULT_WASHER_PERCENT, MIN_WASHER_PERCENT, MAX_WASHER_PERCENT
from iLine.settings import AUTH_USER_MODEL
from car_wash.models.box import Box


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

    def create_boxes(self, amount: int):

        Box.objects.bulk_create(Box(car_wash=self, name=f'Box #{box_num + 1}') for box_num in range(amount))

    def __get_boxes_amount(self):

        return self.boxes.count()

    def __get_orders(self, current_order=None):

        return self.orders.get_waiting(current_order)

    def get_queue_data(self, current_order=None):

        boxes_amount = self.__get_boxes_amount()
        orders = self.__get_orders(current_order)
        queue_duration = orders.aggregate(
            sum_duration=ExpressionWrapper(
                Sum("services__duration", default=timedelta(0)) / Value(boxes_amount),
                output_field=DurationField(),
            ),
        )["sum_duration"]

        # Calculate how long the current order is late for (if applicable)
        late_for = None
        if current_order is not None and len(orders) == 0:
            # You are late if there is no one in front of you (no EN_ROUTE or ON_SITE orders ahead)
            if self.orders.get_active(current_order).count() < boxes_amount:
                last_completed_before = (
                    self.orders.get_completed()
                    .filter(created_at__lt=current_order.created_at)
                    .order_by('-finished_at')
                    .first()
                )
                if last_completed_before and last_completed_before.finished_at:
                    late_for = now() - last_completed_before.finished_at

        return {
            'wait_time': str(queue_duration),
            'car_amount': len(orders),
            'late_for': late_for or str(late_for),
        }

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
    name = models.CharField(_('Car type'), )

    class Meta:
        unique_together = ('settings', 'name')
        indexes = [
            models.Index(fields=['settings']),
        ]
