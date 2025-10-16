import phonenumbers
from django.contrib.auth import authenticate, login
from django.db import transaction
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from rest_framework.exceptions import AuthenticationFailed

from user_auth.utils.constants import MAX_USERNAME_LENGTH, SMS_CODE_LENGTH, MIN_SMS_CODE_VALUE, MAX_SMS_CODE_VALUE
from user_auth.models.user import User
from user_auth.utils.choices import TypeSmsCode, UserRoles


class PhoneNumberValidationMixin:
    def validate_phone_number(self, phone_number):
        try:
            parsed_number = phonenumbers.parse(phone_number)
        except phonenumbers.NumberParseException:
            raise serializers.ValidationError({'phone_number': _('Incorrect phone number')})

        if not phonenumbers.is_valid_number(parsed_number):
            raise serializers.ValidationError({'phone_number': _('Incorrect phone number')})
        return phone_number


class BaseRegisterUserSerializer(serializers.Serializer):
    @staticmethod
    def get_user(phone_number):
        return User.objects.prefetch_related(
            'sms_codes',
        ).filter(
            phone_number=phone_number,
        ).first()


class RegisterUserReadSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('phone_number', 'username')


class RegisterUserWriteSerializer(PhoneNumberValidationMixin, BaseRegisterUserSerializer):
    """Сериализатор регистрации пользователя (по смс)"""
    username =  serializers.CharField(max_length=MAX_USERNAME_LENGTH)
    phone_number = serializers.CharField()
    password = serializers.CharField()
    role = serializers.CharField(default=UserRoles.CLIENT)

    def validate(self, attrs):
        if attrs['role'] not in (UserRoles.CLIENT, UserRoles.DIRECTOR):
            raise serializers.ValidationError({'role': _('Unknown role')})

        attrs['phone_number'] = User.objects.normalize_phone_number(attrs['phone_number'])

        user = self.get_user(attrs['phone_number'])

        if user and user.is_active and attrs['role'] in user.roles.all():
            raise serializers.ValidationError({'phone_number': _('This number is already registered')})

        attrs['user'] = user
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = validated_data.pop('user')
        if not user:
            user = User.objects.create_user(**validated_data)
        elif not user.is_active:
            # Set new values (user might change them between registration attempts) and delete old SMS
            user.set_password(validated_data['password'])
            user.username = validated_data['username']
            user.sms_codes.filter(type=TypeSmsCode.REGISTER).delete()
            user.save()
        else:
            # User registers with a new role. Skip SMS confirmation since already verified
            user.roles.add(validated_data['role'])
            return user

        user.send_registration_code()
        return user

    def to_representation(self, instance):
        return RegisterUserReadSerializer(instance).data


class RegisterUserConfirmWriteSerializer(PhoneNumberValidationMixin, BaseRegisterUserSerializer):
    """Сериализатор регистрации пользователя (по смс)"""
    phone_number = serializers.CharField()
    code = serializers.IntegerField()

    def validate(self, attrs):
        user = self.get_user(attrs['phone_number'])

        if not user:
            raise serializers.ValidationError({'phone_number': _('User not found')})
        if user.is_active:
            raise serializers.ValidationError({'phone_number': _('This number is already registered')})

        if not MIN_SMS_CODE_VALUE <= attrs['code'] <= MAX_SMS_CODE_VALUE:
            raise serializers.ValidationError(
                {'code': _('Must be {sms_code_length} digits').format(sms_code_length=SMS_CODE_LENGTH)}
            )

        sms = user.sms_codes.filter(code=attrs['code'], type=TypeSmsCode.REGISTER).first()
        if not sms:
            raise serializers.ValidationError({'code': _('Incorrect code')})

        if sms.expires_at < timezone.now():
            sms.delete()
            raise serializers.ValidationError({'code': _('Code has expired')})

        attrs['user'] = user
        attrs['sms'] = sms
        return attrs

    def create(self, validated_data):
        user = validated_data['user']
        sms = validated_data['sms']

        user.is_active = True
        user.save()
        login(self.context['request'], user)

        sms.delete()
        return user

    def to_representation(self, instance):
        return None


class LoginUserSerializer(serializers.ModelSerializer, PhoneNumberValidationMixin):
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

        if not user.is_active:
            raise AuthenticationFailed(_('User inactive or deleted.'))

        attrs['user'] = user
        return attrs

    def create(self, validated_data):
        login(self.context['request'], validated_data['user'])
        return validated_data['user']

    def to_representation(self, instance):
        return None