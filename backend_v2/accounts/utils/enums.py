from django.db.models import TextChoices
from django.utils.translation import gettext_lazy as _


class UserRoles(TextChoices):
    CLIENT = ('client', _('Client'))
    WASHER = ('washer', _('Washer'))
    MANAGER = ('manager', _('Manager'))
    DIRECTOR = ('director', _('Director'))


class TypeAuto(TextChoices):
    SEDAN = ('sedan', _('Sedan'))
    JEEP = ('jeep', _('Jeep'))
    MINIVAN = ('minivan', _('Minivan'))
    CROSSOVER = ('crossover', _('Crossover'))
    MINIBUS = ('minibus', _('Minibus'))


class TypeSmsCode(TextChoices):
    REGISTER = ('register', _('Registration Code'))
    CONFIRM = ('confirm', _('Confirm Code'))
