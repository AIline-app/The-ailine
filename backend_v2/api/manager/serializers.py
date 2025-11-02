from django.db import transaction

from accounts.models import User
from api.accounts.serializers import BaseRegisterUserSerializer


class ManagerWriteSerializer(BaseRegisterUserSerializer):
    def validate(self, attrs):
        attrs['user'] = self.get_user(attrs['phone_number'])
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = validated_data.pop('user')
        car_wash = validated_data.pop('car_wash')
        if not user:
            user = User.objects.create_user(**validated_data)
            user.send_manager_invitation()
        car_wash.managers.add(user)
        return user


class WasherWriteSerializer(BaseRegisterUserSerializer):
    def validate(self, attrs):
        # TODO validate
        attrs['user'] = self.get_user(attrs['phone_number'])
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = validated_data.pop('user')
        car_wash = validated_data.pop('car_wash')
        if not user:
            user = User.objects.create_user(**validated_data)
        car_wash.washers.add(user)
        return user
