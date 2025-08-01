from decimal import Decimal
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Order, WasherEarning


@receiver(post_save, sender=Order)
def create_washer_earning(sender, instance: Order, created, **kwargs):
    """Триггер при выполнении заказа"""
    # Только при обновлении (не при создании) и при переходе в статус 'Done'
    if not created and instance.status == 'Done':
        # Проверим, чтобы мы не создали дубликат
        if hasattr(instance, 'earning'):
            return

        pct = instance.car_wash.percent_washers
        earnings = (
            instance.price * Decimal(pct) / Decimal('100')
        ).quantize(Decimal('.01'))

        WasherEarning.objects.create(
            order=instance,
            washer=instance.washer,
            earnings=earnings,
            date=instance.time_end.date()
        )
