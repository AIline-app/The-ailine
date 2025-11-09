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


class TestOrderUpdateServices(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070600001', password=DEFAULT_PASSWORD)
        self.manager = create_active_user(username='Manager', phone_number='+77070600002', password=DEFAULT_PASSWORD)
        self.washer = create_active_user(username='Washer', phone_number='+77070600003', password=DEFAULT_PASSWORD)
        self.client_user = create_active_user(username='Client', phone_number='+77070600004', password=DEFAULT_PASSWORD)

        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.cw.managers.add(self.manager)
        self.cw.washers.add(self.washer)

        self.box = Box.objects.create(car_wash=self.cw, name='Box 1')
        car_type = self.cw.settings.car_types.first()
        self.main = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False)
        self.extra = Services.objects.create(car_wash=self.cw, car_type=car_type, name='Extra', description='Extra', price=200, duration='00:05:00', is_extra=True)

        # Alien service
        alien_owner = create_active_user(username='AlienOwner', phone_number='+77070609999', password=DEFAULT_PASSWORD)
        alien_cw = CarWash.objects.create(owner=alien_owner, name='Alien', address='X', is_active=True)
        alien_cw.create_settings(settings_data={'opens_at': '08:00:00', 'closes_at': '22:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]})
        alien_cw.create_documents(documents_data={'iin': '999999999999'})
        self.alien_service = Services.objects.create(car_wash=alien_cw, car_type=alien_cw.settings.car_types.first(), name='Alien Basic', description='Main', price=777, duration='00:20:00', is_extra=False)

        self.car = Car.objects.create(number='AAA111', owner=self.client_user)

        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})
        self.update_services_url = lambda cw_id, order_id: reverse('car-wash-user-orders-update-services', kwargs={'car_wash_id': cw_id, 'order_id': order_id})
        self.start_url = lambda cw_id, order_id: reverse('car-wash-user-orders-start', kwargs={'car_wash_id': cw_id, 'order_id': order_id})

        # Create order
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        create = self.client.post(self.list_url(self.cw.id), data={'car': str(self.car.id), 'services': [str(self.main.id)]}, format='json')
        self.order_id = create.data['id']

    def test_update_services_accepts_one_main_plus_extras(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        resp = self.client.put(self.update_services_url(self.cw.id, self.order_id), data={'services': [str(self.main.id), str(self.extra.id)]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data['services']), 2)

    def test_update_services_rejects_two_mains(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        before = list(Orders.objects.get(id=self.order_id).services.values_list('id', flat=True))
        second_main = Services.objects.create(car_wash=self.cw, car_type=self.cw.settings.car_types.first(), name='Premium', description='Main', price=1500, duration='00:40:00', is_extra=False)
        resp = self.client.put(self.update_services_url(self.cw.id, self.order_id), data={'services': [str(self.main.id), str(second_main.id)]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('services', resp.data)
        after = list(Orders.objects.get(id=self.order_id).services.values_list('id', flat=True))
        self.assertListEqual(after, before)

    def test_update_services_rejects_services_from_another_car_wash(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        before = list(Orders.objects.get(id=self.order_id).services.values_list('id', flat=True))
        resp = self.client.put(self.update_services_url(self.cw.id, self.order_id), data={'services': [str(self.alien_service.id)]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        after = list(Orders.objects.get(id=self.order_id).services.values_list('id', flat=True))
        self.assertListEqual(after, before)

    def test_update_services_forbidden_after_start(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        # Start first
        self.client.put(self.start_url(self.cw.id, self.order_id), data={'washer': str(self.washer.id), 'box': str(self.box.id)}, format='json')
        before = list(Orders.objects.get(id=self.order_id).services.values_list('id', flat=True))
        resp = self.client.put(self.update_services_url(self.cw.id, self.order_id), data={'services': [str(self.main.id)]}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('id', resp.data)
        after = list(Orders.objects.get(id=self.order_id).services.values_list('id', flat=True))
        self.assertListEqual(after, before)
