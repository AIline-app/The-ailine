from django.db import transaction
from django.db.models import Sum, Count
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarType
from car_wash.utils.constants import MAX_CAR_NUMBER_LENGTH, MIN_CAR_NUMBER_LENGTH
from orders.utils.enums import OrderStatus


class BoxSerializer(serializers.ModelSerializer):

    class Meta:
        model = Box
        exclude = ('car_wash',)


class CarWashCarTypesSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarType
        exclude = ('settings',)


class CarWashSettingsPrivateSerializer(serializers.ModelSerializer):

    car_types = CarWashCarTypesSerializer(many=True, read_only=False)

    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)

    def validate(self, attrs):

        if attrs['opens_at'] >= attrs['closes_at']:
            raise serializers.ValidationError({'opens_at': _('Must be earlier than closes_at')})

        return attrs


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

    settings = CarWashSettingsPublicSerializer(many=False)

    class Meta:

        model = CarWash
        fields = ('id', 'name', 'address', 'location', 'created_at', 'is_active', 'settings')
        read_only_fields = fields


class CarWashPrivateReadSerializer(CarWashPublicReadSerializer):

    documents = CarWashDocumentsPrivateSerializer(many=False)
    boxes = BoxSerializer(many=True)

    class Meta(CarWashPublicReadSerializer.Meta):

        fields = CarWashPublicReadSerializer.Meta.fields + (
            'documents',
            'boxes',
            'managers',
            'washers',
        )


class CarWashReadSerializer(serializers.Serializer):

    def to_representation(self, instance):

        serializer = CarWashPublicReadSerializer
        if instance.owner == self.context['request'].user:
            serializer = CarWashPrivateReadSerializer

        return serializer(instance, context=self.context).data


class CarWashChangeSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarWash
        fields = ('name', 'address', 'location')

    def to_representation(self, instance):
        return CarWashReadSerializer(instance, context=self.context).data


class CarWashWriteSerializer(CarWashChangeSerializer):

    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    boxes_amount = serializers.IntegerField()

    class Meta(CarWashChangeSerializer.Meta):

        fields = CarWashChangeSerializer.Meta.fields + ('settings', 'documents', 'boxes_amount')

    def validate_location(self, value):
        try:
            lat, long = value.split(',')
            lat, long = float(lat), float(long)
        except ValueError:
            raise serializers.ValidationError({'location': _('Must be in format "11.1111,22.2222"')})

        if not -90 <= lat <= 90:
            raise serializers.ValidationError({'location': _('Latitude must be between -90 and 90')})
        if not -90 <= long <= 90:
            raise serializers.ValidationError({'location': _('Longitude must be between -90 and 90')})

        return value

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


class CarWashEarningsByCarTypesReadSerializer(serializers.Serializer):

    car_type = serializers.CharField(read_only=True)
    orders_count = serializers.IntegerField(read_only=True)


class CarWashEarningsReadSerializer(serializers.Serializer):

    revenue = serializers.IntegerField(read_only=True)
    orders_count = serializers.IntegerField(read_only=True)
    by_car_types = CarWashEarningsByCarTypesReadSerializer(many=True, read_only=True)


class CarSerializer(serializers.ModelSerializer):
    number = serializers.CharField(min_length=MIN_CAR_NUMBER_LENGTH, max_length=MAX_CAR_NUMBER_LENGTH)

    class Meta:
        model = Car
        fields = ('id', 'number')

    def validate(self, attrs):
        if Car.objects.filter(number=attrs['number']).exists():
            raise serializers.ValidationError({'number': _('This car already exists')})

        if not attrs['number'].isalnum():
            raise serializers.ValidationError({'number': _('Must contain only alphanumeric')})

        attrs['number'] = attrs['number'].upper()
        return attrs
