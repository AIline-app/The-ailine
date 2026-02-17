from datetime import timedelta

from django.db import transaction
from django.db.models import Sum
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from django_attribution.decorators import conversion_events
from django_attribution.shortcuts import record_conversion

from accounts.models import User
from accounts.utils.constants import MAX_USERNAME_LENGTH
from api.accounts.serializers import UserSerializer, PhoneNumberValidationMixin, UsernameValidationMixin
from api.car_wash.serializers import CarSerializer, BoxSerializer
from api.services.serializers import ServicesReadSerializer
from car_wash.utils.constants import MAX_CAR_NUMBER_LENGTH
from orders.models import Orders
from orders.utils.enums import OrderStatus
from iLine.enums import EventEnum


class BaseOrderSerializer(serializers.ModelSerializer):
    user = UserSerializer(many=False, read_only=True)
    car = CarSerializer(many=False, read_only=True)
    services = ServicesReadSerializer(many=True, read_only=True)

    class Meta:
        model = Orders
        exclude = ('car_wash',)


class OrdersReadPrivateSerializer(BaseOrderSerializer):
    box = BoxSerializer(many=False, read_only=True)
    washer = UserSerializer(many=False, read_only=True)


class OrdersReadPublicSerializer(BaseOrderSerializer):
    class Meta:
        model = Orders
        exclude = ('car_wash', 'box', 'washer')


class OrdersReadSerializer(BaseOrderSerializer):
    def to_representation(self, instance):
        is_manager = self.context.get('is_manager')  # TODO what is going on here
        if is_manager is None:
            request = self.context.get('request')
            user = getattr(request, 'user', None)
            if user is not None:
                # Fallback check if context hint is missing
                is_manager = instance.car_wash.managers.filter(id=user.id).exists()
            else:
                is_manager = False
        if is_manager:
            return OrdersReadPrivateSerializer(instance, context=self.context).data
        return OrdersReadPublicSerializer(instance, context=self.context).data


class OrdersCreateSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())
    status = serializers.ChoiceField(choices=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE), default=OrderStatus.EN_ROUTE)

    class Meta:
        model = Orders
        fields = ('user', 'car', 'status', 'services')

    def validate(self, attrs):

        attrs['services'] = set(attrs['services'])
        if sum(map(lambda x: not x.is_extra, attrs['services'])) != 1:
            raise serializers.ValidationError({'services': _('Exactly one main service is allowed')})

        if not attrs['user'].cars.contains(attrs['car']):
            raise serializers.ValidationError({'car': _('Unknown car')})

        return attrs

    @transaction.atomic
    @conversion_events(EventEnum.ORDER_PLACED)
    def create(self, validated_data):
        services = validated_data.pop('services')
        duration = sum((service.duration for service in services), start=timedelta(0))
        order = Orders.objects.create(duration=duration, **validated_data)
        order.services.add(*services)
        record_conversion(
            self.context['request'],
            EventEnum.ORDER_PLACED,
            source_object=order,
            is_confirmed=False,
            custom_data={
                'initial_price': sum((service.price for service in services), start=0),
                'initial_duration': duration.total_seconds(),
            },
        )
        # Add order to queue if it has a car wash and is in waiting status
        # if order.car_wash and order.status in (OrderStatus.EN_ROUTE, OrderStatus.ON_SITE):
        order.car_wash.add_to_queue(order)
        return order

    def to_representation(self, instance):
        return OrdersReadSerializer(instance, context=self.context).data


class OrdersManualUserSerializer(
    PhoneNumberValidationMixin,
    UsernameValidationMixin,
    serializers.Serializer,
):
    phone_number = serializers.CharField()
    username = serializers.CharField(max_length=MAX_USERNAME_LENGTH)
    car_number = serializers.CharField(max_length=MAX_CAR_NUMBER_LENGTH)

    def validate(self, attrs):
        user = User.objects.prefetch_related('cars').filter(phone_number=attrs['phone_number']).first()
        if user:
            car = user.cars.get_or_create(number=attrs['car_number'])[0]
        else:
            user = User.objects.create_user(username=attrs['username'], phone_number=attrs['phone_number'])
            car = user.cars.create(number=attrs['car_number'])

        attrs['user'] = user
        attrs['car'] = car
        return attrs


class OrdersManualCreateSerializer(OrdersCreateSerializer):
    client_info = OrdersManualUserSerializer()

    class Meta:
        model = Orders
        fields = ('user', 'client_info', 'status', 'services')


    def validate(self, attrs):
        client_info = attrs.pop('client_info')
        attrs['user'] = client_info['user']
        attrs['car'] = client_info['car']
        return super().validate(attrs)


