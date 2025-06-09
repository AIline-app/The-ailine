import requests
import os
import django
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'AstSmartTime.settings')
django.setup()

from datetime import timedelta

from django.conf import settings
from app_orders.models import Order, NotificationData
from app_users.models import User

for order in Order.objects.all():
    current_stamp = timezone.now()
    user = User.objects.get(id=order.customer.pk)
    if current_stamp >= order.time_start - timedelta(minutes=user.notification) and order.status == 'Reserve' and order.notified == 0 and order.payment_status == 'Created':
        phone = order.customer.phone.split('+')[1]
        message = 'Напоминаем о себе. Пора на мойку! :).'
        requests.get(
            f'http://kazinfoteh.org:9507/api?action=sendmessage&username={settings.SMS_LOGIN}&password={settings.SMS_PASSWORD}'
            f'&recipient={phone}&messagetype=SMS:TEXT&originator=INFO_KAZ&messagedata={message}'
        )
        NotificationData.objects.create(order=order.id, message=message)
        order.notified = 1
        print(f"Заказ №{order.id} оповещён")
        order.save()
