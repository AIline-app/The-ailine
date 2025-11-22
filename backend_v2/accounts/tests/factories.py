from django.test import override_settings
from rest_framework.test import APIClient
from unittest.mock import patch

from accounts.models.user import User


DEFAULT_PASSWORD = "S3cureP@ssw0rd"


ALLOAUTH_CONFIG_URL = "/_allauth/browser/v1/config"
ALLOAUTH_LOGIN_PATH = "/_allauth/browser/v1/auth/login"
ALLOAUTH_LOGOUT_PATH = "/_allauth/browser/v1/auth/session"
ALLOAUTH_SIGNUP_PATH = "/_allauth/browser/v1/auth/signup"
ALLOAUTH_PHONE_VERIFY_PATH = "/_allauth/browser/v1/auth/phone/verify"


def _prepare_csrf(client: APIClient) -> str:
    resp = client.get(ALLOAUTH_CONFIG_URL)
    csrftoken = resp.cookies.get('csrftoken')
    if csrftoken:
        client.cookies['csrftoken'] = csrftoken.value if hasattr(csrftoken, 'value') else csrftoken
        return client.cookies['csrftoken']
    return ""


def create_inactive_user(*, username: str, phone_number: str, password: str = DEFAULT_PASSWORD) -> User:
    """Create a user with is_active=True but not verified (business inactive)."""
    user = User.objects.create_user(
        username=username,
        phone_number=phone_number,
        password=password,
    )
    if user.is_verified:
        user.is_verified = False
        user.save(update_fields=["is_verified"])
    return user


def create_active_user(*, username: str, phone_number: str, password: str = DEFAULT_PASSWORD) -> User:
    """Create a user and mark phone as verified."""
    user = create_inactive_user(username=username, phone_number=phone_number, password=password)
    if not user.is_verified:
        user.is_verified = True
        user.save(update_fields=["is_verified"])
    return user

@override_settings(
    ACCOUNT_RATE_LIMITS=False,
    HEADLESS_RATE_LIMITS=False,
    RATE_LIMITS=False,
)
def register_user_and_get_sms(
    client: APIClient,
    *,
    username: str,
    phone_number: str,
    password: str = DEFAULT_PASSWORD,
):
    """Register via allauth headless (phone-based). Returns (response, user, code)."""
    # Obtain CSRF and cookie
    _prepare_csrf(client)
    payload = {
        "phone": phone_number,
        "password": password,
        "username": username,
    }
    captured = {"code": None}

    def _capture(user, phone, code, **kwargs):
        captured["code"] = code
        # do nothing else

    # Patch the SMS send to capture the code that allauth generated
    with patch("accounts.adapters.allauth.AccountAdapter.send_verification_code_sms", side_effect=_capture):
        resp = client.post(ALLOAUTH_SIGNUP_PATH, data=payload, format="json", HTTP_X_CSRFTOKEN=client.cookies.get('csrftoken', ''))

    # Fetch created user by normalized phone
    normalized = User.objects.normalize_phone_number(phone_number)
    user = User.objects.filter(phone_number=normalized).first()
    return resp, user, captured["code"]


@override_settings(
    ACCOUNT_RATE_LIMITS=False,
    HEADLESS_RATE_LIMITS=False,
    RATE_LIMITS=False,
)
def confirm_registration(client: APIClient, *, phone_number: str, code: str):
    # Obtain CSRF and cookie
    _prepare_csrf(client)
    payload = {"phone": phone_number, "code": code}
    return client.post(ALLOAUTH_PHONE_VERIFY_PATH, data=payload, format="json", HTTP_X_CSRFTOKEN=client.cookies.get('csrftoken', ''))


@override_settings(
    ACCOUNT_RATE_LIMITS=False,
    HEADLESS_RATE_LIMITS=False,
    RATE_LIMITS=False,
)
def login_user(client: APIClient, *, phone_number: str, password: str):
    # Always ensure we are logged out before logging in as another user
    _prepare_csrf(client)
    client.delete(
        ALLOAUTH_LOGOUT_PATH,
        data={},
        format="json",
        HTTP_X_CSRFTOKEN=client.cookies.get('csrftoken', ''),
    )
    # Logout may reset session/CSRF; fetch a fresh token just in case
    _prepare_csrf(client)
    payload = {"phone": phone_number, "password": password}
    return client.post(
        ALLOAUTH_LOGIN_PATH,
        data=payload,
        format="json",
        HTTP_X_CSRFTOKEN=client.cookies.get('csrftoken', ''),
    )
