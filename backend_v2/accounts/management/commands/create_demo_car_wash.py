from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from accounts.models.user import User
from car_wash.models.car_wash import CarWash, CarWashSettings, CarType
from car_wash.models import Car, Box
from services.models.services import Services
from orders.models.orders import Orders
from orders.utils.enums import OrderStatus
from datetime import time, timedelta


class Command(BaseCommand):
    help = (
        'Creates demo data: one owner with two active car washes (A:2 boxes, B:4 boxes) with managers/washers and various orders; '
        'and a second owner with an inactive car wash C with assigned staff and no orders.'
    )


    def _get_or_create_user(self, phone: str, name: str, password: str, is_verified: bool = True) -> User:
        user = User.objects.filter(phone_number=phone).first()
        if user is None:
            user = User.objects.create_user(username=name, phone_number=phone, password=password, is_verified=is_verified)
            self.stdout.write(self.style.SUCCESS(f'Created user {name} ({phone})'))
        else:
            updated = False
            if user.username != name:
                user.username = name
                updated = True
            if user.is_verified != is_verified:
                user.is_verified = is_verified
                updated = True
            if password:
                user.set_password(password)
                updated = True
            if updated:
                user.save(update_fields=['username', 'is_verified', 'password'])
            self.stdout.write(self.style.WARNING(f'Using existing user {name} ({phone})'))
        return user

    def _ensure_settings_and_services(self, car_wash: CarWash):
        # Ensure settings
        settings = getattr(car_wash, 'settings', None)
        if settings is None:
            settings = CarWashSettings.objects.create(
                car_wash=car_wash,
                opens_at=time(9, 0),
                closes_at=time(21, 0),
                percent_washers=30,
            )
            self.stdout.write(self.style.SUCCESS(f'Created settings for {car_wash.name}'))
        # Ensure sedan car type
        sedan_type = settings.car_types.filter(name='sedan').first()
        if sedan_type is None:
            sedan_type = CarType.objects.create(settings=settings, name='sedan')
            self.stdout.write(self.style.SUCCESS(f'Created sedan car type for {car_wash.name}'))
        # Ensure services (2 regular, 2 extras)
        service_specs = [
            {"name": "Basic Wash", "description": "Exterior hand wash", "price": 2000, "duration": timedelta(minutes=30), "is_extra": False},
            {"name": "Interior Clean", "description": "Vacuum and wipe interior", "price": 3000, "duration": timedelta(minutes=45), "is_extra": False},
            {"name": "Air Freshener", "description": "Add air freshener", "price": 500, "duration": timedelta(minutes=5), "is_extra": True},
            {"name": "Wax Coating", "description": "Quick spray wax", "price": 1500, "duration": timedelta(minutes=20), "is_extra": True},
        ]
        for spec in service_specs:
            Services.objects.get_or_create(
                car_wash=car_wash,
                car_type=sedan_type,
                name=spec['name'],
                defaults={
                    'description': spec['description'],
                    'price': spec['price'],
                    'duration': spec['duration'],
                    'is_extra': spec['is_extra'],
                }
            )
        return sedan_type

    def _ensure_boxes(self, car_wash: CarWash, required: int):
        existing = car_wash.boxes.count()
        if existing < required:
            to_create = required - existing
            car_wash.create_boxes(to_create)
            self.stdout.write(self.style.SUCCESS(f'{car_wash.name}: added {to_create} box(es)'))
        else:
            self.stdout.write(self.style.WARNING(f'{car_wash.name}: already has {existing} box(es)'))

    def _compose_services_for_order(self, car_wash: CarWash, variant: int = 0):
        """Return a list of services for an order:
        - exactly one base service (is_extra=False)
        - plus 0 to 2 extra services (is_extra=True), varying by `variant`.
        """
        all_services = list(car_wash.services.all())
        if not all_services:
            return []
        base_services = [s for s in all_services if not s.is_extra]
        extra_services = [s for s in all_services if s.is_extra]
        if not base_services:
            return []
        base = base_services[variant % len(base_services)]
        # 0, 1, or 2 extras based on variant
        extra_count = variant % 3
        chosen_extras = []
        if extra_services and extra_count:
            for i in range(extra_count):
                chosen_extras.append(extra_services[(variant + i) % len(extra_services)])
        return [base] + chosen_extras

    def _apply_services_and_total(self, order: Orders, services_list: list[Services]):
        """Attach services to order and, if order is completed, set total_price to the sum of service prices.
        Always sets total_price for completed orders, even if there are no services (sum = 0).
        """
        if services_list:
            order.services.add(*services_list)
        if order.status == OrderStatus.COMPLETED:
            total = sum(s.price for s in order.services.all())
            order.total_price = total
            order.save(update_fields=['total_price'])

    def _get_or_create_client(self, idx: int, password: str):
        """Create or get a demo client and ensure several cars.
        Returns a dict: { 'user': User, 'cars': [Car, ...], 'car_idx': int }
        """
        phone = f'+7701999{idx:03d}'
        name = f'Demo Client {idx:03d}'
        user = self._get_or_create_user(phone, name, password, is_verified=True)
        # Ensure multiple cars per client (2 or 3)
        cars = []
        for n in range(1, 3 + (1 if idx % 3 == 0 else 0)):
            plate = f'DEM-{idx:03d}-{n}'
            car, _ = Car.objects.get_or_create(owner=user, number=plate)
            cars.append(car)
        return {'user': user, 'cars': cars, 'car_idx': 0}

    @transaction.atomic
    def handle(self, *args, **options):
        # Fixed demo credentials and identities (no CLI args)
        password = 'password'
        primary_phone = '+77010000000'
        primary_username = 'Director Demo'

        # Owners
        owner1 = self._get_or_create_user(primary_phone, primary_username, password, is_verified=True)
        owner2 = self._get_or_create_user('+77010000002', 'Second Owner', password, is_verified=True)

        # Carwash A (active, 2 boxes)
        carwash_a, _ = CarWash.objects.get_or_create(owner=owner1, name='Carwash A', defaults={'address': 'Address A', 'is_active': True})
        if not carwash_a.is_active:
            carwash_a.is_active = True
            carwash_a.save(update_fields=['is_active'])
        self._ensure_boxes(carwash_a, 2)
        sedan_a = self._ensure_settings_and_services(carwash_a)

        # Carwash B (active, 4 boxes)
        carwash_b, _ = CarWash.objects.get_or_create(owner=owner1, name='Carwash B', defaults={'address': 'Address B', 'is_active': True})
        if not carwash_b.is_active:
            carwash_b.is_active = True
            carwash_b.save(update_fields=['is_active'])
        self._ensure_boxes(carwash_b, 4)
        sedan_b = self._ensure_settings_and_services(carwash_b)

        # Carwash C (inactive, no orders)
        carwash_c, _ = CarWash.objects.get_or_create(owner=owner2, name='Carwash C', defaults={'address': 'Address C', 'is_active': False})
        if carwash_c.is_active:
            carwash_c.is_active = False
            carwash_c.save(update_fields=['is_active'])
        self._ensure_boxes(carwash_c, 1)  # at least 1 to operate structure (no orders will be created)
        sedan_c = self._ensure_settings_and_services(carwash_c)

        # Staff users
        manager_a = self._get_or_create_user('+77010000010', 'Manager A', password, is_verified=True)
        manager_b = self._get_or_create_user('+77010000011', 'Manager B', password, is_verified=True)
        washer_a = self._get_or_create_user('+77010000020', 'Washer A', password, is_verified=True)
        washer_b = self._get_or_create_user('+77010000021', 'Washer B', password, is_verified=True)
        manager_c = self._get_or_create_user('+77010000012', 'Manager C', password, is_verified=True)
        washer_c = self._get_or_create_user('+77010000022', 'Washer C', password, is_verified=True)

        # Assign staff to car washes
        carwash_a.managers.add(manager_a)
        carwash_a.washers.add(washer_a)

        carwash_b.managers.add(manager_a, manager_b)
        carwash_b.washers.add(washer_a, washer_b)

        carwash_c.managers.add(manager_c)
        carwash_c.washers.add(washer_c)

        # Generate orders only once (idempotent) using Demo Client prefix
        now = timezone.now()

        def create_orders_for(car_wash: CarWash, sedan_type: CarType, in_progress_boxes: int, washers: list[User]):
            if Orders.objects.filter(car_wash=car_wash, user__username__startswith='Demo Client').exists():
                self.stdout.write(self.style.WARNING(f'{car_wash.name}: demo orders already exist, skipping creation'))
                return

            # Prepare clients (with multiple cars each)
            clients = [self._get_or_create_client(i, password) for i in range(1, 30)]
            service_variant = 0

            boxes = list(car_wash.boxes.order_by('name'))
            box_idx = 0
            client_idx = 0

            def next_client_car():
                nonlocal client_idx
                c = clients[client_idx % len(clients)]
                client_idx += 1
                # rotate through this client's cars as well
                car = c['cars'][c['car_idx'] % len(c['cars'])]
                c['car_idx'] = (c['car_idx'] + 1) % len(c['cars'])
                return c['user'], car

            # Extra historical orders: same user, same car, same car wash across different days
            # This ensures some users have repeated history with the exact same car at this car wash.
            special_clients = clients[:3]  # deterministically pick first three demo clients
            for sc_idx, c in enumerate(special_clients):
                user = c['user']
                car = c['cars'][0]  # always pick their first car for repeat history
                for k, days in enumerate([15, 12, 9]):  # three older orders
                    day = now - timedelta(days=days)
                    created_at = day.replace(hour=11 + (k % 3), minute=15, second=0, microsecond=0)
                    # alternate canceled/completed to diversify
                    if k == 1:
                        status = OrderStatus.CANCELED
                        started = None
                        finished_at = None
                    else:
                        status = OrderStatus.COMPLETED
                        started = created_at + timedelta(minutes=12)
                        finished_at = started + timedelta(minutes=38)
                    # assign box/washer if available for realism
                    box = boxes[(box_idx + sc_idx + k) % len(boxes)] if boxes else None
                    washer = washers[(sc_idx + k) % len(washers)] if washers else None
                    services_list = self._compose_services_for_order(car_wash, service_variant)
                    service_variant += 1
                    duration = sum((s.duration for s in services_list), start=timedelta(0))
                    order = Orders.objects.create(
                        user=user,
                        car_wash=car_wash,
                        car=car,
                        box=box,
                        washer=washer,
                        created_at=created_at,
                        started_at=started,
                        finished_at=finished_at,
                        status=status,
                        duration=duration,
                    )
                    self._apply_services_and_total(order, services_list)

            # Historical days: create a mix of completed and canceled orders
            for days_back in range(7, 1, -1):  # 7 to 2 days ago
                for _ in range(4):  # 4 orders per day
                    user, car = next_client_car()
                    box = boxes[box_idx % len(boxes)] if boxes else None
                    washer = washers[box_idx % len(washers)] if washers else None
                    box_idx += 1
                    day = now - timedelta(days=days_back)
                    created_at = day.replace(hour=10 + (_ % 3) * 2, minute=0, second=0, microsecond=0)
                    started_at = created_at + timedelta(minutes=10)
                    # alternate between completed and canceled
                    if _ % 3 == 2:
                        # canceled before start
                        status = OrderStatus.CANCELED
                        finished_at = None
                        started = None
                    else:
                        status = OrderStatus.COMPLETED
                        started = started_at
                        finished_at = started_at + timedelta(minutes=40 + (_ % 2) * 15)
                    services_list = self._compose_services_for_order(car_wash, service_variant)
                    service_variant += 1
                    duration = sum((s.duration for s in services_list), start=timedelta(0))
                    order = Orders.objects.create(
                        user=user,
                        car_wash=car_wash,
                        car=car,
                        box=box,
                        washer=washer,
                        created_at=created_at,
                        started_at=started,
                        finished_at=finished_at,
                        status=status,
                        duration=duration,
                    )
                    self._apply_services_and_total(order, services_list)

            # Recent completed this day
            for _ in range(3):
                user, car = next_client_car()
                box = boxes[box_idx % len(boxes)] if boxes else None
                box_idx += 1
                services_list = self._compose_services_for_order(car_wash, service_variant)
                service_variant += 1
                duration = sum((s.duration for s in services_list), start=timedelta(0))
                order = Orders.objects.create(
                    user=user,
                    car_wash=car_wash,
                    car=car,
                    box=box,
                    washer=washers[0] if washers else None,
                    created_at=now - timedelta(hours=4),
                    started_at=now - timedelta(hours=3, minutes=30),
                    finished_at=now - timedelta(hours=3),
                    status=OrderStatus.COMPLETED,
                    duration=duration,
                )
                self._apply_services_and_total(order, services_list)

            # In-progress orders (occupy distinct boxes and distinct cars)
            # Avoid any car that already has an in-progress order globally
            used_cars = set(Orders.objects.filter(status=OrderStatus.IN_PROGRESS).values_list('car_id', flat=True))
            for idx in range(in_progress_boxes):
                # ensure a new car not used for in-progress yet
                for _guard in range(200):
                    user, car = next_client_car()
                    if car.id not in used_cars:
                        used_cars.add(car.id)
                        break
                box = boxes[idx % len(boxes)] if boxes else None
                services_list = self._compose_services_for_order(car_wash, service_variant)
                service_variant += 1
                duration = sum((s.duration for s in services_list), start=timedelta(0))
                order = Orders.objects.create(
                    user=user,
                    car_wash=car_wash,
                    car=car,
                    box=box,
                    washer=washers[idx % len(washers)] if washers else None,
                    created_at=now - timedelta(hours=1),
                    started_at=now - timedelta(minutes=45),
                    status=OrderStatus.IN_PROGRESS,
                    duration=duration,
                )
                self._apply_services_and_total(order, services_list)

            # 3 en route + 3 on site
            for _ in range(3):
                user, car = next_client_car()
                services_list = self._compose_services_for_order(car_wash, service_variant)
                service_variant += 1
                duration = sum((s.duration for s in services_list), start=timedelta(0))
                order = Orders.objects.create(
                    user=user,
                    car_wash=car_wash,
                    car=car,
                    box=None,
                    status=OrderStatus.EN_ROUTE,
                    created_at=now - timedelta(minutes=25),
                    duration=duration,
                )
                self._apply_services_and_total(order, services_list)
                car_wash.add_to_queue(order)

            for _ in range(3):
                user, car = next_client_car()
                services_list = self._compose_services_for_order(car_wash, service_variant)
                service_variant += 1
                duration = sum((s.duration for s in services_list), start=timedelta(0))
                order = Orders.objects.create(
                    user=user,
                    car_wash=car_wash,
                    car=car,
                    box=None,
                    status=OrderStatus.ON_SITE,
                    created_at=now - timedelta(minutes=12),
                    duration=duration,
                )
                self._apply_services_and_total(order, services_list)
                car_wash.add_to_queue(order)

        create_orders_for(carwash_a, sedan_a, in_progress_boxes=2, washers=[washer_a])
        create_orders_for(carwash_b, sedan_b, in_progress_boxes=2, washers=[washer_a, washer_b])

        self.stdout.write(self.style.SUCCESS('Created demo data: car washes A, B with orders, and car wash C without orders.'))
