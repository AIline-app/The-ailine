from typing import Tuple, Optional

from django.urls import reverse
from rest_framework.test import APIClient

from accounts.models.user import User
from accounts.utils.enums import TypeSmsCode


DEFAULT_PASSWORD = "S3cureP@ssw0rd"


def create_inactive_user(*, username: str, phone_number: str, password: str = DEFAULT_PASSWORD) -> User:
    """Create a user with is_active=False (default in model)."""
    user = User.objects.create_user(
        username=username,
        phone_number=phone_number,
        password=password,
    )
    # Ensure inactive (model default is False, but be explicit)
    if user.is_verified:
        user.is_verified = False
        user.save(update_fields=["is_verified"])
    return user


def create_active_user(*, username: str, phone_number: str, password: str = DEFAULT_PASSWORD) -> User:
    """Create a user and activate it."""
    user = create_inactive_user(username=username, phone_number=phone_number, password=password)
    if not user.is_verified:
        user.is_verified = True
        user.save(update_fields=["is_verified"])
    return user


def register_user_and_get_sms(
    client: APIClient,
    *,
    username: str,
    phone_number: str,
    password: str = DEFAULT_PASSWORD,
):
    """Register via API and return (response, user, sms_code) for confirmation tests."""
    register_url = reverse("user_register")
    resp = client.post(register_url, data={
        "username": username,
        "phone_number": phone_number,
        "password": password,
    }, format="json")
    # Caller can assert status codes; we still fetch objects for convenience
    normalized = User.objects.normalize_phone_number(phone_number)
    user = User.objects.get(phone_number=normalized)
    return resp, user, None


def confirm_registration(client: APIClient, *, phone_number: str, code: int):
    url = reverse("user_register_confirm")
    return client.post(url, data={"phone_number": phone_number, "code": code}, format="json")


def login_user(client: APIClient, *, phone_number: str, password: str):
    url = reverse("user_login")
    return client.post(url, data={"phone_number": phone_number, "password": password}, format="json")
