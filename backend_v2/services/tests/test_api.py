from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from services.models import Services


class ServicesEndpointsTests(APITestCase):
    def setUp(self):
        # Owners and other user
        self.owner = create_active_user(username='Owner', phone_number='+77071110001', password=DEFAULT_PASSWORD)
        self.other = create_active_user(username='Other', phone_number='+77071110002', password=DEFAULT_PASSWORD)
        # Create a car wash with settings and documents so that car_types exist
        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={
            'opens_at': '09:00:00',
            'closes_at': '21:00:00',
            'percent_washers': 30,
            'car_types': [{'name': 'Sedan'}, {'name': 'SUV'}],
        })
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        # Convenience
        self.list_url = reverse('car-wash-services-list', kwargs={'car_wash_id': self.cw.id})

    def _service_payload(self, *, car_type_id):
        return {
            'name': 'Express Wash',
            'description': 'Fast exterior wash',
            'price': 500,
            'duration': '00:30:00',
            'car_type': str(car_type_id),
            # is_extra is optional (default False)
        }

    def test_public_can_list_services_for_car_wash(self):
        # Arrange: create a service directly
        car_type = self.cw.settings.car_types.first()
        Services.objects.create(
            car_wash=self.cw,
            car_type=car_type,
            name='Basic',
            description='Basic wash',
            price=400,
            duration='00:20:00',
            is_extra=False,
        )
        # Act
        resp = self.client.get(self.list_url)
        # Assert
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(resp.data), 1)
        self.assertIn('name', resp.data[0])

    def test_owner_can_create_service(self):
        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        car_type = self.cw.settings.car_types.first()
        payload = self._service_payload(car_type_id=car_type.id)
        resp = self.client.post(self.list_url, data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        # Created in DB and linked to this car_wash
        self.assertTrue(Services.objects.filter(car_wash=self.cw, name='Express Wash').exists())

    def test_non_owner_cannot_create_service(self):
        self.client.login(phone_number=self.other.phone_number, password=DEFAULT_PASSWORD)
        car_type = self.cw.settings.car_types.first()
        payload = self._service_payload(car_type_id=car_type.id)
        resp = self.client.post(self.list_url, data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    def test_cannot_use_car_type_from_another_car_wash(self):
        # Set up another car wash with a different car type
        other_cw_owner = create_active_user(username='Third', phone_number='+77071110003', password=DEFAULT_PASSWORD)
        other_cw = CarWash.objects.create(owner=other_cw_owner, name='CW2', address='Addr2', is_active=True)
        other_cw.create_settings(settings_data={
            'opens_at': '08:00:00',
            'closes_at': '22:00:00',
            'percent_washers': 25,
            'car_types': [{'name': 'Truck'}],
        })
        other_cw.create_documents(documents_data={'iin': '999999999999'})

        foreign_car_type = other_cw.settings.car_types.first()

        login_user(self.client, phone_number=self.owner.phone_number, password=DEFAULT_PASSWORD)
        payload = self._service_payload(car_type_id=foreign_car_type.id)
        resp = self.client.post(self.list_url, data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('car_type', resp.data)
