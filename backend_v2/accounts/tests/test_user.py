from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models.user import User
from accounts.utils.enums import TypeSmsCode
from accounts.tests.factories import (
    create_active_user,
    create_inactive_user,
    register_user_and_get_sms,
    confirm_registration,
    login_user,
)
from accounts.utils.constants import MAX_SMS_CODE_VALUE


class UserAuthEndpointsTests(APITestCase):
    def setUp(self):
        self.register_url = reverse('user_register')
        self.register_confirm_url = reverse('user_register_confirm')
        self.login_url = reverse('user_login')
        # Router-registered endpoint to fetch current user (requires auth)
        self.me_url = '/user/me/'

        self.sample_username = 'John Doe'
        self.sample_phone = '+77051234567'
        self.sample_password = 'S3cureP@ssw0rd'

    def test_register_success_creates_inactive_user_and_returns_user_data(self):
        payload = {
            'username': self.sample_username,
            'phone_number': self.sample_phone,
            'password': self.sample_password,
        }
        resp = self.client.post(self.register_url, data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        # Response should contain user fields
        self.assertIn('id', resp.data)
        self.assertEqual(resp.data['username'], self.sample_username)
        self.assertIn('phone_number', resp.data)
        # Ensure user exists and is inactive until confirmation
        user = User.objects.get(phone_number=User.objects.normalize_phone_number(self.sample_phone))
        self.assertFalse(user.is_verified)

    def test_register_existing_active_fails(self):
        # Prepare existing active user with CLIENT role
        create_active_user(
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )
        users_before = User.objects.count()

        payload = {
            'username': 'Another Name',
            'phone_number': self.sample_phone,
            'password': 'AnotherPass123',
        }
        resp = self.client.post(self.register_url, data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('phone_number', resp.data)
        # Ensure no new user or sms was created
        self.assertEqual(User.objects.count(), users_before)
        user = User.objects.get(phone_number=User.objects.normalize_phone_number(self.sample_phone))

    def test_register_confirm_success_activates_user_and_logs_in(self):
        # Register first to create user and SMS
        reg_resp, user, code = register_user_and_get_sms(
            self.client,
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )
        self.assertEqual(reg_resp.status_code, status.HTTP_201_CREATED)
        self.assertIsNotNone(code)

        resp = confirm_registration(self.client, phone_number=self.sample_phone, code=code)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

        # User should now be active and logged in (session auth)
        user.refresh_from_db()
        self.assertTrue(user.is_verified)
        # Verify session by accessing protected endpoint
        me_resp = self.client.get(self.me_url)
        self.assertEqual(me_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(me_resp.data.get('id'), str(user.id))

    def test_register_confirm_with_wrong_code_fails(self):
        # Create an inactive user and a valid SMS, but send incorrect code
        reg_resp, user, code = register_user_and_get_sms(
            self.client,
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )
        self.assertEqual(reg_resp.status_code, status.HTTP_201_CREATED)
        self.assertIsNotNone(code)

        # pick a wrong code within valid range
        wrong_code = code + 1 if code + 1 < MAX_SMS_CODE_VALUE else code - 1
        resp = confirm_registration(self.client, phone_number=self.sample_phone, code=wrong_code)
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('code', resp.data)
        # Ensure user remains inactive and SMS not deleted; also no session established
        user.refresh_from_db()
        self.assertFalse(user.is_verified)
        me_resp = self.client.get(self.me_url)
        self.assertEqual(me_resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_login_success_for_active_user(self):
        # Create active user directly
        user = create_active_user(
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )

        resp = login_user(self.client, phone_number=self.sample_phone, password=self.sample_password)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        # Verify session by accessing protected endpoint
        me_resp = self.client.get(self.me_url)
        self.assertEqual(me_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(me_resp.data.get('id'), str(user.id))

    def test_login_fails_for_inactive_user(self):
        # Create inactive user
        create_inactive_user(
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )
        resp = login_user(self.client, phone_number=self.sample_phone, password=self.sample_password)
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        # Ensure session not established
        me_resp = self.client.get(self.me_url)
        self.assertEqual(me_resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_login_fails_for_wrong_credentials(self):
        # Active user
        user = create_active_user(
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )

        resp = login_user(self.client, phone_number=self.sample_phone, password='WrongPass123')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        # Ensure session not established
        me_resp = self.client.get(self.me_url)
        self.assertEqual(me_resp.status_code, status.HTTP_403_FORBIDDEN)


    def test_me_returns_current_user_data_for_authenticated_user(self):
        # Arrange: create and log in an active user
        user = create_active_user(
            username=self.sample_username,
            phone_number=self.sample_phone,
            password=self.sample_password,
        )
        login_resp = login_user(self.client, phone_number=self.sample_phone, password=self.sample_password)
        self.assertEqual(login_resp.status_code, status.HTTP_200_OK)

        # Act
        resp = self.client.get(self.me_url)

        # Assert
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        # Response should contain serialized user data
        for field in ('id', 'username', 'phone_number', 'created_at'):
            self.assertIn(field, resp.data)
        self.assertEqual(resp.data['id'], str(user.id))
        self.assertEqual(resp.data['username'], user.name)
        self.assertEqual(resp.data['phone_number'], User.objects.normalize_phone_number(self.sample_phone))

    def test_me_unauthorized_returns_error(self):
        # Without authentication, access to /user/me/ should be forbidden
        resp = self.client.get(self.me_url)
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.assertIn('detail', resp.data)
