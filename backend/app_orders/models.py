from django.conf import settings
from django.db import models
from django.utils.translation import gettext_lazy as _

from AstSmartTime import choices_lists
from app_washes.models import Service, CarWash
from app_users.models import MaxValueValidator, MinValueValidator


class Order(models.Model):
    """ Модель заказа

    Attributes
        customer: Пользователь
        car_wash: Автомойка
        time_start: Время начала
        time_work: Время мойки
        final_price: Итоговая цена
        commission: Коммиссия за заказ
        status: Статус заказа (бронь, в процессе, завершено, отменено)
        status_payment: Статус оплаты
        on_site: Статус приезда клиента(1 - на месте, 0 - в пути)
        rating: Рейтинг заказа. По нему считается рейтинг мойки
        rated: Оценён/не оценён
        notified: Оповещение клиента о приближении его очереди
        notified_by_admin: Оповещение администратора мойки о создании заказа
        cash_out_status: Статус выплаты средств за мойку владельцу автомойки
        service: Список услуг в заказе
        box_id: ID бокса, в котором выполнялся заказ
    """
    customer = models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name=_('Customer'), on_delete=models.PROTECT,
                                 blank=True, null=True, related_name='order_customer')
    car_wash = models.ForeignKey(CarWash, verbose_name=_('CarWash'), on_delete=models.PROTECT, related_name='orders')
    time_start = models.DateTimeField(verbose_name=_('Time start'), blank=True, null=True)
    time_work = models.PositiveSmallIntegerField(help_text='В минутах', null=True, blank=True)
    time_end = models.DateTimeField(verbose_name=_('Time end'), blank=True, null=True)
    price = models.IntegerField(verbose_name=_('Price'), null=True, blank=True)
    final_price = models.IntegerField(verbose_name=_('Final price'), null=True, blank=True)
    commission = models.IntegerField(verbose_name=_('Commission'), null=True, blank=True)
    status = models.CharField(verbose_name=_('Status'), max_length=20, choices=choices_lists.STATUS_ORDER, blank=True,
                              default='Reserve')
    payment_status = models.CharField(verbose_name=_('Status'), max_length=20, choices=choices_lists.STATUS_PAYMENT, blank=True, default='Pending')
    payment_cashout_id = models.IntegerField(default=0)
    on_site = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('On site or on the road'),
        null=True,
        default=0
    )
    rating = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(5)
        ],
        verbose_name=_('Rating'),
        null=True,
        default=0
    )
    rated = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('Evaluation status'),
        null=True,
        default=0
    )
    notified = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('Evaluation status'),
        null=True,
        default=0
    )
    notified_by_admin = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('Evaluation status'),
        null=True,
        default=0
    )
    cash_out_status = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('Evaluation status'),
        null=True,
        default=0
    )
    service = models.ManyToManyField(Service, through='ItemService')
    date_create = models.DateTimeField(verbose_name=_('Date time order create'), auto_now_add=True, db_index=True)
    soft_delete = models.BooleanField(verbose_name=_('Soft delete'), default=False)
    box_id = models.PositiveSmallIntegerField(null=True, blank=True)
    test_field = models.CharField(max_length=100, default=None, null=True, blank=True)

    class Meta:
        verbose_name = _('Order')
        verbose_name_plural = _('Orders')

    def __str__(self):
        return f'{self.customer}'


class NotificationData(models.Model):
    """Храним кому было отправлено уведомление."""
    order = models.CharField(max_length=255)
    message = models.CharField(max_length=355)
    datecreate = models.DateTimeField(auto_now_add=True, null=True, blank=True)


class ItemService(models.Model):
    """ Модель услуги для заказа"""
    order = models.ForeignKey(Order, verbose_name=_('Order'), on_delete=models.CASCADE,
                              blank=False, null=True, related_name='item_service')
    service = models.ForeignKey(Service, verbose_name=_('Service'), on_delete=models.CASCADE,
                                blank=False, null=True, related_name='services')

    class Meta:
        verbose_name = _('Item Service')
        verbose_name_plural = _('Items Service')

    def __str__(self):
        return f'{self.service}'


class PaymentData(models.Model):
    """
    Храним данные об оплате.
    type - Тип платежа. (0 - платёж, 1 - выплата).
    """
    order = models.CharField(max_length=155, null=True, blank=True)
    price = models.CharField(max_length=155, blank=True, null=True)
    id_payment = models.CharField(max_length=155, blank=True, null=True)
    commission = models.CharField(max_length=155, blank=True, null=True)
    payment_status = models.CharField(verbose_name=_('Status'), max_length=20, choices=choices_lists.STATUS_PAYMENT, blank=True, default='Pending')
    type_payment = models.PositiveSmallIntegerField(
        validators=[
            MinValueValidator(0), MaxValueValidator(1)
        ],
        verbose_name=_('Type payment'),
        null=True,
        default=0,
        blank=True
    )
    status = models.CharField(max_length=255, blank=True, null=True)
    err = models.CharField(max_length=255, blank=True, null=True)
    err_code = models.IntegerField(blank=True, null=True)
    date = models.DateTimeField(blank=True, null=True)
    metadata = models.JSONField(blank=True, null=True)


class FullCallbackData(models.Model):
    """Записываю весь коллбек"""
    order = models.CharField(max_length=55, null=True, blank=True)
    type_callback = models.CharField(max_length=255, null=True, blank=True)
    callback = models.CharField(max_length=10000, null=True, blank=True)
