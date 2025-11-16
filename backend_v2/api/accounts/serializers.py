import phonenumbers
from django.contrib.auth import authenticate, login
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from rest_framework.exceptions import AuthenticationFailed

from accounts.utils.constants import MAX_USERNAME_LENGTH, MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE
from accounts.models import User
from accounts.utils.enums import TypeSmsCode


class PhoneNumberValidationMixin:
    def validate_phone_number(self, phone_number):
        # try:
        #     parsed_number = phonenumbers.parse(phone_number)
        # except phonenumbers.NumberParseException:
        #     raise serializers.ValidationError({'phone_number': _('Incorrect phone number')})
        #
        # if not phonenumbers.is_valid_number(parsed_number):
        #     raise serializers.ValidationError({'phone_number': _('Incorrect phone number')})
        return User.objects.normalize_phone_number(phone_number)


class RegisterUserSerializerMixin:
    @staticmethod
    def get_user(phone_number):
        return User.objects.prefetch_related(
            'sms_codes',
        ).filter(
            phone_number=phone_number,
        ).first()

    def to_representation(self, instance):
        return UserSerializer(instance).data


class ExceptionSerializer(serializers.Serializer):
    detail = serializers.CharField()


class BaseRegisterUserSerializer(PhoneNumberValidationMixin, RegisterUserSerializerMixin, serializers.Serializer):
    phone_number = serializers.CharField()
    username =  serializers.CharField(max_length=MAX_USERNAME_LENGTH)
    password = serializers.CharField()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'phone_number', 'created_at']


class RegisterUserWriteSerializer(BaseRegisterUserSerializer):
    """Сериализатор регистрации пользователя (по смс)"""
    def validate(self, attrs):
        user = self.get_user(attrs['phone_number'])

        if user and user.is_active:
            raise serializers.ValidationError({'phone_number': _('This number is already registered')})

        attrs['user'] = user
        return attrs

    def create(self, validated_data):
        user = validated_data.pop('user')
        if not user:
            user = User.objects.create_user(**validated_data)
        else:
            # Set new values (user might change them between registration attempts) and delete old SMS
            user.set_password(validated_data['password'])
            user.name = validated_data['username']
            user.sms_codes.filter(type=TypeSmsCode.REGISTER).delete()  # TODO don't delete, set as invalid
            user.save()

        user.send_registration_code()
        return user


class RegisterUserConfirmWriteSerializer(PhoneNumberValidationMixin, RegisterUserSerializerMixin, serializers.Serializer):
    """Сериализатор регистрации пользователя (по смс)"""
    phone_number = serializers.CharField()
    code = serializers.IntegerField(min_value=MIN_SMS_CODE_VALUE, max_value=MAX_SMS_CODE_VALUE)

    def validate(self, attrs):
        user = self.get_user(attrs['phone_number'])

        if not user:
            raise serializers.ValidationError({'phone_number': _('User not found')})
        if user.is_active:
            raise serializers.ValidationError({'phone_number': _('This number is already registered')})

        sms = user.sms_codes.filter(code=attrs['code'], type=TypeSmsCode.REGISTER).first()
        if not sms:
            raise serializers.ValidationError({'code': _('Incorrect code')})

        if sms.expires_at < timezone.now():
            # sms.delete()
            raise serializers.ValidationError({'code': _('Code has expired')})

        attrs['user'] = user
        attrs['sms'] = sms
        return attrs

    def create(self, validated_data):
        user = validated_data['user']
        sms = validated_data['sms']

        user.is_verified = True
        user.save(update_fields=['is_active'])
        login(self.context['request'], user)

        sms.delete()
        return user


class LoginUserSerializer(PhoneNumberValidationMixin, serializers.ModelSerializer):
    """Сериализатор аутентификации пользователя по телефону и паролю"""
    phone_number = serializers.CharField()

    class Meta:
        model = User
        fields = ['phone_number', 'password']

    def validate(self, attrs):
        """
        Authenticate the userid and password against username and password
        with optional request for context.
        """
        user = authenticate(request=self.context['request'], **attrs)

        if user is None:
            raise AuthenticationFailed(_('Invalid username/password.'))

        if not user.is_verified:
            raise AuthenticationFailed(_('User inactive or deleted.'))

        attrs['user'] = user
        return attrs

    def create(self, validated_data):
        login(self.context['request'], validated_data['user'])
        return validated_data['user']

    def to_representation(self, instance):
        return UserSerializer(instance).data
