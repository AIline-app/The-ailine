import dataclasses
import typing
import uuid

from allauth.account.adapter import DefaultAccountAdapter
from allauth.headless.adapter import DefaultHeadlessAdapter
from allauth.core.internal.cryptokit import generate_user_code
from allauth.account import app_settings
from django_attribution.decorators import conversion_events
from django_attribution.shortcuts import record_conversion

from accounts.models import User
from iLine.enums import EventEnum


class AccountAdapter(DefaultAccountAdapter):
    @conversion_events(EventEnum.REGISTER)
    def save_user(self, request, user, form, commit=True):
        user = super().save_user(request, user, form, commit=False)
        record_conversion(request, EventEnum.REGISTER)
        return user

    def generate_phone_verification_code(self, *, user, phone: str) -> str:
        return generate_user_code(length=4)

    def set_phone(self, user: User, phone_number: str, verified: bool):
        user.phone_number = phone_number
        user.is_verified = verified
        user.save(update_fields=["phone_number", "is_verified"])

    def get_phone(self, user: User) -> typing.Optional[typing.Tuple[str, bool]]:
        if user.phone_number:
            return user.phone_number, user.is_verified
        return None

    @conversion_events(EventEnum.VERIFIED_PHONE)
    def set_phone_verified(self, user: User, phone_number: str):
        self.set_phone(user, phone_number, True)
        record_conversion(self.request, EventEnum.VERIFIED_PHONE)

    @conversion_events(EventEnum.SEND_REGISTER_SMS)
    def send_verification_code_sms(self, user: User, phone: str, code: str, **kwargs):
        user.send_registration_code(code=code)
        record_conversion(self.request, EventEnum.SEND_REGISTER_SMS)

    def send_unknown_account_sms(self, phone_number: str, **kwargs):
        # TODO raise error?
        pass

    def send_account_already_exists_sms(self, phone_number: str, **kwargs):
        # TODO raise error?
        pass

    def get_user_by_phone(self, phone_number: str) -> typing.Optional[User]:
        return User.objects.filter(phone_number=phone_number).first()

    def clean_username(self, username, shallow=False):
        """
        Validates the username. You can hook into this if you want to
        (dynamically) restrict what usernames can be chosen.
        """
        for validator in app_settings.USERNAME_VALIDATORS:
            validator(username)

        username_blacklist_lower = [
            ub.lower() for ub in app_settings.USERNAME_BLACKLIST
        ]
        if username.lower() in username_blacklist_lower:
            raise self.validation_error("username_blacklisted")
        # Uniqueness check was removed
        return username


class HeadlessAdapter(DefaultHeadlessAdapter):
    def get_user_dataclass(self):
        fields = []
        id_type = str
        id_example = str(uuid.uuid4())

        def dc_field(attr, typ, description, example):
            return (
                attr,
                typ,
                dataclasses.field(
                    metadata={
                        "description": description,
                        "example": example,
                    }
                ),
            )

        fields.extend(
            [
                dc_field("id", id_type, "The user ID.", id_example),
                dc_field(
                    "username", str, "The display name for the user.", "Magic Wizard"
                ),
                dc_field(
                    "phone_number", typing.Optional[str], "The phone number.", "+77771234567"
                ),
                dc_field(
                    "has_usable_password",
                    bool,
                    "Whether or not the account has a password set.",
                    True,
                ),
            ]
        )
        return dataclasses.make_dataclass("User", fields)

    def user_as_dataclass(self, user):
        UserDc = self.get_user_dataclass()
        kwargs = {}
        kwargs.update(
            {
                "id": str(user.pk),
                "phone_number": str(user.phone_number),
                "username": str(user.username),
                "has_usable_password": user.has_usable_password(),
            }
        )
        return UserDc(**kwargs)
