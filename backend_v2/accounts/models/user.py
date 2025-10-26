import logging
import uuid

import phonenumbers
from django.apps import apps
from django.conf import settings
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import PermissionsMixin
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import RegexValidator

from accounts.utils.constants import MAX_USERNAME_LENGTH, MAX_PHONE_NUMBER_LENGTH
from accounts.utils.enums import TypeSmsCode, UserRoles


class Roles(models.Model):
    name = models.CharField(_('Role name'), choices=UserRoles.choices, primary_key=True)
    user = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='roles', related_query_name='users')

    def __eq__(self, other):
        if type(other) in (str, UserRoles):
            return self.name == other
        return super(Roles, self).__eq__(other)


class UserManager(BaseUserManager):
    """Менеджер кастомного пользователя, для которого телефон - уникальный идентификатор"""

    def normalize_phone_number(self, phone_number):
        return phonenumbers.format_number(
            phonenumbers.parse(phone_number, None),
            phonenumbers.PhoneNumberFormat.E164
        )

    def _create_user(self, username, phone_number, password, **extra_fields):
        """
        Create and save a user with the given phone_number and password.
        """
        role = extra_fields.pop('role')
        phone_number = self.normalize_phone_number(phone_number)

        GlobalUserModel = apps.get_model(
            self.model._meta.app_label, self.model._meta.object_name
        )
        username = GlobalUserModel.normalize_username(username)
        user = self.model(username=username, phone_number=phone_number, **extra_fields)
        user.password = make_password(password)
        user.save(using=self._db)
        user.roles.add(role)
        return user

    def create_user(self, username, phone_number, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        extra_fields.setdefault("role", (UserRoles.CLIENT,))
        return self._create_user(username, phone_number, password, **extra_fields)

    def create_superuser(self, username, phone_number, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self._create_user(username, phone_number, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Модель пользователя (общая).

    Attributes
        username: ФИО
        phone: Телефон
        password: Пароль
        type_auto: Тип авто
        number_auto: Номер авто
        role: Роль юзера (пользователь/администратор автомойки)
        notification: За какое время присылать оповещение о мойке
        user_code: Одноразовый код для вода в аккаунт
        is_phone_verified: True - телефон подтверждён, False - не подтверждён
        telegram: Оповещать в телеграмм
        whatsapp: Оповещать в ватсапп (недоступно)
        chat_id_telegram: ID пользователя в телеграмм
    """

    objects: UserManager = UserManager()

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_validator = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message=_("Phone number must be entered in the format: '+999999999'. Up to 15 digits allowed."),
    )

    username = models.CharField(verbose_name=_('Name'), max_length=MAX_USERNAME_LENGTH, blank=True, null=True)
    phone_number = models.CharField(
        _('Phone number'),
        unique=True,
        validators=[phone_validator],
        max_length=MAX_PHONE_NUMBER_LENGTH,
    )
    password = models.CharField(_('Password'), max_length=128)
    is_staff = models.BooleanField(_("Staff Status"), default=False)
    is_superuser = models.BooleanField(_("Superuser Status"), default=False)
    is_active = models.BooleanField(_("Active"), default=False)
    created_at = models.DateTimeField(_('Date create'), auto_now_add=True)

    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['password']

    class Meta:
        verbose_name = _('User')
        verbose_name_plural = _('Users')
        db_table = 'user'
        ordering = ['id']

    def __str__(self):
        return f'<User ({self.phone_number}, {self.id})>'

    def send_registration_code(self):
        phone_number = self.phone_number.split('+')[1]

        sms = self.sms_codes.create(type=TypeSmsCode.REGISTER)
        # sms = self.sms_codes.create(user=self, type=TypeSmsCode.REGISTER)
        for _ in range(3):
            try:
                # TODO Place in queue to be sent by another service
                # requests.get(f'http://kazinfoteh.org:9507/api?action=sendmessage&username={settings.SMS_LOGIN}&password={settings.SMS_PASSWORD}&recipient={phone}&messagetype=SMS:TEXT&originator=TEXT_MSG&messagedata=Registration code - {str(sms.code)}')
                print(f'http://kazinfoteh.org:9507/api?action=sendmessage&username={settings.SMS_LOGIN}&password={settings.SMS_PASSWORD}&recipient={phone_number}&messagetype=SMS:TEXT&originator=TEXT_MSG&messagedata=Registration code - {str(sms.code)}')
                return True
            except Exception as error:
                logging.error(f'Failed to send an SMS to {phone_number}: {error}')
        else:
            return False
