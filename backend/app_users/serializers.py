import random
import requests
from rest_framework_simplejwt.exceptions import TokenError
from AstSmartTime import settings
from django.contrib.auth.hashers import make_password
from django.shortcuts import get_object_or_404
from django.db import transaction
from django.utils.translation import gettext_lazy as _
from django.core.exceptions import ObjectDoesNotExist
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken

from AstSmartTime.settings import env
from .exception import CustomSMSException
from app_orders.models import Order, PaymentData, FullCallbackData
from app_orders.serializers import OrderSerializer
from app_orders.serializers import encrypted_payment
from app_users.models import User, UserCode, BankCard, CashOutData, UserCodeConfirm
from app_washes.models import Administrator, CarWash

merchant_id = env.str('MERCHANT_ID', 'MERCHANT_ID')
merchant_data = env.str(
    'MERCHANT_ID_PASSWORD_BASE64',
    'MERCHANT_ID_PASSWORD_BASE64'
)


def cash_out(amount, card_data, phone, metadata):
    data = {
        "type": 1,
        "merchantId": merchant_id,
        "callbackUrl": "https://i-line.kz/api/users/callback",
        "amount": int(amount) * 100,
        "customerData": {
            "cardData": card_data.decode('utf-8'),
            "phone": phone
        },
        "metadata": metadata,
        "acquiringId": 111,
        "demo": False
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


def send_message(phone, message):
    phone = phone.split('+')[1]
    try:
        return requests.get(f'http://kazinfoteh.org:9507/api?action=sendmessage&username={settings.SMS_LOGIN}&password={settings.SMS_PASSWORD}&recipient={phone}&messagetype=SMS:TEXT&originator=TEXT_MSG&messagedata=Code - {str(message)}')
    except Exception as error:
        raise CustomSMSException(f'Смс не отправлено по причине: {error}')


class BankCardSerializer(serializers.ModelSerializer):
    """Сериализатор создание банковских данных."""
    user = serializers.HiddenField(
        default=serializers.CurrentUserDefault()
    )
    number = serializers.CharField(write_only=True)

    class Meta:
        model = BankCard
        fields = '__all__'

    def create(self, validated_data):
        number = validated_data.pop('number')
        user = validated_data.pop('user')
        last_number = '*' + number[-4:]
        new_card = BankCard.objects.create(
            user=user,
            number=number,
            last_number=last_number
        )
        if user.role == 'partner':
            for wash in CarWash.objects.filter(user=user):
                if wash.wash_admin.count() > 0:
                    wash.is_validate = True
                    wash.save()
        return new_card

    def update(self, instance, validated_data):
        instance.number = validated_data.pop('number')
        instance.last_number = '*' + instance.number[-4:]
        instance.save()

        return instance

    @staticmethod
    def destroy(id_card):
        try:
            card = BankCard.objects.get(id=id_card)
            wash = CarWash.objects.get(user_id=card.user_id)
            wash.is_validate = False
            wash.save()
        except Exception as error:
            raise f'Error {error}!'


class CashOutSerializer(serializers.ModelSerializer):
    """Сериализатор выплаты."""
    code = serializers.IntegerField(required=False, default=None)
    count_order = serializers.SerializerMethodField()
    count_price = serializers.SerializerMethodField()
    queue = serializers.SerializerMethodField()
    orders = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('count_order', 'count_price', 'orders', 'queue', 'code')

    def get_count_order(self, obj):
        return Order.objects.filter(car_wash__user=obj.id, status='Done', cash_out_status=0).count()

    def get_queue(self, obj):
        return Order.objects.filter(car_wash__user=obj.id, status__in='Reserve', payment_status__in='Created', cash_out_status=0).count()

    def get_count_price(self, obj):
        count_price = 0
        for order in Order.objects.filter(car_wash__user=obj.id, status='Done', cash_out_status=0):
            count_price += order.price
        return count_price

    def get_orders(self, obj):
        qs = Order.objects.filter(car_wash__user=obj.id, status='Done', cash_out_status=0)
        serializer = OrderSerializer(instance=qs, many=True)

        return serializer.data

    def validate(self, request):
        refresh = RefreshToken(self.context['request'].COOKIES.get('refresh'))
        user_sms = request.pop('code')
        user_db = get_object_or_404(User, pk=refresh.get('user_id'))
        try:
            number = '*' + BankCard.objects.get(user=user_db).number[-4:]
        except ObjectDoesNotExist as error:
            raise serializers.ValidationError({'code': f'Произошла ошиибка {error}'})
        phone = user_db.phone
        user_code = random.randint(1000, 9999)
        list_orders = []

        if user_sms is None:
            try:
                UserCodeConfirm.objects.filter(phone=phone).delete()
                send_message(phone=phone, message=f'{user_code} Вывод средств {number}.')
                UserCodeConfirm.objects.create(phone=phone, user_code=user_code)
                return request
            except ObjectDoesNotExist as error:
                raise serializers.ValidationError({'code': f'Произошла ошиибка {error}'})
        else:
            try:
                if UserCodeConfirm.objects.get(phone=phone).user_code == user_sms:
                    count = 0
                    sum = 0
                    for order in Order.objects.filter(car_wash__user=user_db, cash_out_status=0, payment_status='Fulfilled', status='Done').order_by('date_create'):
                        if sum >= 2000000:  # максимальная сумма выплаты
                            break

                        list_orders.append(order.id)
                        sum += order.price
                        count += 1
                        # order.cash_out_status = 1
                        order.save()

                    cashout = CashOutData.objects.create(
                        user=user_db,
                        count_orders=count,
                        sum=sum,
                        list_order=list_orders
                    )
                    for order_id in list_orders:
                        try:
                            order = Order.objects.get(pk=order_id)
                            order.payment_cashout_id = cashout.id
                            order.save()
                        except ObjectDoesNotExist as error:
                            raise serializers.ValidationError({'code': f'Заказ не найден {error}'})

                    wash_card = {"pan": BankCard.objects.get(user=user_db).number}

                    cash_out(
                        amount=sum,
                        card_data=encrypted_payment(message=wash_card),
                        phone=user_db.phone,
                        metadata={'id_cashout': cashout.id},
                    )

                    UserCodeConfirm.objects.filter(phone=phone).delete()
                    return request
                else:
                    raise serializers.ValidationError({'code': _('This user code is not True')})
            except Exception as error:
                raise serializers.ValidationError({'code': f'Выплата не произведена: {error}'})

    def update(self, instance, validated_data):
        return instance


class ListBankCardSerializers(serializers.ModelSerializer):
    """Сериализатор получения списка карт"""

    class Meta:
        model = BankCard
        fields = ('id', 'last_number')


class RegisterSerializer(TokenObtainPairSerializer, serializers.Serializer):
    """Сериализатор регистрации пользователя (по смс)"""
    phone = serializers.CharField(max_length=12, min_length=12)
    password = serializers.CharField(max_length=20, min_length=6)
    role = serializers.CharField(max_length=40, min_length=5)
    user_code = serializers.IntegerField(required=False, default=None)
    token = serializers.JSONField(required=False)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.user_code = random.randint(1000, 9999)

    @transaction.atomic
    def validate(self, request):
        phone = request.get('phone')
        user_sms = request.pop('user_code', None)

        if user_sms is None:
            UserCode.objects.filter(phone=phone).delete()
            if User.objects.filter(phone=phone).exists():
                raise serializers.ValidationError({'phone': _('This number is already registered')})
            else:
                send_message(phone=phone, message=self.user_code)
                UserCode.objects.create(phone=phone, user_code=self.user_code)
                return request
        else:
            user = UserCode.objects.get(phone=phone)
            password = request.get('password', None)
            role = request.get('role', None)
            if user_sms == user.user_code:
                new_user = User.objects.create(phone=phone, password=(make_password(password)), role=role)
                user.delete()
                new_user.token = super().validate(request)
                return new_user
            else:
                raise serializers.ValidationError({'code': _('This user code is not True')})


class MyTokenRefreshSerializer(serializers.Serializer):
    """Сериализатор обновления access токена"""

    def validate(self, attrs):
        refresh = RefreshToken(self.context['request'].COOKIES.get('refresh'))
        if User.objects.get(pk=refresh.get('user_id')) is None:
            raise KeyError
        data = {'access': str(refresh.access_token)}
        return data


class LoginUserSerializer(TokenObtainPairSerializer, serializers.ModelSerializer):
    """Сериализатор аутентификации пользователя по телефону и паролю"""
    phone = serializers.CharField(max_length=12, min_length=12)
    password = serializers.CharField()

    class Meta:
        model = User
        fields = ['id', 'phone', 'password']


class RefreshTokenSerializer(serializers.Serializer):

    default_error_messages = {
        'bad_token': _('Token is invalid or expired')
    }

    def validate(self, attrs):
        attrs = RefreshToken(self.context['request'].COOKIES.get('refresh'))
        return attrs

    def save(self, **kwargs):
        try:
            RefreshToken(self.context['request'].COOKIES.get('refresh')).blacklist()
        except TokenError:
            self.fail('bad_token')


class DetailUserSerializer(serializers.ModelSerializer):
    """Сериализатор анкеты пользователя"""
    password = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['id', 'username', 'phone', 'type_auto', 'number_auto',
                  'role', 'telegram', 'whatsapp', 'notification', 'password', 'chat_id_telegram']

    def update(self, instance, validated_data):
        instance.role = validated_data.pop('role', instance.role)
        instance.username = validated_data.pop('username', instance.username)
        instance.type_auto = validated_data.pop('type_auto', instance.type_auto)
        instance.number_auto = validated_data.pop('number_auto', instance.number_auto)
        instance.chat_id_telegram = validated_data.pop('chat_id_telegram', instance.chat_id_telegram)
        password = validated_data.pop('password', instance.password)
        if instance.role == 'light_client' and instance.username is not None and instance.type_auto is not None and instance.number_auto is not None:
            instance.role = 'client'
        if instance.role == 'light_manager':
            for admin in Administrator.objects.all():
                if admin.phone == instance.phone:
                    instance.role = 'manager'
                else:
                    instance.role = 'client'
        # if instance.chat_id_telegram is not None and instance.chat_id_telegram != User.objects.get(id=instance.id).chat_id_telegram:
        #     say_hi(instance.chat_id_telegram, "Регистрация завершена успешно! Добро пожаловать!")
        if instance.password != password:
            instance.password = make_password(password)
            instance.save()
        instance = super().update(instance, validated_data)
        return instance


class TokenObtainWithoutPasswordSerializer(serializers.Serializer):
    """Сериализатор токена."""
    token_class = None

    @classmethod
    def get_token(cls, user):
        return cls.token_class.for_user(user)


class TokenObtainPairWithoutLoginSerializer(TokenObtainWithoutPasswordSerializer):
    """Сериалиазатор присвоение токена без пароля."""
    token_class = RefreshToken

    def validate(self, attrs):
        refresh = RefreshToken.for_user(User.objects.get(phone=attrs.get('phone')))
        data = {
            'access': str(refresh.access_token),
            'refresh': str(refresh)
        }
        return data


class UpdateUserPasswordSerializer(TokenObtainPairWithoutLoginSerializer, serializers.Serializer):
    """Сериализатор для изменения пароля без авторизации."""
    phone = serializers.CharField(max_length=12, min_length=12)
    user_code = serializers.IntegerField(required=False, default=None)
    token = serializers.JSONField(required=False)
    password = serializers.CharField(required=False, write_only=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.user_code = random.randint(1000, 9999)

    @transaction.atomic
    def validate(self, request):
        phone = request.get('phone')
        user_sms = request.pop('user_code', None)

        if user_sms is None and User.objects.filter(phone=phone).exists():
            UserCode.objects.filter(phone=phone).delete()
            send_message(phone=phone, message=self.user_code)
            UserCode.objects.create(phone=phone, user_code=self.user_code)
            return request
        else:
            user = UserCode.objects.get(phone=phone)
            if user_sms == user.user_code:
                new_user = User.objects.get(phone=phone)
                user.delete()
                new_user.token = super().validate(request)
                return new_user
            else:
                raise serializers.ValidationError({'code': _('This user code is not True')})


class CallBackCashOutSerializer(serializers.Serializer):
    """Работа с коллбеком на выплату."""
    id = serializers.CharField(required=False)
    status = serializers.IntegerField(required=False)
    description = serializers.CharField(required=False)
    amount = serializers.IntegerField(required=False)
    commission = serializers.IntegerField(required=False)
    date = serializers.DateTimeField(required=False)
    errCode = serializers.CharField(required=False)
    errMessage = serializers.CharField(required=False, allow_blank=True)
    cardToken = serializers.CharField(required=False)
    metadata = serializers.JSONField(required=False)

    def validate(self, validated_data):
        # прислать ответ {"accepted": true}, что коллбэк принят
        FullCallbackData.objects.create(
            callback=str(validated_data),
            type_callback='Выплата'
        )
        status = validated_data.get('status')
        err_code = validated_data.pop('errCode')
        metadata = validated_data.pop('metadata')

        payment_db = PaymentData.objects.create(
            date=validated_data.pop('date'),
            id_payment=validated_data.get('id'),
            price=validated_data.pop('amount'),
            commission=validated_data.pop('commission'),
            err=validated_data.pop('errMessage'),
            err_code=err_code,
            status=status,
            type_payment=1,
            metadata=metadata
        )

        if status == 1 or status == 2:
            for order in Order.objects.filter(payment_cashout_id=metadata['id_cashout']):
                order.cash_out_status = 1
                order.save()
            payment_db.payment_status = 'Fulfilled'

        elif status == 0 and err_code == 230:
            payment_db.payment_status = 'Time out'

        elif status == 0:
            payment_db.payment_status = 'Canceled'

        payment_db.save()
        return validated_data
