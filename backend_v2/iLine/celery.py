import os
from celery import Celery
from celery.schedules import crontab

# Set default Django settings module for 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'iLine.settings')

app = Celery('iLine')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related config keys
#   should have a `CELERY_` prefix in Django settings.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django app configs.
app.autodiscover_tasks()

# Periodic tasks (Celery Beat)
# Runs every 15 minutes to cancel delayed orders (> 12 hours)
app.conf.beat_schedule = {
    'cancel-delayed-orders-every-15-min': {
        'task': 'orders.tasks.cancel_delayed_orders',
        'schedule': crontab(minute='*/15'),
        'options': {
            'expires': 60 * 60,  # Do not run if task is older than 1 hour
        },
    },
    'send-order-notifications-every-5-min': {
        'task': 'orders.tasks.send_order_notifications',
        'schedule': crontab(minute='*/5'),
        'options': {
            'expires': 10 * 60,  # Expire after 10 minutes
        },
    },
}


@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
