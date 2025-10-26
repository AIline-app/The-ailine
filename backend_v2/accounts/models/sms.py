from django.db import models
from django.utils.translation import gettext_lazy as _

from accounts.models.user import User
from accounts.utils.enums import TypeSmsCode
from accounts.utils.utils import generate_sms_code, get_default_expires_at
from accounts.validators import validate_code


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
