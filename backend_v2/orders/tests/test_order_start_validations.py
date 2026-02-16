from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from car_wash.models.box import Box
from car_wash.models import Car
from services.models import Services
from orders.models import Orders
from orders.utils.enums import OrderStatus


class TestOrderStartValidations(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070500001', password=DEFAULT_PASSWORD)
        self.manager = create_active_user(username='Manager', phone_number='+77070500002', password=DEFAULT_PASSWORD)
        self.washer = create_active_user(username='Washer', phone_number='+77070500003', password=DEFAULT_PASSWORD)
        self.client_user = create_active_user(username='Client', phone_number='+77070500004', password=DEFAULT_PASSWORD)

        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.cw.managers.add(self.manager)
        self.cw.washers.add(self.washer)

        self.box = Box.objects.create(car_wash=self.cw, name='Box 1')
        car_type = self.cw.settings.car_types.first()
        self.main = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False)

        self.car = Car.objects.create(number='AAA111', owner=self.client_user)

        # Alien car wash and entities
        alien_owner = create_active_user(username='AlienOwner', phone_number='+77070509999', password=DEFAULT_PASSWORD)
        self.alien_cw = CarWash.objects.create(owner=alien_owner, name='Alien', address='X', is_active=True)
        self.alien_cw.create_settings(settings_data={'opens_at': '08:00:00', 'closes_at': '22:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        self.alien_cw.create_documents(documents_data={'iin': '999999999999'})
        self.alien_box = Box.objects.create(car_wash=self.alien_cw, name='Alien Box')

        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})
        self.start_url = lambda cw_id, order_id: reverse('car-wash-user-orders-start', kwargs={'car_wash_id': cw_id, 'order_id': order_id})

        # Create order
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        create = self.client.post(self.list_url(self.cw.id), data={'car': str(self.car.id), 'services': [str(self.main.id)]}, format='json')
        self.order_id = create.data['id']

    def test_start_rejects_foreign_box(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        before = Orders.objects.get(id=self.order_id)
        resp = self.client.put(self.start_url(self.cw.id, self.order_id), data={'washer': str(self.washer.id), 'box': str(self.alien_box.id)}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('box', resp.data)
        # Ensure state unchanged
        after = Orders.objects.get(id=self.order_id)
        self.assertEqual(after.status, OrderStatus.EN_ROUTE)
        self.assertIsNone(after.box)
        self.assertIsNone(after.washer)
        self.assertIsNone(after.total_price)
        self.assertEqual(after.services.count(), before.services.count())
        self.assertEqual(Orders.objects.count(), 1)

    def test_start_rejects_foreign_washer(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        before = Orders.objects.get(id=self.order_id)
        alien_washer = create_active_user(username='AlienWasher', phone_number='+77070507777', password=DEFAULT_PASSWORD)
        resp = self.client.put(self.start_url(self.cw.id, self.order_id), data={'washer': str(alien_washer.id), 'box': str(self.box.id)}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('washer', resp.data)
        # Ensure state unchanged
        after = Orders.objects.get(id=self.order_id)
        self.assertEqual(after.status, OrderStatus.EN_ROUTE)
        self.assertIsNone(after.box)
        self.assertIsNone(after.washer)
        self.assertIsNone(after.total_price)
        self.assertEqual(after.services.count(), before.services.count())
        self.assertEqual(Orders.objects.count(), 1)

    def test_cannot_start_twice(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        first = self.client.put(self.start_url(self.cw.id, self.order_id), data={'washer': str(self.washer.id), 'box': str(self.box.id)}, format='json')
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        before = Orders.objects.get(id=self.order_id)
        second = self.client.put(self.start_url(self.cw.id, self.order_id), data={'washer': str(self.washer.id), 'box': str(self.box.id)}, format='json')
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('id', second.data)
        after = Orders.objects.get(id=self.order_id)
        self.assertEqual(after.status, OrderStatus.IN_PROGRESS)
        self.assertEqual(after.box_id, before.box_id)
        self.assertEqual(after.washer_id, before.washer_id)
        self.assertEqual(after.total_price, before.total_price)
