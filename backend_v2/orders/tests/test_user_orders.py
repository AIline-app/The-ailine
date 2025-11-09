from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from car_wash.models.box import Box
from car_wash.models import Car
from orders.models import Orders
from orders.utils.enums import OrderStatus
from services.models import Services


class TestUserOrders(APITestCase):
    def setUp(self):
        # Users
        self.owner = create_active_user(username='Owner', phone_number='+77070100001', password=DEFAULT_PASSWORD)
        self.client_user = create_active_user(username='Client', phone_number='+77070100002', password=DEFAULT_PASSWORD)
        self.other_user = create_active_user(username='OtherClient', phone_number='+77070100003', password=DEFAULT_PASSWORD)

        # Car wash
        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={
            'opens_at': '09:00:00',
            'closes_at': '21:00:00',
            'percent_washers': 30,
            'car_types': [{'name': 'Sedan'}],
        })
        self.cw.create_documents(documents_data={'iin': '123456789012'})

        # Boxes (not used directly here, but ensure related exists)
        Box.objects.create(car_wash=self.cw, name='Box 1')

        # Service set
        car_type = self.cw.settings.car_types.first()
        self.main_service = Services.objects.create(
            car_wash=self.cw,
            car_type=car_type,
            name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False
        )
        self.extra_service = Services.objects.create(
            car_wash=self.cw,
            car_type=car_type,
            name='Air Freshener', description='Extra', price=200, duration='00:05:00', is_extra=True
        )

        # Client cars
        self.client_car = Car.objects.create(number='111AAA', owner=self.client_user)
        self.other_car = Car.objects.create(number='222BBB', owner=self.other_user)

        # URLs
        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})

    def test_user_can_create_order_and_list_only_own(self):
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        payload = {
            'car': str(self.client_car.id),
            'services': [str(self.main_service.id), str(self.extra_service.id)],
            'status': OrderStatus.EN_ROUTE,
        }
        resp = self.client.post(self.list_url(self.cw.id), data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        created_id = resp.data['id']

        # Create someone else's order
        foreign_order = Orders.objects.create(user=self.other_user, car_wash=self.cw, car=self.other_car)
        foreign_order.services.add(self.main_service)

        list_resp = self.client.get(self.list_url(self.cw.id))
        self.assertEqual(list_resp.status_code, status.HTTP_200_OK)
        ids = {item['id'] for item in list_resp.data}
        self.assertIn(str(created_id), ids)
        self.assertNotIn(str(foreign_order.id), ids)

    def test_listing_other_car_wash_returns_only_user_orders_or_empty(self):
        # Create another car wash with no orders for this user
        other_owner = create_active_user(username='OtherOwner', phone_number='+77070109999', password=DEFAULT_PASSWORD)
        other_cw = CarWash.objects.create(owner=other_owner, name='Else', address='X', is_active=True)
        other_cw.create_settings(settings_data={
            'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]
        })
        other_cw.create_documents(documents_data={'iin': '999999999999'})
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        resp = self.client.get(self.list_url(other_cw.id))
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data, [])

    def test_create_rejects_without_main_service_or_with_multiple_mains(self):
        login_user(self.client, phone_number=self.client_user.phone_number, password=DEFAULT_PASSWORD)
        from orders.models import Orders
        count_before = Orders.objects.count()
        # Only extra -> 400
        payload_extra_only = {
            'car': str(self.client_car.id),
            'services': [str(self.extra_service.id)],
            'status': OrderStatus.EN_ROUTE,
        }
        resp1 = self.client.post(self.list_url(self.cw.id), data=payload_extra_only, format='json')
        self.assertEqual(resp1.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('services', resp1.data)
        self.assertEqual(Orders.objects.count(), count_before)
        # Multiple mains -> 400
        car_type = self.cw.settings.car_types.first()
        second_main = Services.objects.create(
            car_wash=self.cw, car_type=car_type, name='Premium', description='Main', price=1500, duration='00:40:00', is_extra=False
        )
        payload_two_mains = {
            'car': str(self.client_car.id),
            'services': [str(self.main_service.id), str(second_main.id)],
            'status': OrderStatus.EN_ROUTE,
        }
        resp2 = self.client.post(self.list_url(self.cw.id), data=payload_two_mains, format='json')
        self.assertEqual(resp2.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('services', resp2.data)
        self.assertEqual(Orders.objects.count(), count_before)
