import phonenumbers
from allauth.account.adapter import get_adapter
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


class UsernameValidationMixin:
    def validate_username(self, username):
        return get_adapter().clean_username(username)


class BaseRegisterUserSerializer(
    PhoneNumberValidationMixin,
    UsernameValidationMixin,
    serializers.Serializer,
):

    phone_number = serializers.CharField()
    username = serializers.CharField(max_length=MAX_USERNAME_LENGTH)
    password = serializers.CharField()

    @staticmethod
    def get_user(phone_number):
        return get_adapter().get_user_by_phone(phone_number)

    def to_representation(self, instance):

        return UserSerializer(instance, context=self.context).data


class UserSerializer(serializers.ModelSerializer):

    class Meta:

        model = User
        fields = ('id', 'username', 'phone_number', 'created_at')
