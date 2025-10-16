import random
from datetime import datetime, timedelta

from django.core.exceptions import ValidationError
from django.db import models
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _

from user_auth.utils.constants import MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE
from user_auth.models.user import User
from user_auth.utils.choices import TypeSmsCode


def get_default_expires_at() -> datetime:
    return now() + timedelta(minutes=5)

def generate_sms_code() -> int:
    return random.randint(MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE)

def validate_code(value):
    if not MIN_SMS_CODE_VALUE <= value <= MAX_SMS_CODE_VALUE:
        raise ValidationError(
            _('%(value)s is not %(SMS_CODE_LENGTH)s digits')
        )

class SMSCode(models.Model):
    """Модель смс-кода для регистрации."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sms_codes')
    code = models.IntegerField(
        _('Code'),
        default=generate_sms_code,
        blank=False,
        null=False,
        validators=[validate_code])
    type = models.CharField(_('SMS Type'), choices=TypeSmsCode.choices)
    created_at = models.DateTimeField(_('Date created'), auto_now_add=True)
    expires_at = models.DateTimeField(_('Expiration date'), default=get_default_expires_at, null=False, blank=False)
    # TODO add attempt_amount = 3 ?

    class Meta:
        verbose_name = _('SMS Code')
        verbose_name_plural = _('SMS Codes')
