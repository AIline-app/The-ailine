import os
import django
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'AstSmartTime.settings')
django.setup()

from app_orders.models import Order
from app_users.models import User
from app_orders.serializers import notify_for_admin

for order in Order.objects.all():
    current_stamp = timezone.now()
    user = User.objects.get(id=order.customer.pk)
    if current_stamp >= order.time_start and order.status == 'Reserve' and order.payment_status == 'Created' and order.notified_by_admin == 0:
        message = f'Клиент с номером {order.customer.number_auto} опаздывает.'
        notify_for_admin(order.car_wash, message)
        order.notified_by_admin = 1
        order.save()
