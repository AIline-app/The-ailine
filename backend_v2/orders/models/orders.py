import uuid

from django.db import models
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _

from car_wash.models import Car, Box
from car_wash.models.car_wash import CarWash
from iLine.settings import AUTH_USER_MODEL
from orders.utils.enums import OrderStatus
from services.models import Services


class OrdersQuerySet(models.QuerySet):

    def get_waiting(self, current_order=None):

        active_orders = self.filter(status__in=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE))

        if current_order:
            active_orders = active_orders.filter(created_at__lt=current_order.created_at)

        return active_orders

    def get_active(self, current_order=None):

        active_orders = self.filter(status=OrderStatus.IN_PROGRESS)

        if current_order:
            active_orders = active_orders.filter(created_at__lt=current_order.created_at)

        return active_orders

    def get_completed(self):

        return self.filter(status=OrderStatus.COMPLETED)


class Orders(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        AUTH_USER_MODEL,
        verbose_name=_('Client'),
        null=True,
        blank=False,
        on_delete=models.SET_NULL,
        related_name='orders',
    )
    car_wash = models.ForeignKey(
        CarWash,
        verbose_name=_('Car wash'),
        null=True,
        blank=False,
        on_delete=models.SET_NULL,
        related_name='orders',
    )
    car = models.ForeignKey(
        Car,
        verbose_name=_('Car'),
        null=True,
        blank=False,
        on_delete=models.SET_NULL,
        related_name='orders',
    )
    box = models.ForeignKey(
        Box,
        verbose_name=_('Box'),
        null=True,
        blank=False,
        on_delete=models.SET_NULL,
        related_name='orders',
    )
    services = models.ManyToManyField(
        Services,
        verbose_name=_('Services'),
        blank=False,
        related_name='orders',
    )
    washer = models.ForeignKey(
        AUTH_USER_MODEL,
        verbose_name=_('Washer'),
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='executed_orders',
    )
    created_at = models.DateTimeField(verbose_name=_('Created at'), blank=False, null=False, default=now)
    started_at = models.DateTimeField(verbose_name=_('Started at'), blank=True, null=True)
    finished_at = models.DateTimeField(verbose_name=_('Finished at'), blank=True, null=True)
    total_price = models.PositiveIntegerField(verbose_name=_('Final total price'), blank=True, null=True, default=None)
    duration = models.DurationField(verbose_name=_('Total duration'), blank=False, null=False)
    status = models.CharField(verbose_name=_('Status'), choices=OrderStatus.choices, default=OrderStatus.EN_ROUTE)

    objects: OrdersQuerySet = OrdersQuerySet.as_manager()

    class Meta:
        verbose_name = _('Order')
        verbose_name_plural = _('Orders')

        indexes = [
            models.Index(fields=['car_wash', '-created_at'], name='ord_cw_created_desc_idx'),
            models.Index(fields=['car_wash', 'status', '-created_at'], name='ord_cw_status_created_desc_idx'),
            models.Index(fields=['car', '-created_at'], name='ord_car_created_id_desc_idx'),
            models.Index(fields=['car_wash', 'user', '-created_at'], name='ord_cw_user_created_desc_idx'),
        ]

    def get_queue_data(self):

        # Get approximate wait time
        # wait_time = self.queue_entry.get_approximate_wait_time()
        # wait_time_str = str(wait_time) if wait_time else '0:00:00'

        # Count cars ahead in queue
        # cars_ahead = QueueEntry.objects.filter(position__lt=self.queue_entry.position, car_wash=self.car_wash).count()

        # Check if delayed
        # delay_duration = self.queue_entry.get_delay_duration()
        # late_for_str = str(delay_duration) if delay_duration else None

        return {
            'wait_time': self.queue_entry.get_approximate_wait_time(),
            'car_amount': self.queue_entry.position,
            'late_for': self.queue_entry.get_delay_duration(),
        }
