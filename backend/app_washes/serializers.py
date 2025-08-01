import base64

from django.core.files.base import ContentFile
from django.db import transaction
from django.db.models import F, Sum, ExpressionWrapper, DecimalField
from django.utils import timezone
from rest_framework import serializers
from decimal import Decimal

from app_users.models import User, BankCard
from app_washes.models import Administrator, CarWash, CarWashCoordinates, Service, Washer
from app_adminwork.models import SlotsInWash
from app_orders.models import Order, WasherEarning


class Base64ImageField(serializers.ImageField):
    """Обработка картинок в base64. На вход поступает словарь с именем, расширением, строкой и размеромм."""
    def to_internal_value(self, data):
        data = ContentFile(
            base64.b64decode(data["base64"]),
            name=f'{data["name"]}{data["ext"]}',
        )

        return super().to_internal_value(data)


class ServiceCreateSerializer(serializers.ModelSerializer):  # todo через json
    """Сериализатор создания услуги"""

    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = Service
        fields = '__all__'

    def create(self, validated_data):
        user_data = validated_data.pop('user', [])
        wash_data = validated_data.pop('wash', [])
        wash = CarWash.objects.filter(user=user_data, id=wash_data.id).first()
        return Service.objects.create(**validated_data, wash=wash)


class ServiceDetailSerializer(serializers.ModelSerializer):
    """Сериализатор услуги"""

    class Meta:
        model = Service
        fields = '__all__'


class AdministratorDetailSerializer(serializers.ModelSerializer):
    """Информация об администраторе автомойки"""

    class Meta:
        model = Administrator
        fields = ['id', 'phone']


class WasherDetailSerializer(serializers.ModelSerializer):
    """Информация об мойщике автомойки"""

    class Meta:
        model = Washer
        fields = ['id', 'name', 'phone']


class WasherCreateSerializer(serializers.ModelSerializer):
    """Создание мойщика"""

    class Meta:
        model = Washer
        fields = '__all__'


class WasherStatsSerializer(serializers.ModelSerializer):
    """Статистика мойщиков одной мойки"""
    count_order    = serializers.SerializerMethodField()
    total_earnings = serializers.SerializerMethodField()

    class Meta:
        model  = Washer
        fields = ("id", "name", "phone", "count_order", "total_earnings")

    def get_count_order(self, washer):
        return WasherEarning.objects.filter(
            washer=washer,
            date__gte=self.context['start_date'],
            date__lte=self.context['end_date'],
        ).count()

    def get_total_earnings(self, washer):
        agg = WasherEarning.objects.filter(
            washer=washer,
            date__gte=self.context['start_date'],
            date__lte=self.context['end_date'],
        ).aggregate(total=Sum('earnings'))
        return agg['total'] or Decimal('0')


class DateRangeSerializer(serializers.Serializer):
    """Принимает start_date и end_date в POST."""
    start_date = serializers.DateField()
    end_date   = serializers.DateField()

    def validate(self, data):
        if data['start_date'] > data['end_date']:
            raise serializers.ValidationError("start_date не может быть позже end_date")
        return data


class CarWashAdminSerializer(serializers.ModelSerializer):
    """Список администраторов мойки"""
    wash_admin = AdministratorDetailSerializer(many=True)

    class Meta:
        model = CarWash
        fields = ['id', 'title', 'wash_admin']


class AdministratorCreateSerializer(serializers.ModelSerializer):
    """Сериализатор добавления администратора"""
    user = serializers.HiddenField(read_only=False, default=serializers.CurrentUserDefault())
    wash = serializers.PrimaryKeyRelatedField(queryset=CarWash.objects.all(), many=True)

    class Meta:
        model = Administrator
        fields = '__all__'

    def create(self, validated_data):
        user = validated_data.pop('user')
        wash = validated_data.pop('wash')[0]
        wash_object = CarWash.objects.get(id=wash.id, user=user)
        if wash_object.wash_admin.count() > 0:
            raise ValueError('Admin is already exists!')
        admin = Administrator.objects.create(**validated_data)
        if user.phone != wash_object.user.phone:
            raise ValueError('Customer cannot be a admin!')
        for user in User.objects.all():
            if user.phone == admin.phone:
                user_db = User.objects.get(pk=user.id)
                user_db.role = 'light_manager'
                user_db.save()
        if wash_object.user.user_card.count() > 0:
            wash_object.is_validate = True
            wash_object.save()
        admin.wash.add(wash_object)

        return admin


