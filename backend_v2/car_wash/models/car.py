from django.utils.translation import gettext_lazy as _
from django.db import models

from car_wash.utils.constants import MAX_CAR_NUMBER_LENGTH
from iLine.settings import AUTH_USER_MODEL


class Car(models.Model):
    number = models.CharField(_('Registration plate'), max_length=MAX_CAR_NUMBER_LENGTH)
    owner = models.ForeignKey(AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='cars')

    class Meta:
        unique_together = ('owner', 'number')
        indexes = [
            models.Index(fields=['owner', 'number']),
        ]

    def __str__(self):
        return f'<Car ({self.number}, {self.owner})>'
