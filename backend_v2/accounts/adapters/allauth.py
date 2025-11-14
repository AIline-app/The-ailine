import typing

from allauth.account.adapter import DefaultAccountAdapter

from accounts.models import User


class AccountAdapter(DefaultAccountAdapter):

    def set_phone(self, user: User, phone_number: str, verified: bool):
        user.phone_number = phone_number
        user.is_active = verified
        user.save(update_fields=["phone_number", "is_active"])

    def get_phone(self, user: User) -> typing.Optional[typing.Tuple[str, bool]]:
        if user.phone_number:
            return user.phone_number, user.is_active
        return None

    def set_phone_verified(self, user: User, phone_number: str):
        self.set_phone(user, phone_number, True)

    def send_verification_code_sms(self, user: User, phone: str, code: str, **kwargs):
        user.send_registration_code()

    def send_unknown_account_sms(self, phone_number: str, **kwargs):
        # TODO raise error?
        pass

    def send_account_already_exists_sms(self, phone_number: str, **kwargs):
        # TODO raise error?
        pass

    def get_user_by_phone(self, phone_number: str) -> typing.Optional[User]:
        return User.objects.filter(phone_number=phone_number).first()
