import json
import requests
import base64
from datetime import timedelta
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding
from rest_framework import serializers
from django.db import transaction
from django.utils import timezone
from AstSmartTime.settings import env
from AstSmartTime.constants import COMMISSION
from .models import Order, ItemService, PaymentData, FullCallbackData
from app_users.models import BankCard, User
from app_washes.models import Service, CarWash, Administrator
from app_washes.serializers import ServiceDetailSerializer
from app_adminwork.models import SlotsInWash
from app_bot.management.commands.bot import TOKEN
from telebot import TeleBot

merchant_id = env.str('MERCHANT_ID', 'MERCHANT_ID')
merchant_data = env.str(
    'MERCHANT_ID_PASSWORD_BASE64',
    'MERCHANT_ID_PASSWORD_BASE64'
)
bot = TeleBot(token=TOKEN)


def notify_for_admin(wash, message):
    try:
        user = [user for user in User.objects.all() if user.phone == wash.wash_admin.first().phone][0]
        if user.chat_id_telegram is not None:
            bot.send_message(user.chat_id_telegram, message)
    except Exception:
        pass


def two_stage_payment(id_payment, action):
    data = {
        "ID": id_payment,
        "action": action
    }
    headers = {
        "Authorization": f"Basic {merchant_data}",
        "Content-type": "application/json",
        "Accept": "application/json"
    }
    link = requests.post(
        url="https://ecommerce.pult24.kz/payment/processing/end",
        json=data,
        headers=headers
    )

    return link.json()


def payment(order_id, amount, card_data, if_save, last_number, id_card):
    user = Order.objects.get(id=order_id).customer
    if id_card is not None:
        bank_card = BankCard.objects.get(id=id_card)
        customer_data = {
            "phone": user.phone,
            "cardToken": bank_card.token
        }
    else:
        customer_data = {"phone": user.phone, "cardData": card_data.decode('utf-8')}
    data = {
        "merchantId": merchant_id,
        "callbackUrl": "https://i-line.kz/api/orders/callback",
        "returnUrl": f"https://i-line.kz/payment/{order_id}",
        "amount": amount * 100,
        "orderId": str(order_id),
        "description": f"Оплата заказа под номером {order_id}",
        "acquiringId": 139,
        "metadata": {
            "if_save": if_save,
            "last_number": last_number
        },
        "customerData": customer_data,
        "demo": False,
    }
    headers = {
        "Authorization": f"Basic {merchant_data}",
        "Content-type": "application/json",
        "Accept": "application/json"
    }
    link = requests.post(
        url="https://ecommerce.pult24.kz/payment/create",
        json=data,
        headers=headers
    )
    return link.json()


def encrypted_payment(message):
    with open('public.pem', 'wb+') as key_file:
        key = requests.get('https://ecommerce.pult24.kz/payment/getcert/pem').content  # получаем pem-ключ с эндпоинта.
        key_file.write(key)

    key_file = open('public.pem')
    pub_key = serialization.load_pem_public_key(                # Сериализуем ключ
        key_file.read().encode('utf-8'),
        default_backend()
    )

    message = json.dumps(message).encode('utf-8')               # Из словаря с платёжными данными получаем JSON-строку, её переделываем в байтовый массив для алгоритма.
    sha256 = hashes.SHA256()                                    # Хэш-функция.
    mgf = padding.MGF1(algorithm=sha256)                        # MGF1 заполнение, с применением хэширования.
    pad = padding.OAEP(mgf=mgf, algorithm=sha256, label=None)   # OAEP заполнение, с применением хэширования.
    data = pub_key.encrypt(message, pad)                        # Алгоритм RSA шифрования, с использованием заполнений OAEP и MGF1.

    return base64.b64encode(data)                               # Полученный байтовый массив с зашифрованными данными энкодируем в base64.


class ItemServiceSerializer(serializers.ModelSerializer):
    service = ServiceDetailSerializer()

    class Meta:
        model = ItemService
        fields = ('service',)


