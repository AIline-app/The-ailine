from datetime import timedelta

from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from car_wash.models import CarType
from services.models import Services
from services.utils.constants import PRICE_MINIMUM_VALUE, CHAR_MAX_LENGTH


class ServicesReadSerializer(serializers.ModelSerializer):
    car_type = serializers.ReadOnlyField(source='car_type_id')

    class Meta:
        model = Services
        exclude = ('car_wash',)


class ServicesWriteSerializer(serializers.ModelSerializer):
    name = serializers.CharField(max_length=CHAR_MAX_LENGTH)
    description = serializers.CharField(max_length=CHAR_MAX_LENGTH)
    car_type = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=CarType.objects.all())
    price = serializers.IntegerField(min_value=PRICE_MINIMUM_VALUE)

    class Meta:
        model = Services
        exclude = ('id', 'car_wash')

    def validate(self, attrs):
        if attrs['car_type'].settings.car_wash != attrs['car_wash']:
            raise serializers.ValidationError(
                {'car_type': _('Invalid pk "{pk_value}" - object does not exist.').format(pk_value=attrs['car_type'].pk)}
            )
        if attrs['duration'] > timedelta(hours=24):
            raise serializers.ValidationError({'duration': _('Cannot exceed 24 hours')})
        return attrs

    def to_representation(self, instance):
        return ServicesReadSerializer(instance, context=self.context).data
