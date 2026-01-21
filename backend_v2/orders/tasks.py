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

    Returns:
    - Number of orders updated
    """
    threshold = now() - timedelta(hours=12)

    with transaction.atomic():
        qs = Orders.objects.select_for_update(skip_locked=True).filter(
            status__in=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE),
            created_at__lte=threshold,
        )
        updated = qs.update(status=OrderStatus.CANCELED, finished_at=now())

    return updated
