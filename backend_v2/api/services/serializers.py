from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

from car_wash.models import CarTypes
from services.models import Services
from services.utils.constants import PRICE_MINIMUM_VALUE


class ServicesReadSerializer(serializers.ModelSerializer):
    car_type = serializers.ReadOnlyField(source='car_type_id')

    class Meta:
        model = Services
        exclude = ('car_wash',)


class ServicesWriteSerializer(serializers.ModelSerializer):
    car_type = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=CarTypes.objects.all())
    price = serializers.IntegerField(min_value=PRICE_MINIMUM_VALUE)

    class Meta:
        model = Services
        exclude = ('id', 'car_wash')

    def validate(self, attrs):
        # TODO validate
        if attrs['car_type'].settings.car_wash != self.context['car_wash']:
            raise ValidationError(
                {'car_type': _('Invalid pk "{pk_value}" - object does not exist.').format(pk_value=attrs['car_type'].pk)}
            )
        return attrs

    def to_representation(self, instance):
        return ServicesReadSerializer(instance, context=self.context).data
