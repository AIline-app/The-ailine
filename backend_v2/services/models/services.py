import uuid

from django.db import models
from django.utils.translation import gettext_lazy as _

from car_wash.models.car_wash import CarWash, CarType
from services.utils.constants import CHAR_MAX_LENGTH


class Services(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    car_wash = models.ForeignKey(CarWash, on_delete=models.CASCADE, null=False, blank=False, related_name='services')
    car_type = models.ForeignKey(CarType, on_delete=models.CASCADE, null=False, blank=False, related_name='services')
    name = models.CharField(blank=False, null=False, max_length=CHAR_MAX_LENGTH)
    description = models.CharField(max_length=CHAR_MAX_LENGTH)
    price = models.PositiveIntegerField(blank=False, null=False)
    duration = models.DurationField(blank=False, null=False)
    is_extra = models.BooleanField(default=False, blank=False, null=False)

    class Meta:
        verbose_name = _('Service')

        indexes = [
            models.Index(fields=['car_wash']),
        ]

    def __str__(self):
        return f'<Service ({self.name}, {self.id})>'
