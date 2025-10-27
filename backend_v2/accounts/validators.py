from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

from accounts.utils.constants import MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE


def validate_code(value):
    if not MIN_SMS_CODE_VALUE <= value <= MAX_SMS_CODE_VALUE:
        raise ValidationError(
            _('%(value)s is not %(SMS_CODE_LENGTH)s digits')
        )
