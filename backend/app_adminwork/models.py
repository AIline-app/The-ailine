from django.db import models

from AstSmartTime import choices_lists
from app_orders.models import Order
from app_washes.models import CarWash


class SlotsInWash(models.Model):
    """Модель слота.

    Attributes
        wash - мойка
        order - заказ
        status - статус слота
    """
    wash = models.ForeignKey(
        CarWash,
        null=False,
        on_delete=models.CASCADE,
        related_name='slot'
    )
    order = models.ForeignKey(
        Order,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='order',
    )
    status = models.CharField(
        max_length=20,
        choices=choices_lists.STATUS_ORDER,
        default='Free',
        null=True,
        blank=True,
    )

    def __str__(self):
        return f'Слот №{self.pk} для автомойки {self.wash}. Статус: {self.status}'