class CreateOrderSerializer(serializers.ModelSerializer):
    """
    Сериализатор создания заказа и оплаты.
    """
    customer = serializers.HiddenField(
        default=serializers.CurrentUserDefault()
    )
    item_service = ItemServiceSerializer(many=True, required=False)
    service = serializers.PrimaryKeyRelatedField(queryset=Service.objects.all(), many=True)

    class Meta:
        model = Order
        fields = ('id', 'customer', 'car_wash', 'washer', 'service', 'time_start', 'item_service',
                  'time_work', 'final_price', 'status', 'time_end', 'on_site', 'rated', 'price', 'commission')

    @transaction.atomic
    def create(self, validated_data):
        time_work = 0
        price = 0
        customer = validated_data.pop('customer')
        car_wash = validated_data.pop('car_wash')
        washer = validated_data.pop('washer')
        service = validated_data.pop('service')
        validated_data.pop('link', None)
        wash = CarWash.objects.get(id=car_wash.id)
        if wash.is_validate is False:
            raise ValueError('Car Wash is not valid')

        new_order = Order.objects.create(
            customer=customer,
            car_wash=car_wash,
            washer=washer,
            **validated_data
        )
        for serv in service:
            item = Service.objects.get(id=serv.id)
            time_work += item.time_work
            price += item.price
            ItemService.objects.create(service=item, order=new_order)

        query = SlotsInWash.objects.filter(wash=car_wash).only('status')
        free_slot = SlotsInWash.objects.filter(wash=car_wash, status='Free')
        for slot in query:
            if (slot.status == 'Free' or slot.status is None) and len(Order.objects.filter(car_wash=wash, status='Reserve')) <= len(free_slot):
                new_order.time_start = timezone.now() + timedelta(minutes=30)
                break
        if new_order.time_start is None:
            orders = Order.objects.filter(car_wash=wash, status__in=['Reserve', 'In progress'], time_end__isnull=False).order_by('-time_end')
            if orders[len(query) - 1].time_end < timezone.now():  # защита от тупости(админ не убрал вечером заказ из бокса)
                new_order.time_start = timezone.now() + timedelta(minutes=30)
            else:
                new_order.time_start = orders[len(query) - 1].time_end

        new_order.time_work = time_work
        new_order.price = price
        new_order.time_end = new_order.time_start + timedelta(minutes=time_work)
        new_order.commission = (new_order.price / 100) * COMMISSION
        new_order.final_price = new_order.price + new_order.commission
        new_order.save()

        last_order = Order.objects.filter(car_wash=wash, status__in=['Reserve', 'In progress']).order_by('-time_end')

        if len(last_order) < wash.slots:  # Если заказов в слотах и в очереди меньше количества слотов у мойки
            wash.last_time = timezone.now()
        else:
            wash.last_time = last_order[len(query) - 1].time_end

        notify_for_admin(wash, f'Клиент с номером {customer.number_auto} встал в очередь')

        wash.save()

        return new_order


class OrderSerializer(serializers.ModelSerializer):
    """
    Сериализатор отображения заказа/заказов.
    """
    customer = serializers.SlugRelatedField(slug_field='number_auto', read_only=True)
    item_service = ItemServiceSerializer(many=True, required=False)
    service = serializers.PrimaryKeyRelatedField(queryset=Service.objects.all(), many=True, required=False)
    car_wash = serializers.SlugRelatedField(slug_field='id', queryset=CarWash.objects.all(), required=False)
    wash_title = serializers.SerializerMethodField()
    phone = serializers.SerializerMethodField()
    phone_admin = serializers.SerializerMethodField()
    customer_name = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ('id', 'customer', 'car_wash', 'washer', 'time_start', 'status', 'item_service', 'service', 'final_price',
                  'rating', 'rated', 'on_site', 'time_end', 'date_create', 'payment_status', 'wash_title', 'price',
                  'commission', 'phone', 'phone_admin', 'customer_name')

    def get_wash_title(self, obj):
        return obj.car_wash.title

    def get_phone_admin(self, obj):
        try:
            return Administrator.objects.filter(boss=obj.car_wash.user)[0].phone
        except Exception:
            return None

    def get_phone(self, obj):
        return obj.customer.phone

    def get_customer_name(self, obj):
        return obj.customer.username

    @transaction.atomic
    def update(self, instance, validated_data):
        rating = validated_data.get('rating')
        car_wash = validated_data.get('service')[0].wash
        wash = CarWash.objects.get(pk=car_wash.pk)

        if validated_data.get('on_site') is not None and validated_data.get('on_site') == 1:
            notify_for_admin(wash, f'Клиент с номером {instance.customer.number_auto} на месте.')

        if rating is not None and rating >= 1:
            value = 0
            count = 0
            for order in Order.objects.filter(car_wash=car_wash):
                if order.rating is not None and order.rating >= 1:
                    value += order.rating
                    count += 1
            try:
                total = int(value / count)
            except ZeroDivisionError:
                total = int(value + rating)
            wash.rating = total
            instance.rated = 1
            wash.save()
        if rating == 0:
            pass
        instance = super().update(instance, validated_data)

        return instance


