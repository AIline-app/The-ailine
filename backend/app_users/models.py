from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import MaxValueValidator, MinValueValidator

from AstSmartTime import choices_lists


class User(AbstractUser):
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

    last_name = None
    first_name = None
    full_name = None

    username = models.CharField(verbose_name=_('Name'), max_length=30, blank=True, null=True)
    phone = models.CharField(verbose_name=_('Phone'), max_length=12, unique=True, blank=False)
    password = models.CharField(_('Password'), max_length=128)
    type_auto = models.CharField(verbose_name=_('Number Auto'), max_length=15, choices=choices_lists.TYPE_AUTO, blank=True)
    number_auto = models.CharField(verbose_name=_('Number Auto'), max_length=15, blank=True)
    role = models.CharField(verbose_name=_('Role'), max_length=20, choices=choices_lists.ROLE, null=True, blank=True)
    notification = models.PositiveSmallIntegerField(verbose_name=_('Notification'), null=True, blank=True)
    user_code = models.IntegerField(verbose_name=_('Code'), blank=True, null=True)
    is_phone_verified = models.BooleanField(verbose_name=_('Phone is verified'), blank=False, default=False)
    telegram = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('Telegram'),
        null=True,
        default=0
    )
    whatsapp = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('WhatsApp'),
        null=True,
        default=0
    )
    chat_id_telegram = models.BigIntegerField(verbose_name=_('Chat ID in Telegram'), null=True, blank=True, default=None)
    date_create = models.DateTimeField(verbose_name=_('Date create'), auto_now_add=True, db_index=True)
    soft_delete = models.BooleanField(verbose_name=_('Soft delete'), default=False)

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['username']

    class Meta:
        verbose_name = _('User')
        verbose_name_plural = _('Users')
        db_table = 'user'
        ordering = ['id']

    def __str__(self):
        return f'{self.phone}'


class UserCode(models.Model):
    """Модель смс-кода для регистрации."""
    username = models.CharField(verbose_name=_('Full name'), max_length=30, blank=True)
    phone = models.CharField(verbose_name=_('Phone'), max_length=12, unique=True, blank=False)
    user_code = models.IntegerField(verbose_name=_('Code'), blank=False, null=False)

    class Meta:
        verbose_name = _('User')
        verbose_name_plural = _('Users')


class UserCodeConfirm(models.Model):
    """Модель смс-кода для подтверждения."""
    phone = models.CharField(verbose_name=_('Phone'), max_length=12, unique=True, blank=False)
    user_code = models.IntegerField(verbose_name=_('Code'), blank=False, null=False)


class BankCard(models.Model):
    """Модель банковской карты."""
    user = models.ForeignKey(User, verbose_name=_('User'), on_delete=models.CASCADE, related_name='user_card')
    number = models.CharField(verbose_name=_('Card number'), max_length=250, null=True, blank=True)  # Для автомоек обязательно. у пользователей не храним
    last_number = models.CharField(verbose_name=_('Last 4 number'), max_length=16, null=True, blank=True)  # Для владельца
    token = models.CharField(verbose_name=_('Token from kassa24'), max_length=255, null=True, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'last_number'],
                name='unique_user_number'
            )
        ]


class CashOutData(models.Model):
    """Модель выплаты автомойке"""
    user = models.ForeignKey(User, on_delete=models.DO_NOTHING, related_name='user_cashout')
    count_orders = models.PositiveSmallIntegerField()
    sum = models.IntegerField(verbose_name='Payout amount', blank=True, null=True)
    list_order = models.CharField(max_length=2000, blank=True, null=True)
    date_create = models.DateTimeField(auto_now_add=True, blank=True, null=True)