class AdministratorListSerializer(serializers.ModelSerializer):
    """Список администраторов (по всем автомойкам)"""
    car_wash = CarWashAdminSerializer(many=True)

    class Meta:
        model = User
        fields = ['car_wash']


class WashCoordinatesSerializer(serializers.ModelSerializer):
    """Сериализатор координат автомойки"""

    class Meta:
        model = CarWashCoordinates
        fields = ['latitude', 'longitude']


class WashListSerializer(serializers.ModelSerializer):
    """Сериализатор списка автомоек"""
    wash_coordinates = WashCoordinatesSerializer(required=False)

    class Meta:
        model = CarWash
        fields = ['id', 'title', 'img', 'wash_coordinates']


class RegisterCarWashSerializer(serializers.ModelSerializer):
    """Сериализатор регистрации автомойки"""

    user = serializers.HiddenField(read_only=False, default=serializers.CurrentUserDefault())
    service = ServiceDetailSerializer(many=True, required=False)
    wash_coordinates = WashCoordinatesSerializer(required=False)
    img = Base64ImageField(required=False, allow_null=True)
    count_orders = serializers.SerializerMethodField()

    class Meta:
        model = CarWash
        exclude = ['date_create', 'soft_delete']

    @transaction.atomic
    def create(self, validated_data):
        service_list = list()
        service_data = validated_data.pop('service', [])
        coordinates = validated_data.pop('wash_coordinates', [])
        slots = validated_data.get('slots')
        new_wash = CarWash.objects.create(**validated_data)

        for service in service_data:
            service_list.append(
                Service(
                    wash=new_wash,
                    title=service['title'],
                    type_auto=service['type_auto'],
                    price=service['price'],
                    time_work=service['time_work'],
                    extra=service['extra']
                )
            )
        Service.objects.bulk_create(service_list)
        for _ in range(slots):
            SlotsInWash.objects.create(wash=new_wash)
        if len(coordinates) == 2:
            CarWashCoordinates.objects.create(
                wash=new_wash, longitude=coordinates['longitude'],
                latitude=coordinates['latitude']
            )
        user = User.objects.get(id=new_wash.user_id)
        if user.role == 'light_partner':
            user.role = 'partner'
        user.save()
        new_wash.last_time = timezone.now()
        new_wash.save()

        return new_wash

    @transaction.atomic
    def get_count_orders(self, validated_data):
        return len(Order.objects.filter(car_wash_id=validated_data.id, status='Reserve'))


class CarWashSerializer(serializers.ModelSerializer):
    """Сериализатор данных автомойки"""
    service = ServiceDetailSerializer(many=True, required=False)
    wash_coordinates = WashCoordinatesSerializer(required=False)
    img = Base64ImageField(required=False, allow_null=True)
    count_orders = serializers.SerializerMethodField(required=False)

    class Meta:
        model = CarWash
        exclude = ['soft_delete']

    @transaction.atomic
    def update(self, instance, validated_data):
        validated_data.pop('service', [])
        instance.slots = validated_data.pop('slots', None)
        coordinates = validated_data.pop('wash_coordinates')
        instance.is_active = validated_data.pop('is_active', instance.is_active)
        wash = CarWash.objects.get(id=instance.id)
        if instance.slots > wash.slots:
            diff = instance.slots - wash.slots
            for _ in range(diff):
                SlotsInWash.objects.create(wash=wash)
        if instance.slots < wash.slots:
            diff = wash.slots - instance.slots
            for number in range(diff - 1, -1, -1):
                SlotsInWash.objects.filter(wash=wash).only('id')[number].delete()

        instance.wash_coordinates.latitude = coordinates['latitude']
        instance.wash_coordinates.longitude = coordinates['longitude']
        coordinate = CarWashCoordinates.objects.get(wash_id=wash.id)
        coordinate.latitude = coordinates['latitude']
        coordinate.longitude = coordinates['longitude']
        coordinate.save()
        instance = super().update(instance, validated_data)

        return instance

    @transaction.atomic
    def get_count_orders(self, validated_data):
        return len(Order.objects.filter(car_wash_id=validated_data.id, status='Reserve').only('car_wash_id', 'status'))
