from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from accounts.models import User
from api.accounts.serializers import RegisterUserWriteSerializer


class ManagerReadSerializer(serializers.ModelSerializer):
    managed_car_wash = serializers.ReadOnlyField(source='car_wash_id')

    class Meta:
        model = User
        fields = ['id', 'username', 'phone_number', 'created_at', 'managed_car_wash']


class ManagerWriteSerializer(serializers.Serializer):
    manager = RegisterUserWriteSerializer(many=False)

    def validate(self, attrs):
        # TODO validate
        return attrs

    def create(self, validated_data):
        user = self.fields['manager'].create(validated_data.pop('manager'))
        user.managed_car_wash = validated_data.pop('car_wash')
        user.save(update_fields=('managed_car_wash',))
        return user

    def to_representation(self, instance):
        return ManagerReadSerializer(instance).data
