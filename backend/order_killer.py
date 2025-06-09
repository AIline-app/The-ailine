import os
import django
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'AstSmartTime.settings')
django.setup()

from datetime import timedelta

from app_orders.models import Order

for order in Order.objects.all():
    current_stamp = timezone.now()
    if current_stamp > order.date_create + timedelta(minutes=15) and order.payment_status == 'Pending' or order.payment_status == 'Sent':

        order.status = 'Canceled'
        order.payment_status = 'Canceled'
        order.save()
