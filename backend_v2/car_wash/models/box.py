import uuid

from django.db import models
from django.utils.translation import gettext_lazy as _

from car_wash.utils.constants import BOX_NAME_MAX_LENGTH


class Box(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    car_wash = models.ForeignKey(
        'car_wash.CarWash',
        on_delete=models.CASCADE,
        null=False,
        blank=False,
        related_name='boxes',
    )
    name = models.CharField(max_length=BOX_NAME_MAX_LENGTH, default=_('Box'))

    class Meta:
        verbose_name = _('Box')
        verbose_name_plural = _('Boxes')

        indexes = [
            models.Index(fields=['car_wash']),
        ]

    def __str__(self):
        return f'<Box ({self.name}, {self.id}, {self.car_wash})>'
