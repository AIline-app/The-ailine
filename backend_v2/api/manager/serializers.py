from rest_framework import serializers
from django.db import transaction
from django.utils.translation import gettext_lazy as _

from accounts.models import User
from api.accounts.serializers import BaseRegisterUserSerializer


class ManagerWriteSerializer(BaseRegisterUserSerializer):
    def validate(self, attrs):
        attrs['user'] = self.get_user(attrs['phone_number'])
        if attrs['user'] in attrs['car_wash'].managers:
            raise serializers.ValidationError({'phone_number': _('Already a manager in this car wash')})
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
        attrs['user'] = self.get_user(attrs['phone_number'])
        if attrs['user'] in attrs['car_wash'].washers:
            raise serializers.ValidationError({'phone_number': _('Already a washer in this car wash')})
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = validated_data.pop('user')
        car_wash = validated_data.pop('car_wash')
        if not user:
            user = User.objects.create_user(**validated_data)
        car_wash.washers.add(user)
        return user


class WasherEarningsReadSerializer(serializers.Serializer):

    washer = serializers.CharField()
    orders_count = serializers.IntegerField(read_only=True)
    revenue = serializers.IntegerField(read_only=True)
    earned = serializers.IntegerField(read_only=True)
    percent = serializers.IntegerField(read_only=True)
