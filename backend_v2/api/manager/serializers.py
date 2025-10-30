from django.db import transaction
from rest_framework import serializers

from api.accounts.serializers import RegisterUserWriteSerializer, UserSerializer


class ManagerWriteSerializer(serializers.Serializer):
    manager = RegisterUserWriteSerializer(many=False)

    class Meta:
        exclude = ('manager__role',)

    def validate(self, attrs):
        # TODO validate
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = self.fields['manager'].create(validated_data.pop('manager'))
        user.managed_car_wash = validated_data.pop('car_wash')
        user.save(update_fields=('managed_car_wash',))
        return user

    def to_representation(self, instance):
        return UserSerializer(instance).data
