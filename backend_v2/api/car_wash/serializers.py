from datetime import timedelta

from django.db import transaction
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarTypes
from orders.models import Orders
from orders.utils.enums import OrderStatus


class CarWashCarTypesSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarTypes
        exclude = ('settings',)


class CarWashSettingsPrivateSerializer(serializers.ModelSerializer):
    car_types = CarWashCarTypesSerializer(many=True, read_only=False)
    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)


class CarWashSettingsPublicSerializer(serializers.ModelSerializer):
    car_types = CarWashCarTypesSerializer(many=True, read_only=True)
    class Meta:
        model = CarWashSettings
        fields = ('opens_at', 'closes_at', 'car_types')


class CarWashDocumentsPrivateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashDocuments
        exclude = ('car_wash',)


class CarWashPublicReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPublicSerializer(read_only=True)
    class Meta:
        model = CarWash
        fields = ('id', 'name', 'address', 'created_at', 'is_active', 'settings')


class CarWashPrivateReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    class Meta:
        model = CarWash
        exclude = ('owner',)


class CarWashReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    boxes_amount = serializers.IntegerField()

    class Meta:
        model = CarWash
        fields = ('id', 'name', 'address', 'created_at', 'settings', 'documents', 'boxes_amount')

    def to_representation(self, instance):
        if instance.owner == self.context['request'].user:
            return CarWashPrivateReadSerializer(instance).data
        return CarWashPublicReadSerializer(instance).data


class CarWashWriteSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    boxes_amount = serializers.IntegerField()

    class Meta:
        model = CarWash
        fields = ('id', 'name', 'address', 'created_at', 'settings', 'documents', 'boxes_amount')

    def validate(self, attrs):
        if 'is_active' in attrs:
            attrs.pop('is_active')
        # TODO validate
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        settings_data = validated_data.pop('settings')
        documents_data = validated_data.pop('documents')
        boxes_amount = validated_data.pop('boxes_amount')

        car_wash = super().create(validated_data)
        car_wash.create_settings(settings_data)
        car_wash.create_documents(documents_data)
        car_wash.create_boxes(boxes_amount)

        return car_wash

    @transaction.atomic
    def update(self, instance, validated_data):
        for field in ('settings', 'documents'):
            if field in validated_data:
                data = validated_data.pop(field)

                if 'car_types' in data:
                    car_types = data.pop('car_types')
                    instance.update_car_types(car_types)

                obj = getattr(instance, field)
                for k, v in data.items():
                    setattr(obj, k, v)
                obj.save()
        if 'boxes_amount' in validated_data:
            boxes_amount = validated_data.pop('boxes_amount')

        return super().update(instance, validated_data)

    def to_representation(self, instance):
        return CarWashReadSerializer(instance, context=self.context).data


class CarWashQueueSerializer(serializers.Serializer):
    wait_time = serializers.DurationField(read_only=True)
    car_amount = serializers.IntegerField(read_only=True)

    def create(self, validated_data):
        car_wash = self.get_car_wash(validated_data.pop('car_wash_id'))
        boxes_amount = car_wash.boxes.count()

        orders = self.get_orders_query(car_wash)

        combined_duration = self.get_total_duration(orders)
        return {'wait_time': combined_duration/boxes_amount, 'car_amount': len(orders)}

    def get_car_wash(self, car_wash_id):
        return CarWash.objects.prefetch_related('boxes').filter(id=car_wash_id).first()

    def get_orders_query(self, car_wash, *args, **kwargs):
        query = Orders.objects.prefetch_related(
            'services',
        ).filter(
            car_wash=car_wash,
            status__in=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE),
        )
        return query

    def get_total_duration(self, orders):
        return sum(
            (
                sum(
                    (service.duration for service in order.services.all()),
                    timedelta(0)
                ) for order in orders
            ),
            timedelta(0)
        )

class CarSerializer(serializers.ModelSerializer):
    class Meta:
        model = Car
        fields = ('id', 'number')

    def validate(self, attrs):
        if Car.objects.filter(number=attrs['number']).exists():
            raise serializers.ValidationError({'number': _('This car already exists')})
        # TODO validate car number
        return attrs


class BoxSerializer(serializers.ModelSerializer):
    class Meta:
        model = Box
        exclude = ('car_wash',)