class OrdersStartSerializer(serializers.ModelSerializer):
    class Meta:
        model = Orders
        fields = ('id', 'box', 'washer')

    def validate(self, attrs):
        if self.instance.status in (OrderStatus.CANCELED, OrderStatus.COMPLETED):
            raise serializers.ValidationError({'id': _('Order already executed')})
        if self.instance.status in (OrderStatus.IN_PROGRESS,):
            raise serializers.ValidationError({'id': _('Order already in progress')})
        return attrs

    def validate_washer(self, washer):
        if not self.instance.car_wash.washers.contains(washer):
            raise serializers.ValidationError(_('Unknown washer'))

        if self.instance.car_wash.orders.filter(washer=washer, status=OrderStatus.IN_PROGRESS).exists():
            raise serializers.ValidationError(_('Washer already has an order in progress'))

        return washer

    def validate_box(self, box):
        if not self.instance.car_wash.boxes.contains(box):
            raise serializers.ValidationError(_('Unknown box'))

        if self.instance.car_wash.orders.filter(box=box, status=OrderStatus.IN_PROGRESS).exists():
            raise serializers.ValidationError(_('Box already has an order in progress'))

        return box


    @conversion_events(EventEnum.ORDER_STARTED)
    def update(self, instance, validated_data):
        instance.status = OrderStatus.IN_PROGRESS
        instance.box = validated_data['box']
        instance.washer = validated_data['washer']
        instance.started_at = now()
        instance.total_price = instance.services.aggregate(Sum('price'))['price__sum']  # TODO check if no services exists
        instance.save(update_fields=['status', 'box', 'washer', 'total_price', 'started_at'])
        # Remove from queue when order starts
        instance.car_wash.remove_from_queue(instance)
        # Track conversion for order start
        request = self.context.get('request')
        if request is not None:
            record_conversion(
                request,
                EventEnum.ORDER_STARTED,
                source_object=instance,
                is_confirmed=True,
                custom_data={
                    'box_id': str(instance.box_id) if instance.box_id else None,
                    'washer_id': str(instance.washer_id) if instance.washer_id else None,
                    'started_at': instance.started_at.isoformat() if instance.started_at else None,
                    'total_price': instance.total_price,
                },
            )
        return instance

    def to_representation(self, instance):
        return OrdersReadSerializer(instance, context=self.context).data


class OrdersFinishSerializer(serializers.ModelSerializer):
    class Meta:
        model = Orders
        fields = ('id',)

    def validate(self, attrs):
        if self.instance.status != OrderStatus.IN_PROGRESS:
            raise serializers.ValidationError({'id': _('Order is not in progress')})
        return attrs

    @conversion_events(EventEnum.ORDER_COMPLETED)
    def update(self, instance, validated_data):
        instance.status = OrderStatus.COMPLETED
        instance.finished_at = now()
        instance.save(update_fields=['status', 'finished_at'])
        # Track conversion for order completion
        request = self.context.get('request')
        if request is not None:
            duration_seconds = None
            if instance.started_at and instance.finished_at:
                duration_seconds = int((instance.finished_at - instance.started_at).total_seconds())
            record_conversion(
                request,
                EventEnum.ORDER_COMPLETED,
                source_object=instance,
                is_confirmed=True,
                custom_data={
                    'finished_at': instance.finished_at.isoformat() if instance.finished_at else None,
                    'started_at': instance.started_at.isoformat() if instance.started_at else None,
                    'duration_seconds': duration_seconds,
                    'total_price': instance.total_price,
                },
            )
        return instance

    def to_representation(self, instance):
        return OrdersReadSerializer(instance, context=self.context).data


class OrdersUpdateServicesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Orders
        fields = ('id', 'services')

    def validate_services(self, services):
        """Validate that all services belong to the car wash."""
        # if 'car_wash' in self.context:
        services = set(services)

        valid_services = self.context['car_wash'].services
        if any(not valid_services.contains(service) for service in services):  # TODO optimize
            raise serializers.ValidationError({'services': _('All services must belong to this car wash')})

        if sum(map(lambda x: not x.is_extra, services)) != 1:
            raise serializers.ValidationError({'services': _('Exactly one main service is allowed')})

        return services

    def validate(self, attrs):
        if self.instance.status in (OrderStatus.IN_PROGRESS, OrderStatus.COMPLETED, OrderStatus.CANCELED):
            raise serializers.ValidationError({'id': _('Order is either in progress or executed')})
        return attrs

    @conversion_events(EventEnum.ORDER_SERVICES_UPDATED)
    def update(self, instance, validated_data):
        # capture before state
        request = self.context.get('request')
        before_services = list(instance.services.values_list('id', flat=True))
        before_price = instance.services.aggregate(Sum('price'))['price__sum'] or 0
        # apply update
        instance.services.set(validated_data['services'])
        # recalculate duration to equal sum of service durations
        duration = sum((service.duration for service in instance.services.all()), start=timedelta(0))
        instance.duration = duration
        instance.save(update_fields=['duration'])
        instance.car_wash.recalculate_queue()
        # recalc total prospective price if already started (total_price is set on start)
        after_services = list(instance.services.values_list('id', flat=True))
        after_price = instance.services.aggregate(Sum('price'))['price__sum'] or 0
        if request is not None:
            record_conversion(
                request,
                EventEnum.ORDER_SERVICES_UPDATED,
                source_object=instance,
                is_confirmed=True,
                custom_data={
                    'before_services': [str(s) for s in before_services],
                    'after_services': [str(s) for s in after_services],
                    'price_delta': (after_price - before_price),
                    'before_price': before_price,
                    'after_price': after_price,
                    'after_duration_seconds': int(duration.total_seconds()),
                },
            )
        return instance

    def to_representation(self, instance):
        return OrdersReadSerializer(instance, context=self.context).data
