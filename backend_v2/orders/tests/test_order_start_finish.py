from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from car_wash.models.box import Box
from car_wash.models import Car
from orders.utils.enums import OrderStatus
from orders.models import Orders
from services.models import Services


class TestOrderStartFinish(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070300001', password=DEFAULT_PASSWORD)
        self.manager = create_active_user(username='Manager', phone_number='+77070300002', password=DEFAULT_PASSWORD)
        self.washer = create_active_user(username='Washer', phone_number='+77070300003', password=DEFAULT_PASSWORD)
        self.client_user = create_active_user(username='Client', phone_number='+77070300004', password=DEFAULT_PASSWORD)

        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.cw.managers.add(self.manager)
        self.cw.washers.add(self.washer)

        self.box = Box.objects.create(car_wash=self.cw, name='Box 1')
        car_type = self.cw.settings.car_types.first()
        self.main = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False)
        self.extra = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Extra', description='Extra', price=200, duration='00:05:00', is_extra=True)

        self.car = Car.objects.create(number='AAA111', owner=self.client_user)

        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})
        self.start_url = lambda cw_id, order_id: reverse('car-wash-user-orders-start', kwargs={'car_wash_id': cw_id, 'order_id': order_id})
        self.finish_url = lambda cw_id, order_id: reverse('car-wash-user-orders-finish', kwargs={'car_wash_id': cw_id, 'order_id': order_id})

    def _create_order(self):
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        resp = self.client.post(self.list_url(self.cw.id), data={'car': str(self.car.id), 'services': [str(self.main.id), str(self.extra.id)]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        return resp.data['id']

    def test_manager_can_start_and_finish(self):
        order_id = self._create_order()
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        start = self.client.put(self.start_url(self.cw.id, order_id), data={'washer': str(self.washer.id), 'box': str(self.box.id)}, format='json')
        self.assertEqual(start.status_code, status.HTTP_200_OK)
        self.assertEqual(start.data['status'], OrderStatus.IN_PROGRESS)
        self.assertEqual(start.data['total_price'], self.main.price + self.extra.price)
        finish = self.client.put(self.finish_url(self.cw.id, order_id), data={}, format='json')
        self.assertEqual(finish.status_code, status.HTTP_200_OK)
        self.assertEqual(finish.data['status'], OrderStatus.COMPLETED)

    def test_finish_when_not_in_progress_is_rejected(self):
        order_id = self._create_order()
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        before = Orders.objects.get(id=order_id)
        resp = self.client.put(self.finish_url(self.cw.id, order_id), data={}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('id', resp.data)
        after = Orders.objects.get(id=order_id)
        self.assertEqual(after.status, OrderStatus.EN_ROUTE)
        self.assertIsNone(after.finished_at)
        self.assertIsNone(after.started_at)
        self.assertIsNone(after.total_price)
        self.assertIsNone(after.box)
        self.assertIsNone(after.washer)
        self.assertEqual(after.services.count(), before.services.count())
