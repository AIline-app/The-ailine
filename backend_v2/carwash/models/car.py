from django.db import models

from accounts.models.user import User


class Car(models.Model):
    number = models.CharField(max_length=15)
    # type = models.CharField(verbose_name=_('Car Type'), max_length=15, choices=TypeAuto.choices)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cars')

    class Meta:
        unique_together = ('owner', 'number')
        indexes = [
            models.Index(fields=['owner', 'number']),
        ]
