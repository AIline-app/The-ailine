from django.db import models
from django.utils.translation import gettext_lazy as _

from user_auth.models.user import User
from user_auth.utils.choices import TypeAuto


class Car(models.Model):
    number = models.CharField(max_length=15)
    type = models.CharField(verbose_name=_('Car Type'), max_length=15, choices=TypeAuto.choices)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cars')

    class Meta:
        unique_together = ('owner', 'number')
        indexes = [
            models.Index(fields=['owner', 'number']),
        ]
