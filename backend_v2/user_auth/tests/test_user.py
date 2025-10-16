from django.test import Client
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from user_auth.models import User


class UserRegistrationTests(APITestCase):
    def setUp(self):
        User.objects.create_user(
            username='TestUser Inactive',
            phone_number='+77770000000',
            password='password',
            is_active=False,
        )

        User.objects.create_user(
            username='TestUser Active',
            phone_number='+77777777777',
            password='password',
        )

    def tearDown(self):
        User.objects.all().delete()

    def test_register_success(self):
        """
        Ensure a new user can send a registration request
        """
        url = reverse('user_register')
        data = {'phone_number': '+7(777) 123-45-67', 'password': 'password', 'username': 'NewTestUser'}
        response = self.client.post(url, data, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(User.objects.count(), 1)

        user = User.objects.prefetch_related('sms_codes').get()
        self.assertEqual(user.phone_number, '+77771234567')
        self.assertEqual(user.username, 'NewTestUser')
        self.assertFalse(user.is_active)
        self.assertFalse(user.is_staff)
        self.assertFalse(user.is_superuser)
        self.assertEqual(user.sms_codes.count(), 1)
        self.assertEqual(user.sms_codes.get().type, 'register')

    def test_register_confirmation_success(self):
        """
        Ensure user can confirm registration
        """
        url = reverse('user_register_confirm')
        user = User.objects.prefetch_related('sms_codes').filter(phone_number='+77770000000').get()

        data = {'phone_number': user.phone_number, 'code': user.sms_codes.filter(type='register').first().code}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(user.is_active)
        self.assertEqual(user.sms_codes.count(), 0)


    def test_register_misformatted_phone_number(self):
        """
        Ensure user can send a registration request
        """
        url = reverse('user_register')
        data = {'phone_number': '+7777771234567', 'password': 'password', 'username': 'TestUser'}
        response = self.client.post(url, data, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(User.objects.count(), 0)
