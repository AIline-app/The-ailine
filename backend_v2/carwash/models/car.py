from django.db import models

from accounts.models.user import User
from carwash.utils.constants import MAX_CAR_NUMBER_LENGTH


class Car(models.Model):
    number = models.CharField(max_length=MAX_CAR_NUMBER_LENGTH)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cars')

    class Meta:
        unique_together = ('owner', 'number')
        indexes = [
            models.Index(fields=['owner', 'number']),
        ]
