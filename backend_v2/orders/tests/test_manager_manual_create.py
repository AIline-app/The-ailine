from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import User
from accounts.tests.factories import create_active_user, DEFAULT_PASSWORD, login_user
from car_wash.models.car_wash import CarWash
from services.models import Services
from orders.models import Orders


class TestManagerManualCreate(APITestCase):
    def setUp(self):
        self.owner = create_active_user(username='Owner', phone_number='+77070200001', password=DEFAULT_PASSWORD)
        self.manager = create_active_user(username='Manager', phone_number='+77070200002', password=DEFAULT_PASSWORD)
        self.cw = CarWash.objects.create(owner=self.owner, name='CW', address='Addr', is_active=True)
        self.cw.create_settings(settings_data={
            'opens_at': '09:00:00', 'closes_at': '21:00:00', 'percent_washers': 30, 'car_types': [{'name': 'Sedan'}]
        })
        self.cw.create_documents(documents_data={'iin': '123456789012'})
        self.cw.create_boxes(amount=2)
        self.cw.managers.add(self.manager)

        car_type = self.cw.settings.car_types.first()
        self.main_service = Services.objects.create(
            car_wash=self.cw, car_type=car_type, name='Basic', description='Main', price=1000, duration='00:30:00', is_extra=False
        )
        self.manual_url = lambda cw_id: reverse('car-wash-user-orders-manual', kwargs={'car_wash_id': cw_id})
        self.list_url = lambda cw_id: reverse('car-wash-user-orders-list', kwargs={'car_wash_id': cw_id})

    def test_manager_can_create_manual_order(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        payload = {
            'client_info': {
                'phone_number': '+77070205555',
                'username': 'WalkIn',
                'car_number': 'W111AA',
            },
            'services': [str(self.main_service.id)],
            'status': 'on_site',
        }
        resp = self.client.post(self.manual_url(self.cw.id), data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        list_resp = self.client.get(self.list_url(self.cw.id))
        self.assertEqual(list_resp.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(list_resp.data), 1)

    def test_manual_create_reuses_existing_user_and_car(self):
        # Pre-create user with phone and car
        existing = create_active_user(username='Existing', phone_number='+77070206666', password=DEFAULT_PASSWORD)
        existing.cars.create(number='EX123')
        user_count_before = User.objects.count()
        car_count_before = existing.cars.count()

        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        payload = {
            'client_info': {
                'phone_number': existing.phone_number,
                'username': 'Ignored',
                'car_number': 'EX123',
            },
            'services': [str(self.main_service.id)],
            'status': 'on_site',
        }
        resp = self.client.post(self.manual_url(self.cw.id), data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        # Ensure no new user was created and car count unchanged
        self.assertEqual(User.objects.count(), user_count_before)
        existing.refresh_from_db()
        self.assertEqual(existing.cars.count(), car_count_before)

    def test_manual_create_invalid_payload_does_not_create_anything(self):
        login_user(self.client, phone_number=self.manager.phone_number, password=DEFAULT_PASSWORD)
        user_count_before = User.objects.count()
        orders_before = Orders.objects.count()
        payload = {
            'client_info': {
                'phone_number': '+77070207777',
                # 'username' missing
                'car_number': 'BAD123',
            },
            # Missing services
        }
        resp = self.client.post(self.manual_url(self.cw.id), data=payload, format='json')
        self.assertEqual(resp.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertGreaterEqual(len(resp.data.keys()), 1)
        self.assertEqual(User.objects.count(), user_count_before)
        self.assertEqual(Orders.objects.count(), orders_before)
