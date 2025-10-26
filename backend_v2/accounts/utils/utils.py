import random
from datetime import datetime, timedelta

from django.utils.timezone import now

from accounts.utils.constants import MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE


def get_default_expires_at() -> datetime:
    return now() + timedelta(minutes=5)

def generate_sms_code() -> int:
    return random.randint(MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE)