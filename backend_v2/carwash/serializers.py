from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from carwash.models import Car
from carwash.models.carwash import CarWash, CarWashSettings, CarWashDocuments


class CarWashSettingsPrivateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)


class CarWashSettingsPublicSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashSettings
        fields = ('opens_at', 'closes_at')


class CarWashDocumentsPrivateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashDocuments
        exclude = ('car_wash',)


class CarWashPublicReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPublicSerializer(read_only=True)
    class Meta:
        model = CarWash
        fields = ['id', 'name', 'address', 'created_at', 'is_active', 'settings']


class CarWashPrivateReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    class Meta:
        model = CarWash
        exclude = ('owner',)


class CarWashWriteSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)

    class Meta:
        model = CarWash
        fields = ['id','owner', 'name', 'address', 'created_at', 'settings', 'documents']

    def validate(self, attrs):
        if 'is_active' in attrs:
            attrs.pop('is_active')
        # TODO validate
        return attrs

    def create(self, validated_data):
        settings_data = validated_data.pop('settings')
        documents_data = validated_data.pop('documents')
        car_wash = CarWash.objects.create(**validated_data)
        CarWashSettings.objects.create(car_wash=car_wash, **settings_data)
        CarWashDocuments.objects.create(car_wash=car_wash, **documents_data)
        return car_wash

    def update(self, instance, validated_data):
        for field in ('settings', 'documents'):
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
        fields = ['number']

    def validate(self, attrs):
        if Car.objects.filter(number=attrs['number']).exists():
            raise serializers.ValidationError({'number': _('This car already exists')})
        # TODO validate car number
        return attrs
