import uuid

from django.utils.translation import gettext_lazy as _
from django.db import models

from accounts.models import User
from car_wash.models import CarWash
from orders.models import Orders


class Rating(models.Model):
    car_wash = models.OneToOneField(
        CarWash,
        verbose_name=_('CarWash'),
        related_name='rating',
        on_delete=models.CASCADE,
        primary_key=True,
    )
    count = models.PositiveIntegerField(default=0)
    average = models.FloatField(default=0)

    def __str__(self):
        return f'<Rating ({self.car_wash.id} {self.count} {self.average})>'


class UserReview(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=False, related_name='reviews')
    order = models.OneToOneField(Orders, on_delete=models.CASCADE, null=False, related_name='review')
    rating = models.PositiveIntegerField(default=0)
    # review = models.TextField(max_length=500)

    def __str__(self):
        return f'<Rating ({self.order.id} {self.user.id} {self.rating})>'
