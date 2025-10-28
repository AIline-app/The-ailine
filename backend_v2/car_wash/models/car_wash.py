import uuid

from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.utils.translation import gettext_lazy as _

from accounts.models.user import User
from car_wash.models.box import Box


class CarWash(models.Model):
    """Модель автомойки.

    Attributes
        owner: Owner of the car wash
        name: Название
        iin: ТОО/ИИН
        address: адрес
        is_active: Активность мойки
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(
        User,
        verbose_name=_('Owner'),
        on_delete=models.CASCADE,
        related_name='car_wash',
    )
    name = models.CharField(verbose_name=_('Name'), max_length=40, blank=False)
    address = models.CharField(verbose_name=_('Address'), max_length=300)
    created_at = models.DateTimeField(verbose_name=_('Creation Data'), auto_now_add=True)
    is_active = models.BooleanField(verbose_name=_('Is active'), default=False)

    class Meta:
        verbose_name = _('Car Wash')
        verbose_name_plural = _('Car Washes')

        indexes = [
            models.Index(fields=['owner']),
        ]

    def __str__(self):
        return f'<CarWash ({self.name}, {self.id})>'

    def create_settings(self, settings_data):
        car_types = settings_data.pop('car_types')
        settings = CarWashSettings.objects.create(car_wash=self, **settings_data)
        settings.set_car_types(car_types)
        return settings

    def create_documents(self, documents_data):
        return CarWashDocuments.objects.create(car_wash=self, **documents_data)

    def create_boxes(self, amount: int):
        boxes = [
            Box(car_wash=self, name=f'Box #{box_num+1}')
            for box_num in range(amount)
        ]
        Box.objects.bulk_create(boxes)

    def update_car_types(self, car_types):
        # TODO finish
        return


class CarWashSettings(models.Model):
    car_wash = models.OneToOneField(
        CarWash,
        verbose_name=_('CarWash'),
        related_name='settings',
        on_delete=models.CASCADE,
        primary_key=True,
    )
    opens_at = models.TimeField(verbose_name=_('Opens at'), null=False, blank=False, default='9:00')
    closes_at = models.TimeField(verbose_name=_('Closes at'), null=False, blank=False, default='21:00')
    percent_washers = models.IntegerField(
        verbose_name=_('Washer Percent'),
        null=False,
        blank=True,
        default=30,
    )

    class Meta:
        verbose_name = _('Car Wash Settings')

    def __str__(self):
        return f'<CarWashSettings ({self.car_wash})>'

    def set_car_types(self, car_types):
        objects = [CarTypes(settings=self, name=car_type['name']) for car_type in car_types]
        CarTypes.objects.bulk_create(objects)


class CarWashDocuments(models.Model):
    car_wash = models.OneToOneField(
        CarWash,
        verbose_name=_('CarWash'),
        related_name='documents',
        on_delete=models.CASCADE,
        primary_key=True,
    )
    iin = models.CharField(_('TOO/IIN'), max_length=12)
    # TODO add fields for relevant documents (e.g. paths at storage)

    class Meta:
        verbose_name = _('Car Wash Documents')

    def __str__(self):
        return f'<CarWashDocuments ({self.car_wash})>'


class CarTypes(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    settings = models.ForeignKey(CarWashSettings, on_delete=models.CASCADE, related_name='car_types')
    name = models.CharField(_('Car type'), )

    class Meta:
        unique_together = ('settings', 'name')
        indexes = [
            models.Index(fields=['settings']),
        ]
