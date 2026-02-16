from datetime import timedelta

from django.utils.timezone import now
from django.db import transaction

try:
    from celery import shared_task
except Exception:  # pragma: no cover - allows Django to run even if Celery not installed in some envs
    def shared_task(*dargs, **dkwargs):  # type: ignore
        def _decorator(func):
            return func
        return _decorator

from django.conf import settings
from django.db.models import Prefetch
from accounts.utils.kafka import Kafka
from services.models import Services
from orders.models import Orders
from orders.utils.enums import OrderStatus


@shared_task(name='orders.tasks.cancel_delayed_orders')
def cancel_delayed_orders():
    """
    Cancels all orders that are in EN_ROUTE or ON_SITE status for more than 12 hours.

    Criteria:
    - status in {EN_ROUTE, ON_SITE}
    - created_at <= now - 12 hours

    Side effects:
    - Sets status to CANCELED
    - Sets finished_at to current time for bookkeeping
    - Removes orders from queue

    Returns:
    - Number of orders updated
    """
    threshold = now() - timedelta(hours=12)

    with transaction.atomic():
        # Get orders before updating to track which car washes need queue cleanup
        orders_to_cancel = list(
            Orders.objects.select_related('car_wash').filter(
                status__in=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE),
                created_at__lte=threshold,
            )
        )
        
        # Update status
        qs = Orders.objects.select_for_update(skip_locked=True).filter(
            status__in=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE),
            created_at__lte=threshold,
        )
        updated = qs.update(status=OrderStatus.CANCELED, finished_at=now())
        
        # Remove from queue
        for order in orders_to_cancel:
            if order.car_wash:
                try:
                    order.car_wash.remove_from_queue(order)
                except Exception:
                    # Don't fail the task if queue cleanup has issues
                    pass

    return updated


def _send_notification(order):
    user = order.user
    if not user:
        return False
    # Build message
    text = f"Your car wash will be finished soon at {order.car_wash.name if order.car_wash else ''}."
    kafka = Kafka()
    try:
        if getattr(user, 'notification_method', None) == getattr(user.NotificationMethod, 'WHATSAPP', 'whatsapp'):
            topic = getattr(settings, 'KAFKA_WHATSAPP_TOPIC', 'whatsapp')
            payload = {
                'phone': (user.phone_number or '').lstrip('+'),
                'message': text,
            }
        else:
            topic = getattr(settings, 'KAFKA_TELEGRAM_TOPIC', 'telegram')
            payload = {
                'chat_id': getattr(user, 'chat_id_telegram', None),
                'message': text,
            }
        kafka.send(topic=topic, payload=payload)
        return True
    except Exception:
        return False


@shared_task(name='orders.tasks.send_order_notifications')
def send_order_notifications():
    """Send notifications to users N minutes before the expected finish.

    Expected finish = started_at + sum(services.duration)
    Send when now >= expected_finish - user.notification_minutes and notification not yet sent.
    """
    now_ts = now()
    # Select in-progress orders with started_at, not finished, and no notification sent yet
    orders_qs = (
        Orders.objects.select_related('user', 'car_wash')
        .prefetch_related('services')
        .filter(
            status=OrderStatus.EN_ROUTE,
            started_at__isnull=False,
            finished_at__isnull=True,
            notification_sent_at__isnull=True,
        )
    )

    updated_count = 0
    for order in orders_qs:  # type: Orders
        queue = order.car_wash.get_queue_data(order)
        minutes = getattr(order.user, 'notification_minutes', 30) or 30
        # notify_time = expected_finish - timedelta(minutes=minutes)
        # Only send if in the window (before finish) and notify_time passed
        # if now_ts >= notify_time and now_ts < expected_finish:
        #     sent = _send_notification(order)
        #     if sent:
        #         Orders.objects.filter(pk=order.pk, notification_sent_at__isnull=True).update(notification_sent_at=now())
        #         updated_count += 1
    return updated_count
