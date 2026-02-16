from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from car_wash.models.box import Box
from car_wash.models import Car
from services.models import Services


class TestOrderPermissions(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070400001', password=DEFAULT_PASSWORD)
        self.manager = create_active_user(username='Manager', phone_number='+77070400002', password=DEFAULT_PASSWORD)
        self.not_manager = create_active_user(username='NotManager', phone_number='+77070400003', password=DEFAULT_PASSWORD)
        self.washer = create_active_user(username='Washer', phone_number='+77070400004', password=DEFAULT_PASSWORD)
        self.client_user = create_active_user(username='Client', phone_number='+77070400005', password=DEFAULT_PASSWORD)

        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.cw.managers.add(self.manager)
        self.cw.washers.add(self.washer)

        self.box = Box.objects.create(car_wash=self.cw, name='Box 1')
        car_type = self.cw.settings.car_types.first()
        self.main = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False)

        self.car = Car.objects.create(number='AAA111', owner=self.client_user)
        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})
        self.start_url = lambda cw_id, order_id: reverse('car-wash-user-orders-start', kwargs={'car_wash_id': cw_id, 'order_id': order_id})
        self.finish_url = lambda cw_id, order_id: reverse('car-wash-user-orders-finish', kwargs={'car_wash_id': cw_id, 'order_id': order_id})
        self.update_services_url = lambda cw_id, order_id: reverse('car-wash-user-orders-update-services', kwargs={'car_wash_id': cw_id, 'order_id': order_id})

        # Create order
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        create = self.client.post(self.list_url(self.cw.id), data={'car': str(self.car.id), 'services': [str(self.main.id)]}, format='json')
        self.assertEqual(create.status_code, status.HTTP_201_CREATED)
        self.order_id = create.data['id']

    def test_non_manager_cannot_start_finish_or_update_services(self):
        login_user(self.client, phone_number=self.not_manager.phone_number, password=DEFAULT_PASSWORD)
        resp_start = self.client.put(self.start_url(self.cw.id, self.order_id), data={'washer': str(self.washer.id), 'box': str(self.box.id)}, format='json')
        self.assertEqual(resp_start.status_code, status.HTTP_403_FORBIDDEN)
        resp_finish = self.client.put(self.finish_url(self.cw.id, self.order_id), data={}, format='json')
        self.assertEqual(resp_finish.status_code, status.HTTP_403_FORBIDDEN)
        resp_update = self.client.put(self.update_services_url(self.cw.id, self.order_id), data={'services': [str(self.main.id)]}, format='json')
        self.assertEqual(resp_update.status_code, status.HTTP_403_FORBIDDEN)
