import logging
import uuid
import json

import phonenumbers
from kafka import KafkaProducer
from django.conf import settings
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import PermissionsMixin, AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import RegexValidator

from accounts.utils.constants import (
    MAX_USERNAME_LENGTH,
    MAX_PHONE_NUMBER_LENGTH,
    PHONE_VALIDATE_REGEX,
    PHONE_VALIDATE_MESSAGE,
    MAX_PASSWORD_LENGTH,
    SMS_REGISTRATION_MESSAGE,
    MANAGER_REGISTRATION_MESSAGE,
)
from accounts.utils.enums import TypeSmsCode
from accounts.utils.kafka import Kafka
from iLine.settings import APP_HOST


class UserManager(BaseUserManager):
    """Менеджер кастомного пользователя, для которого телефон - уникальный идентификатор"""

    def normalize_phone_number(self, phone_number):
        return phonenumbers.format_number(
            phonenumbers.parse(phone_number, None),
            phonenumbers.PhoneNumberFormat.E164,
        )

    def _create_user(self, username, phone_number, password, **extra_fields):
        """
        Create and save a user with the given phone_number and password.
        """
        phone_number = self.normalize_phone_number(phone_number)

        user = self.model(username=username, phone_number=phone_number, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, username, phone_number, password=None, is_verified=False, **extra_fields):
        extra_fields["is_staff"] = False
        extra_fields["is_superuser"] = False
        extra_fields["is_active"] = True
        extra_fields["is_verified"] = is_verified
        return self._create_user(username, phone_number, password, **extra_fields)

    def create_superuser(self, username, phone_number, password=None, **extra_fields):
        extra_fields["is_staff"] = True
        extra_fields["is_superuser"] = True
        extra_fields["is_active"] = True
        extra_fields["is_verified"] = True
        return self._create_user(username, phone_number, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Модель пользователя (общая).

    Attributes
        username: ФИО
        phone: Телефон
        password: Пароль
        type_auto: Тип авто
        number_auto: Номер авто
        notification: За какое время присылать оповещение о мойке
        user_code: Одноразовый код для вода в аккаунт
        is_phone_verified: True - телефон подтверждён, False - не подтверждён
        telegram: Оповещать в телеграмм
        whatsapp: Оповещать в ватсапп (недоступно)
        chat_id_telegram: ID пользователя в телеграмм
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # phone_validator = RegexValidator(
    #     regex=PHONE_VALIDATE_REGEX,
    #     message=_(PHONE_VALIDATE_MESSAGE.format(MAX_PHONE_NUMBER_LENGTH=MAX_PHONE_NUMBER_LENGTH)),
    # )
    username = models.CharField(verbose_name=_('Name'), max_length=MAX_USERNAME_LENGTH, blank=True, null=True)
    phone_number = models.CharField(
        _('Phone number'),
        unique=True,
        # validators=[phone_validator],
        max_length=MAX_PHONE_NUMBER_LENGTH,
        blank=False,
        null=True,
    )
    password = models.CharField(_('Password'), max_length=MAX_PASSWORD_LENGTH)
    is_staff = models.BooleanField(_("Staff Status"), default=False)
    is_superuser = models.BooleanField(_("Superuser Status"), default=False)
    is_verified = models.BooleanField(_("Active"), default=False)
    is_active = models.BooleanField(_("Active"), default=True)
    created_at = models.DateTimeField(_('Date created'), auto_now_add=True)

    USERNAME_FIELD = 'phone_number'
    REQUIRED_FIELDS = ['password']

    objects: UserManager = UserManager()

    class Meta:
        verbose_name = _('User')
        verbose_name_plural = _('Users')
        db_table = 'user'
        ordering = ('id',)

    def __str__(self):
        return f'<User ({self.phone_number}, {self.id})>'

    def send_registration_code(self, code: str) -> bool:
        return self.__send_to_kafka(_(SMS_REGISTRATION_MESSAGE).format(code=code))

    def send_manager_invitation(self) -> bool:
        return self.__send_to_kafka(_(MANAGER_REGISTRATION_MESSAGE).format(app_link=APP_HOST))

    def __send_to_kafka(self, message: str) -> bool:
        # TODO deleted user will have no phone number
        try:
            Kafka().send(
                topic=settings.KAFKA_SMS_TOPIC,
                payload={"phone": self.phone_number.lstrip('+'), "message": message},
            )
            return True
        except Exception as error:
            # TODO notify admin?
            logging.error(f"Kafka not available for sending SMS for user {self.id}: {error}")
        return False