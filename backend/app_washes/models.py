import re

from django.db import models
from django.utils.translation import gettext_lazy as _
from rest_framework.exceptions import ValidationError

from AstSmartTime import choices_lists
from app_users.models import User, MinValueValidator, MaxValueValidator


def user_directory_path(instance, filename):
    return 'user_{0}/{1}'.format(instance.user.id, filename)


def validate_url(value):
    pattern = r'^https\:\/\/(go\.)?2gis\.(com|kz)\/'
    if not re.match(pattern, value):
        raise ValidationError('Добавьте корректную ссылку на 2GIS')


class CarWash(models.Model):
    """Модель автомойки.

    Attributes
        title: Название
        inn: ТОО/ИНН
        address: адрес
        start_time: Время начала работы
        end_time: Время окончания работы
        slots: Количество слотов
        image: Картинка
        slots: Количество слотов в автомойке
        rating: Рейтинг автомойки
        last_time: Время последней записи на текущий момент
        is_validate: 1 - отображение мойки на карте, 0 - автомойка скрыта и не показана на карте
        is_active: Активность мойки
        link_2_gis: ссылка на 2GIS
    """

    user = models.ForeignKey(User, verbose_name=_('User'),
                             on_delete=models.CASCADE, blank=True, null=True, related_name='car_wash')
    title = models.CharField(verbose_name=_('Title'), max_length=40, blank=False)
    inn = models.CharField(_('TOO/INN'), max_length=12)
    address = models.CharField(verbose_name=_('Address'), max_length=80)
    start_time = models.TimeField(verbose_name=_('Start Time'), max_length=15)
    end_time = models.TimeField(verbose_name=_('End time'), max_length=20)
    slots = models.PositiveIntegerField(verbose_name=_('Slots'), blank=False)
    img = models.FileField(verbose_name=_('Image'), blank=True, null=True)
    rating = models.IntegerField(verbose_name=_('Rating'), blank=True, null=True, default=0)
    last_time = models.DateTimeField(verbose_name=_('Time end last order'), null=True, blank=True)
    date_create = models.DateTimeField(verbose_name=_('Date create'), auto_now_add=True, db_index=True)
    soft_delete = models.BooleanField(verbose_name=_('Soft delete'), default=False)
    is_validate = models.BooleanField(verbose_name=_('Is validate'), default=False)
    is_active = models.BooleanField(verbose_name=_('Is active'), default=True)
    link_2_gis = models.CharField(max_length=256, null=True, blank=True, validators=[validate_url])

    class Meta:
        verbose_name = _('CarWash')
        verbose_name_plural = _('CarWashes')

    def __str__(self):
        return f'{self.title}'


class CarWashCoordinates(models.Model):
    """Модель координат автомойки."""
    wash = models.OneToOneField(CarWash, verbose_name=_('Car Wash'),
                                on_delete=models.CASCADE, blank=False, null=True, related_name='wash_coordinates')
    latitude = models.FloatField(verbose_name=_('Latitude'), max_length=255, blank=True)
    longitude = models.FloatField(verbose_name=_('Longitude'), max_length=255, blank=True)

    class Meta:
        verbose_name = _('Car Wash Coordinates')
        verbose_name_plural = _('Car Wash Coordinates')

    def __str__(self):
        return f'{self.latitude} {self.longitude}'


class Service(models.Model):
    """ Модель услуги автомойки

    Attributes
        title: Название
        description: Описание
        type_auto: Тип авто
        price: Цена за услугу
        time_work: Время работы
        extra: Доп.услуга
    """
    wash = models.ForeignKey(CarWash, verbose_name=_('Car Wash'),
                             on_delete=models.CASCADE, blank=True, null=True, related_name='service')
    title = models.CharField(verbose_name=_('Title'), max_length=20, blank=False)
    description = models.CharField(verbose_name=_('Description'), max_length=60, blank=True, null=True)
    type_auto = models.CharField(verbose_name=_('Number Auto'), max_length=15, choices=choices_lists.TYPE_AUTO)
    price = models.IntegerField(verbose_name=_('Price'))
    time_work = models.PositiveSmallIntegerField(verbose_name=_('Time work'), help_text='В минутах')
    extra = models.BooleanField(verbose_name=_('Extra Service'), default=False)

    class Meta:
        verbose_name = _('Service')
        verbose_name_plural = _('Services')

    def __str__(self):
        return f'{self.title}'


class Rating(models.Model):
    """ Модель оценки автомойки """
    wash = models.ForeignKey(CarWash, verbose_name=_('Car Wash'), on_delete=models.CASCADE, related_name='wash_rating')
    user = models.ForeignKey(User, verbose_name=_('User'), on_delete=models.SET_NULL, null=True)
    score = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(5)
        ],
        verbose_name=_('Rating'),
        null=True,
        default=0
    )
    date_create = models.DateTimeField(verbose_name=_('Date create'), auto_now_add=True, db_index=True)

    class Meta:
        verbose_name = _('Rating')
        verbose_name_plural = _('Ratings')


class Administrator(models.Model):
    """ Модель администратора автомойки """
    boss = models.ForeignKey(User, on_delete=models.CASCADE, related_name='admin_boss')
    wash = models.ManyToManyField(to=CarWash, verbose_name=_('Car Wash'), related_name='wash_admin')
    phone = models.CharField(verbose_name=_('Phone'), max_length=12, blank=False)

    class Meta:
        verbose_name = _('Administrator')
        verbose_name_plural = _('Administrators')


class Washer(models.Model):
    """ Модель мойщика автомойки """
    name = models.CharField(verbose_name=_('Name'), max_length=30, blank=True, null=True)
    phone = models.CharField(verbose_name=_('Phone'), max_length=12, blank=False)
    wash = models.ForeignKey(CarWash, verbose_name=_('Car Wash'),
                             on_delete=models.CASCADE, related_name='wash_washer')

    class Meta:
        verbose_name = _('Washer')
        verbose_name_plural = _('Washers')

    def __str__(self):
        return f'{self.name}'
