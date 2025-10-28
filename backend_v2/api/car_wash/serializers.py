from django.db import transaction
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarTypes


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
        # TODO support car_types inside settings
        for field in ('settings', 'documents', 'boxes_amount'):
            if field in validated_data:
                data = validated_data.pop(field)
                obj = getattr(instance, field)
                for k, v in data.items():
                    setattr(obj, k, v)
                obj.save()
        return super().update(instance, validated_data)

    def to_representation(self, instance):
        if instance.owner == self.context['request'].user:
            return CarWashPrivateReadSerializer(instance).data
        return CarWashPublicReadSerializer(instance).data

class CarSerializer(serializers.ModelSerializer):
    class Meta:
        model = Car
        fields = ('number',)

    def validate(self, attrs):
        if Car.objects.filter(number=attrs['number']).exists():
            raise serializers.ValidationError({'number': _('This car already exists')})
        # TODO validate car number
        return attrs


class BoxSerializer(serializers.ModelSerializer):
    class Meta:
        model = Box
        exclude = ('car_wash',)
