import phonenumbers
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from accounts.models import User
from accounts.utils.constants import MAX_USERNAME_LENGTH


class PhoneNumberValidationMixin:
    def validate_phone_number(self, phone_number):
        try:
            parsed_number = phonenumbers.parse(phone_number)
        except phonenumbers.NumberParseException:
            raise serializers.ValidationError({'phone_number': _('Incorrect phone number')})

        if not phonenumbers.is_valid_number(parsed_number):
            raise serializers.ValidationError({'phone_number': _('Incorrect phone number')})
        return User.objects.normalize_phone_number(phone_number)


class RegisterUserSerializerMixin:
    @staticmethod
    def get_user(phone_number):
        return User.objects.filter(
            phone_number=phone_number,
        ).first()

    def to_representation(self, instance):
        return UserSerializer(instance).data


class BaseRegisterUserSerializer(PhoneNumberValidationMixin, RegisterUserSerializerMixin, serializers.Serializer):
    phone_number = serializers.CharField()
    username =  serializers.CharField(max_length=MAX_USERNAME_LENGTH)
    password = serializers.CharField()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'phone_number', 'created_at']