class OrderCancelSerializer(serializers.ModelSerializer):
    """Сериализатор отмены заказа."""

    class Meta:
        model = Order
        fields = ('id', 'status', 'payment_status')

    def update(self, instance, validated_data):
        order = Order.objects.get(id=instance.id)
        wash = CarWash.objects.get(id=order.car_wash.id)
        query = SlotsInWash.objects.filter(wash=wash).only('status')
        last_order = Order.objects.filter(car_wash=wash, status__in=['Reserve', 'In progress']).order_by('-time_end')

        if len(last_order) < wash.slots:  # Если заказов в слотах и в очереди меньше количества слотов у мойки
            wash.last_time = timezone.now()
        else:
            wash.last_time = last_order[len(query) - 1].time_end  #

        wash.save()

        return instance


class OrderCallBackSerializer(serializers.Serializer):
    """Обратока callback'а от платёжки."""
    id = serializers.CharField(required=False)
    metadata = serializers.JSONField(required=False)
    status = serializers.IntegerField(required=False)
    orderId = serializers.CharField(required=False)
    description = serializers.CharField(required=False)
    amount = serializers.IntegerField(required=False)
    commission = serializers.IntegerField(required=False)
    date = serializers.DateTimeField(required=False)
    errCode = serializers.CharField(required=False)
    errMessage = serializers.CharField(required=False, allow_blank=True)
    cardToken = serializers.CharField(required=False)

    def validate(self, validated_data):
        # прислать ответ {"accepted": true}, что коллбэк принят
        FullCallbackData.objects.create(
            order=int(validated_data.get('orderId', None)),
            callback=str(validated_data),
            type_callback='Оплата'
        )
        order_id = int(validated_data.pop('orderId', None))
        status = validated_data.get('status')
        err_code = validated_data.pop('errCode')
        metadata = validated_data.pop('metadata')
        if_save = metadata['if_save']
        card_token = validated_data.pop('cardToken', None)
        order = Order.objects.get(id=order_id)
        user = order.customer

        if if_save == 1:
            BankCard.objects.create(
                user=user,
                last_number=metadata['last_number'],
                token=card_token
            )
        payment_db = PaymentData.objects.create(
            order=order_id,
            date=validated_data.pop('date'),
            id_payment=validated_data.get('id'),
            price=validated_data.pop('amount'),
            commission=validated_data.pop('merchantCommission', None),
            err=validated_data.pop('errMessage'),
            err_code=err_code,
            status=status
        )

        if status == 2:
            order.payment_status = 'Created'
            payment_db.payment_status = 'Created'

        elif status == 1:
            order.payment_status = 'Fulfilled'
            payment_db.payment_status = 'Fulfilled'

        elif status == 0 and err_code == 230:
            order.payment_status = 'Timeout'
            order.status = 'Canceled'

        elif status == 0:
            order.payment_status = 'Reject'
            order.status = 'Canceled'

        elif status == 3 or status == 4 or status == 5 or status == 31:
            order.payment_status = 'Canceled'
            order.status = 'Canceled'
            payment_db.payment_status = 'Canceled'

        order.save()
        payment_db.save()
        return validated_data


class PaymentSerializers(serializers.Serializer):
    cvv = serializers.CharField(write_only=True, required=False)
    id_card = serializers.IntegerField(required=False)
    number = serializers.CharField(required=False)
    owner = serializers.CharField(required=False)
    end_date = serializers.CharField(required=False)
    if_save = serializers.IntegerField(required=False)
    user = serializers.HiddenField(
        default=serializers.CurrentUserDefault()
    )
    link = serializers.CharField(required=False)

    def validate(self, validated_data):
        id_card = validated_data.get('id_card')
        if id_card is not None:
            bank_card = BankCard.objects.get(id=id_card)
            validated_data['last_number'] = bank_card.last_number
            validated_data['user'] = bank_card.user
            validated_data['token'] = bank_card.token

        return validated_data
