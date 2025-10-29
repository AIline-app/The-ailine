from rest_framework import serializers

from car_wash.models import CarTypes
from services.models import Services


class ServicesReadSerializer(serializers.ModelSerializer):
    car_type = serializers.PrimaryKeyRelatedField(many=False, read_only=True)

    class Meta:
        model = Services
        exclude = ('car_wash',)


class ServicesWriteSerializer(serializers.ModelSerializer):
    car_type = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=CarTypes.objects.none())

    class Meta:
        model = Services
        exclude = ('id', 'car_wash')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        car_wash = self.context.get('car_wash')
        if car_wash:
            self.fields['car_type'].queryset = CarTypes.objects.filter(settings__car_wash=car_wash)

    def validate(self, attrs):
        # TODO validate
        attrs['car_wash'] = self.context['car_wash']
        return attrs

    def to_representation(self, instance):
        return ServicesReadSerializer(instance, context=self.context).data


