from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from car_wash.models import Car
from orders.models import Orders
from orders.utils.enums import OrderStatus
from services.models import Services


class TestOrderCancel(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070700001', password=DEFAULT_PASSWORD)
        self.client_user = create_active_user(username='Client', phone_number='+77070700002', password=DEFAULT_PASSWORD)
        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.cw.create_boxes(amount=2)
        car_type = self.cw.settings.car_types.first()
        self.main = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False)
        self.car = Car.objects.create(number='AAA111', owner=self.client_user)
        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})
        self.detail_url = lambda cw_id, order_id: reverse('car-wash-user-orders-detail', kwargs={'car_wash_id': cw_id, 'order_id': order_id})

        # Create order
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        create = self.client.post(self.list_url(self.cw.id), data={'car': str(self.car.id), 'services': [str(self.main.id)]}, format='json')
        self.order_id = create.data['id']

    def test_delete_sets_status_canceled(self):
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        resp = self.client.delete(self.detail_url(self.cw.id, self.order_id))
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        order = Orders.objects.get(id=self.order_id)
        self.assertEqual(order.status, OrderStatus.CANCELED)
