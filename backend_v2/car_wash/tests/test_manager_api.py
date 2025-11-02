from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from accounts.models.user import User


class ManagerEndpointsTests(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77072220001', password=DEFAULT_PASSWORD)
        self.other = create_active_user(username='Other', phone_number='+77072220002', password=DEFAULT_PASSWORD)
        # Car wash with relations so manager/washer routes have a car_wash context
        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={
            'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30,
            'car_types': [{'name': 'Sedan'}]
        })
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.list_url = reverse('car-wash-managers-list', kwargs={'car_wash_id': self.cw.id})

    def _invite_payload(self, *, username: str, phone_number: str):
        return {
            'username': username,
            'phone_number': phone_number,
            'password': 'TmpPass123',
        }

    def test_owner_can_list_and_invite_manager(self):
        # Owner has permission (IsManagerSuperior -> IsCarWashOwner)
        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)

        # Initially empty
        resp_list_empty = self.client.get(self.list_url)
        self.assertEqual(resp_list_empty.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp_list_empty.data), 0)

        # Invite by phone (creates user if absent and adds relation)
        payload = self._invite_payload(username='New Manager', phone_number='+77072220003')
        resp_create = self.client.post(self.list_url, data=payload, format='json')
        self.assertEqual(resp_create.status_code, status.HTTP_201_CREATED)
        # User entity created and added to managers M2M
        invited = User.objects.get(phone_number=User.objects.normalize_phone_number(payload['phone_number']))
        self.assertTrue(self.cw.managers.filter(id=invited.id).exists())

        # List now contains the invited manager
        resp_list = self.client.get(self.list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_200_OK)
        ids = {str(u['id']) for u in resp_list.data}
        self.assertIn(str(invited.id), ids)

    def test_non_owner_forbidden_for_manager_routes(self):
        # A different user cannot access manager routes of this car wash
        login_user(self.client, phone_number=self.other.phone_number, password=DEFAULT_PASSWORD)
        resp_list = self.client.get(self.list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_403_FORBIDDEN)
        resp_create = self.client.post(self.list_url, data=self._invite_payload(username='X', phone_number='+77072220004'), format='json')
        self.assertEqual(resp_create.status_code, status.HTTP_403_FORBIDDEN)


class WasherEndpointsTests(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77073330001', password=DEFAULT_PASSWORD)
        self.manager = create_active_user(username='Manager', phone_number='+77073330002', password=DEFAULT_PASSWORD)
        self.other = create_active_user(username='Other', phone_number='+77073330003', password=DEFAULT_PASSWORD)

        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={
            'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30,
            'car_types': [{'name': 'Sedan'}]
        })
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        # Make manager a manager of this car wash
        self.cw.managers.add(self.manager)

        self.list_url = reverse('car-wash-washers-list', kwargs={'car_wash_id': self.cw.id})

    def _invite_payload(self, *, username: str, phone_number: str):
        return {
            'username': username,
            'phone_number': phone_number,
            'password': 'TmpPass123',
        }

    def test_manager_can_list_and_invite_washer(self):
        # Permission: IsCarWashManager — only managers of this car wash
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)

        # List initially
        resp_list_empty = self.client.get(self.list_url)
        self.assertEqual(resp_list_empty.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp_list_empty.data), 0)

        # Invite washer
        payload = self._invite_payload(username='New Washer', phone_number='+77073330004')
        resp_create = self.client.post(self.list_url, data=payload, format='json')
        self.assertEqual(resp_create.status_code, status.HTTP_201_CREATED)

        invited = User.objects.get(phone_number=User.objects.normalize_phone_number(payload['phone_number']))
        self.assertTrue(self.cw.washers.filter(id=invited.id).exists())

        # List now includes the washer
        resp_list = self.client.get(self.list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_200_OK)
        ids = {str(u['id']) for u in resp_list.data}
        self.assertIn(str(invited.id), ids)

    def test_non_manager_forbidden_for_washer_routes(self):
        # Random user is not a manager of this car wash
        login_user(self.client, phone_number=self.other.phone_number, password=DEFAULT_PASSWORD)
        resp_list = self.client.get(self.list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_403_FORBIDDEN)
        resp_create = self.client.post(self.list_url, data=self._invite_payload(username='X', phone_number='+77073330005'), format='json')
        self.assertEqual(resp_create.status_code, status.HTTP_403_FORBIDDEN)

    def test_owner_is_not_implicitly_allowed_on_washer_routes(self):
        # Current permission requires being a manager (owner alone should be forbidden)
        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        resp_list = self.client.get(self.list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_403_FORBIDDEN)
