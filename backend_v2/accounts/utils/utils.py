import random
from datetime import datetime, timedelta

from django.utils.timezone import now

from accounts.utils.constants import MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE, SMS_EXPIRES_IN_MINS


def get_default_expires_at() -> datetime:
    return now() + timedelta(minutes=SMS_EXPIRES_IN_MINS)

def generate_sms_code() -> int:
    return random.randint(MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE)