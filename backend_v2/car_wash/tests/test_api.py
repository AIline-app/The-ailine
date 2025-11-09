from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from car_wash.models.box import Box
from car_wash.models import Car


class CarWashEndpointsTests(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070000001', password=DEFAULT_PASSWORD)
        self.other = create_active_user(username='Other', phone_number='+77070000002', password=DEFAULT_PASSWORD)
        # Helper payload pieces
        self.sample_settings = {
            'opens_at': '08:00:00',
            'closes_at': '22:00:00',
            'percent_washers': 30,
            'car_types': [
                {'name': 'Sedan'},
                {'name': 'SUV'},
            ]
        }
        self.sample_documents = {
            'iin': '123456789012'
        }

    def _create_car_wash(self, *, owner, name='CW', address='City, Street 1', is_active=True):
        cw = CarWash.objects.create(owner=owner, name=name, address=address, is_active=is_active)
        cw.create_settings(settings_data={
            'opens_at': '09:00:00',
            'closes_at': '21:00:00',
            'percent_washers': 30,
            'car_types': [{'name': 'Sedan'}],
        })
        cw.create_documents(documents_data={'iin': '111122223333'})
        return cw

    def test_list_public_shows_only_active(self):
        active_cw = self._create_car_wash(owner=self.owner, is_active=True)
        self._create_car_wash(owner=self.owner, is_active=False)

        url = reverse('car-wash-list')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        ids = [item['id'] for item in resp.data]
        self.assertIn(str(active_cw.id), ids)
        self.assertEqual(len(resp.data), 1)

    def test_list_authenticated_sees_active_and_own_inactive(self):
        own_inactive = self._create_car_wash(owner=self.owner, is_active=False)
        public_active = self._create_car_wash(owner=self.other, is_active=True)

        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        url = reverse('car-wash-list')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in resp.data}
        # Should include public active and own inactive
        self.assertIn(str(public_active.id), ids)
        self.assertIn(str(own_inactive.id), ids)

    def test_retrieve_owner_gets_private_fields_and_non_owner_gets_public(self):
        cw = self._create_car_wash(owner=self.owner, is_active=True)
        url = reverse('car-wash-detail', kwargs={'car_wash_id': cw.id})

        # Anonymous -> public
        resp_public = self.client.get(url)
        self.assertEqual(resp_public.status_code, status.HTTP_200_OK)
        self.assertNotIn('documents', resp_public.data)

        # Owner -> private
        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        resp_owner = self.client.get(url)
        self.assertEqual(resp_owner.status_code, status.HTTP_200_OK)
        self.assertIn('documents', resp_owner.data)

    def test_create_car_wash_sets_owner(self):
        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        url = reverse('car-wash-list')
        payload = {
            'name': 'My Car Wash',
            'address': 'Some address',
            'boxes_amount': 2,
            'settings': self.sample_settings,
            'documents': self.sample_documents,
        }
        resp = self.client.post(url, data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        # Fetch created object and ensure owner is set
        created_id = resp.data.get('id')
        cw = CarWash.objects.get(id=created_id)
        self.assertEqual(cw.owner, self.owner)
        # Boxes created
        self.assertEqual(Box.objects.filter(car_wash=cw).count(), 2)


class BoxEndpointsTests(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070000011', password=DEFAULT_PASSWORD)
        self.other = create_active_user(username='Other', phone_number='+77070000012', password=DEFAULT_PASSWORD)
        # Create car wash with relations
        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={
            'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]
        })
        self.cw.create_documents(documents_data={'iin': '123456789012'})

    def test_owner_can_list_and_create_boxes(self):
        self.client.login(phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        list_url = reverse('car-wash-boxes-list', kwargs={'car_wash_id': self.cw.id})
        resp_list = self.client.get(list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_200_OK)

        create_resp = self.client.post(list_url, data={'name': 'VIP Box'}, format='json')
        self.assertEqual(create_resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Box.objects.filter(car_wash=self.cw).count(), 1)

    def test_non_owner_forbidden(self):
        self.client.login(phone_number=self.other.phone_number, password=DEFAULT_PASSWORD)
        list_url = reverse('car-wash-boxes-list', kwargs={'car_wash_id': self.cw.id})
        count_before = Box.objects.filter(car_wash=self.cw).count()
        resp = self.client.get(list_url)
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(Box.objects.filter(car_wash=self.cw).count(), count_before)


class CarEndpointsTests(APITestCase):
    def setUp(self):
        self.user = create_active_user(username='User', phone_number='+77070000021', password=DEFAULT_PASSWORD)
        self.other = create_active_user(username='Other', phone_number='+77070000022', password=DEFAULT_PASSWORD)
        self.list_url = reverse('user-car-list')

    def test_create_and_list_own_cars(self):
        self.client.login(phone_number=self.user.phone_number, password=DEFAULT_PASSWORD)
        # Create
        resp_create = self.client.post(self.list_url, data={'number': '123ABC01'}, format='json')
        self.assertEqual(resp_create.status_code, status.HTTP_201_CREATED)
        # Only own cars returned
        Car.objects.create(number='ZZZ999', owner=self.other)
        resp_list = self.client.get(self.list_url)
        self.assertEqual(resp_list.status_code, status.HTTP_200_OK)
        numbers = {c['number'] for c in resp_list.data}
        self.assertIn('123ABC01', numbers)
        self.assertNotIn('ZZZ999', numbers)

    def test_duplicate_number_rejected(self):
        self.client.login(phone_number=self.user.phone_number, password=DEFAULT_PASSWORD)
        self.client.post(self.list_url, data={'number': 'AAA111'}, format='json')
        # Same number again should be rejected by serializer
        count_before = Car.objects.filter(owner=self.user).count()
        resp_dup = self.client.post(self.list_url, data={'number': 'AAA111'}, format='json')
        self.assertEqual(resp_dup.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('number', resp_dup.data)
        self.assertEqual(Car.objects.filter(owner=self.user).count(), count_before)
