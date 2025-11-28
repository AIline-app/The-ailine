import uuid

from django.db import models
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _

from car_wash.models import Car, Box
from car_wash.models.car_wash import CarWash
from iLine.settings import AUTH_USER_MODEL
from orders.utils.enums import OrderStatus
from services.models import Services


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
    status = models.CharField(verbose_name=_('Status'), choices=OrderStatus.choices, default=OrderStatus.EN_ROUTE)

    class Meta:
        verbose_name = _('Order')
        verbose_name_plural = _('Orders')

        # TODO check which indexes needed
        # indexes = [
            # models.Index(fields=['car']),
            # models.Index(fields=['box']),
            # models.Index(fields=['car_wash']),
            # models.Index(fields=['user']),
        # ]
