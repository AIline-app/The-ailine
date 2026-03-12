import json
from datetime import timedelta, datetime
from typing import Dict, Any, List

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils.timezone import now

from accounts.models import User
from car_wash.models import Car, Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarType
from orders.models import Orders
from orders.models.queue import QueueEntry
from orders.utils.enums import OrderStatus
from services.models import Services
from rating.models import Rating, UserReview


DEFAULT_DATA = {
    "key": "demo-wash-001",
    "car_wash": {
        "name": "Royal Crystal Wash Almaty",
        "address": "г. Алматы, проспект Назарбаева 223, уг. ул. Сатпаева (центр города, деловой район)",
        "location": "43.23249481139736, 76.94839346016137",
        "is_active": True,
        "boxes": 8,
        "settings": {
            "opens_at": "08:00",
            "closes_at": "23:00",
            "percent_washers": 40,
            "car_types": [
                {"name": "Легковой автомобиль", "description": "седан / хэтчбек"},
                {"name": "Бизнес-класс", "description": "E-class, Camry, Sonata и аналог"},
                {"name": "Кроссовер", "description": "RAV4, Sportage, Tucson и аналог"},
                {"name": "Внедорожник", "description": "Land Cruiser, Prado, Patrol и аналог"},
                {"name": "Премиум SUV", "description": "Range Rover, GLS, Escalade и аналог"},
            ],
        },
        "documents": {
            "iin": "123456789012",
            "legal_address": "г. Алматы, проспект Назарбаева 223, уг. ул. Сатпаева (центр города, деловой район)"
        }
    },
    "users": {
        "owner": {"username": "Алькей Аманжолов", "phone_number": "+77071112200", "password": "ownerpass"},
        "managers": [
            {"username": "Менеджер", "phone_number": "+77071112301", "password": "managerpass"}
        ],
        "washers": [
            {"username": "Ержан Садыков", "phone_number": "+77071112201", "password": "washerpass"},
            {"username": "Нурлан Ахметов", "phone_number": "+77071112202", "password": "washerpass"},
            {"username": "Данияр Бекенов", "phone_number": "+77071112203", "password": "washerpass"},
            {"username": "Арман Касымов", "phone_number": "+77071112204", "password": "washerpass"},
            {"username": "Айдос Турсынов", "phone_number": "+77071112205", "password": "washerpass"},
            {"username": "Бауыржан Сейтжанов", "phone_number": "+77071112206", "password": "washerpass"},
            {"username": "Мадияр Жумабеков", "phone_number": "+77071112207", "password": "washerpass"},
            {"username": "Руслан Абилов", "phone_number": "+77071112208", "password": "washerpass"},
        ],
        "customers": [
            {"username": "Егор Сорокин", "phone_number": "+77071112401", "password": "custpass", "cars": ["777AAA02", "909BMV02"]},
            {"username": "Иван Иванов", "phone_number": "+77071112402", "password": "custpass", "cars": ["505KZ02" ]},
            {"username": "Тестовый Клиент 1", "phone_number": "+77071112403", "password": "custpass", "cars": ["101LEX02" ]},
            {"username": "Тестовый Клиент 2", "phone_number": "+77071112404", "password": "custpass", "cars": ["888VIP02" ]},
        ],
    },
    "services": [
        {
            "name": "Экспресс-мойка кузова",
            "description": "Стандартная быстрая мойка",
            "price": 3_500,
            "duration_minutes": 30,
            "car_type": "Легковой автомобиль",
            "is_extra": False,
        },
        {
            "name": "Экспресс-мойка кузова",
            "description": "Стандартная быстрая мойка",
            "price": 4_000,
            "duration_minutes": 35,
            "car_type": "Бизнес-класс",
            "is_extra": False,
        },
        {
            "name": "Экспресс-мойка кузова",
            "description": "Стандартная быстрая мойка",
            "price": 4_500,
            "duration_minutes": 35,
            "car_type": "Кроссовер",
            "is_extra": False,
        },
        {
            "name": "Экспресс-мойка кузова",
            "description": "Стандартная быстрая мойка",
            "price": 5_000,
            "duration_minutes": 40,
            "car_type": "Внедорожник",
            "is_extra": False,
        },
        {
            "name": "Экспресс-мойка кузова",
            "description": "Стандартная быстрая мойка",
            "price": 6_000,
            "duration_minutes": 45,
            "car_type": "Премиум SUV",
            "is_extra": False,
        },

        {
            "name": "Комплексная мойка",
            "description": "кузов + салон",
            "price": 6_500,
            "duration_minutes": 60,
            "car_type": "Легковой автомобиль",
            "is_extra": False,
        },
        {
            "name": "Комплексная мойка",
            "description": "кузов + салон",
            "price": 7_000,
            "duration_minutes": 65,
            "car_type": "Бизнес-класс",
            "is_extra": False,
        },
        {
            "name": "Комплексная мойка",
            "description": "кузов + салон",
            "price": 8_000,
            "duration_minutes": 70,
            "car_type": "Кроссовер",
            "is_extra": False,
        },
        {
            "name": "Комплексная мойка",
            "description": "кузов + салон",
            "price": 9_000,
            "duration_minutes": 75,
            "car_type": "Внедорожник",
            "is_extra": False,
        },
        {
            "name": "Комплексная мойка",
            "description": "кузов + салон",
            "price": 11_000,
            "duration_minutes": 80,
            "car_type": "Премиум SUV",
            "is_extra": False,
        },

        {
            "name": "Глубокая комплексная мойка",
            "description": "кузов + салон",
            "price": 9_000,
            "duration_minutes": 90,
            "car_type": "Легковой автомобиль",
            "is_extra": False,
        },
        {
            "name": "Глубокая комплексная мойка",
            "description": "кузов + салон",
            "price": 10_000,
            "duration_minutes": 90,
            "car_type": "Бизнес-класс",
            "is_extra": False,
        },
        {
            "name": "Глубокая комплексная мойка",
            "description": "кузов + салон",
            "price": 12_000,
            "duration_minutes": 90,
            "car_type": "Кроссовер",
            "is_extra": False,
        },
        {
            "name": "Глубокая комплексная мойка",
            "description": "кузов + салон",
            "price": 14_000,
            "duration_minutes": 90,
            "car_type": "Внедорожник",
            "is_extra": False,
        },
        {
            "name": "Глубокая комплексная мойка",
            "description": "кузов + салон",
            "price": 16_000,
            "duration_minutes": 90,
            "car_type": "Премиум SUV",
            "is_extra": False,
        },

        {
            "name": "Нанесение жидкого воска",
            "description": "",
            "price": 3_000,
            "duration_minutes": 20,
            "car_type": "Легковой автомобиль",
            "is_extra": True,
        },
        {
            "name": "Нанесение жидкого воска",
            "description": "",
            "price": 3_500,
            "duration_minutes": 20,
            "car_type": "Бизнес-класс",
            "is_extra": True,
        },
        {
            "name": "Нанесение жидкого воска",
            "description": "",
            "price": 4_000,
            "duration_minutes": 25,
            "car_type": "Кроссовер",
            "is_extra": True,
        },
        {
            "name": "Нанесение жидкого воска",
            "description": "",
            "price": 4_500,
            "duration_minutes": 25,
            "car_type": "Внедорожник",
            "is_extra": True,
        },
        {
            "name": "Нанесение жидкого воска",
            "description": "",
            "price": 5_000,
            "duration_minutes": 30,
            "car_type": "Премиум SUV",
            "is_extra": True,
        },

        {
            "name": "Чернение резины",
            "description": "",
            "price": 2_000,
            "duration_minutes": 10,
            "car_type": "Легковой автомобиль",
            "is_extra": True,
        },
        {
            "name": "Чернение резины",
            "description": "",
            "price": 2_500,
            "duration_minutes": 10,
            "car_type": "Бизнес-класс",
            "is_extra": True,
        },
        {
            "name": "Чернение резины",
            "description": "",
            "price": 3_000,
            "duration_minutes": 15,
            "car_type": "Кроссовер",
            "is_extra": True,
        },
        {
            "name": "Чернение резины",
            "description": "",
            "price": 3_500,
            "duration_minutes": 15,
            "car_type": "Внедорожник",
            "is_extra": True,
        },
        {
            "name": "Чернение резины",
            "description": "",
            "price": 4_000,
            "duration_minutes": 20,
            "car_type": "Премиум SUV",
            "is_extra": True,
        },

        {
            "name": "Химчистка сидений",
            "description": "",
            "price": 8_000,
            "duration_minutes": 60,
            "car_type": "Легковой автомобиль",
            "is_extra": True,
        },
        {
            "name": "Химчистка сидений",
            "description": "",
            "price": 9_000,
            "duration_minutes": 60,
            "car_type": "Бизнес-класс",
            "is_extra": True,
        },
        {
            "name": "Химчистка сидений",
            "description": "",
            "price": 10_000,
            "duration_minutes": 70,
            "car_type": "Кроссовер",
            "is_extra": True,
        },
        {
            "name": "Химчистка сидений",
            "description": "",
            "price": 11_000,
            "duration_minutes": 70,
            "car_type": "Внедорожник",
            "is_extra": True,
        },
        {
            "name": "Химчистка сидений",
            "description": "",
            "price": 12_000,
            "duration_minutes": 80,
            "car_type": "Премиум SUV",
            "is_extra": True,
        },

        {
            "name": "Озонация салона",
            "description": "",
            "price": 3_500,
            "duration_minutes": 20,
            "car_type": "Легковой автомобиль",
            "is_extra": True,
        },
        {
            "name": "Озонация салона",
            "description": "",
            "price": 4_000,
            "duration_minutes": 20,
            "car_type": "Бизнес-класс",
            "is_extra": True,
        },
        {
            "name": "Озонация салона",
            "description": "",
            "price": 4_500,
            "duration_minutes": 25,
            "car_type": "Кроссовер",
            "is_extra": True,
        },
        {
            "name": "Озонация салона",
            "description": "",
            "price": 5_000,
            "duration_minutes": 25,
            "car_type": "Внедорожник",
            "is_extra": True,
        },
        {
            "name": "Озонация салона",
            "description": "",
            "price": 5_500,
            "duration_minutes": 30,
            "car_type": "Премиум SUV",
            "is_extra": True,
        },
    ],
    "orders": [
        {
            "customer_phone": "+77071112401",
            "car_number": "777AAA02",
            "car_type": "Бизнес-класс",
            "services": ["Комплексная мойка"],
            "status": "on_site",
            "created_offset_min": -10,
        },
        {
            "customer_phone": "+77071112402",
            "car_number": "505KZ02",
            "car_type": "Кроссовер",
            "services": ["Экспресс-мойка"],
            "status": "en_route",
            "created_offset_min": -120,
        },
        {
            "customer_phone": "+77071112403",
            "car_number": "101LEX02",
            "car_type": "Премиум SUV",
            "services": ["Комплексная мойка"],
            "status": "in_progress",
            "box": 3,
            "washer_phone": "+77071112201",
            "created_offset_min": -100,
            "started_offset_min": -20,
        },
        {
            "customer_phone": "+77071112404",
            "car_number": "888VIP02",
            "car_type": "Внедорожник",
            "services": ["Глубокая комплексная мойка"],
            "status": "in_progress",
            "box": 6,
            "washer_phone": "+77071112202",
            "created_offset_min": -60,
            "started_offset_min": -40,
        },
        {
            "customer_phone": "+77071112401",
            "car_number": "909BMV02",
            "car_type": "Бизнес-класс",
            "services": ["Глубокая комплексная мойка"],
            "status": "completed",
            "created_offset_min": -60*24*5,
            "with_review": True,
            "rating": 5
        }
    ]
}


class Command(BaseCommand):
    help = "Create a demo car wash with users, services, orders, and optional reviews. Idempotent by car wash name and owner."

    def add_arguments(self, parser):
        parser.add_argument('--config', type=str, help='Path to JSON config describing the demo data')
        parser.add_argument('--key', type=str, help='Unique key to ensure idempotency (defaults to demo-wash-001)')
        parser.add_argument('--name', type=str, help='Override car wash name')
        parser.add_argument('--boxes', type=int, help='Number of boxes to create or ensure exist')
        parser.add_argument('--with-reviews', action='store_true', help='Force creation of reviews when possible')

    def handle(self, *args, **options):
        try:
            data = self._load_data(options)
        except Exception as exc:
            raise CommandError(f"Failed to load data: {exc}")

        with transaction.atomic():
            summary = self._create_demo(data, with_reviews=options.get('with_reviews', False), boxes_override=options.get('boxes'))

        self.stdout.write(self.style.SUCCESS("Demo car wash created/ensured successfully."))
        for k, v in summary.items():
            self.stdout.write(f"{k}: {v}")

    def _load_data(self, options) -> Dict[str, Any]:
        if options.get('config'):
            with open(options['config'], 'r', encoding='utf-8') as f:
                data = json.load(f)
        else:
            data = json.loads(json.dumps(DEFAULT_DATA))  # deep copy

        if options.get('key'):
            data['key'] = options['key']
        if options.get('name'):
            data['car_wash']['name'] = options['name']
        if options.get('boxes'):
            data['car_wash']['boxes'] = int(options['boxes'])
        return data

    def _get_or_create_user(self, username: str, phone: str, password: str) -> User:
        user = User.objects.create_user(
            username=username,
            phone_number=phone,
            password=password,
            is_active=True,
            is_verified=True,
        )
        # if not created:
        #     changed = False
        #     if username and user.username != username:
        #         user.username = username
        #         changed = True
        #     if password and user.password != password:
        #         user.password = password
        #         changed = True
        #     if not user.is_verified:
        #         user.is_verified = True
        #         changed = True
        #     if changed:
        #         user.save(update_fields=['username', 'password', 'is_verified'])
        return user

    def _ensure_boxes(self, cw: CarWash, amount: int) -> int:
        existing = cw.boxes.count()
        to_add = max(amount - existing, 0)
        if to_add:
            Box.objects.bulk_create(Box(car_wash=cw, name=f'Box #{existing + i + 1}') for i in range(to_add))
        return cw.boxes.count()

    def _ensure_settings(self, cw: CarWash, settings: Dict[str, Any]) -> CarWashSettings:
        car_types_data = settings.get('car_types', [])
        opens_at = settings.get('opens_at', '09:00')
        closes_at = settings.get('closes_at', '21:00')
        percent_washers = settings.get('percent_washers', 20)
        if hasattr(cw, 'settings'):
            cws = cw.settings
            fields_to_update = []
            if str(cws.opens_at) != opens_at:
                cws.opens_at = opens_at
                fields_to_update.append('opens_at')
            if str(cws.closes_at) != closes_at:
                cws.closes_at = closes_at
                fields_to_update.append('closes_at')
            if cws.percent_washers != percent_washers:
                cws.percent_washers = percent_washers
                fields_to_update.append('percent_washers')
            if fields_to_update:
                cws.save(update_fields=fields_to_update)
        else:
            cws = CarWashSettings.objects.create(car_wash=cw, opens_at=opens_at, closes_at=closes_at, percent_washers=percent_washers)
        # Ensure car types
        existing_types = {ct.name: ct for ct in cws.car_types.all()}
        for ct in car_types_data:
            if ct['name'] not in existing_types:
                CarType.objects.create(settings=cws, name=ct['name'], description=ct.get('description', ''))
        return cws

    def _ensure_documents(self, cw: CarWash, documents: Dict[str, Any]) -> CarWashDocuments:
        iin = documents.get('iin')
        legal_address = documents.get('legal_address')
        if hasattr(cw, 'documents'):
            docs = cw.documents
            fields_to_update = []
            if docs.iin != iin:
                docs.iin = iin
                fields_to_update.append('iin')
            if docs.legal_address != legal_address:
                docs.legal_address = legal_address
                fields_to_update.append('legal_address')
            docs.save(update_fields=fields_to_update)
        else:
            docs = CarWashDocuments.objects.create(car_wash=cw, iin=iin, legal_address=legal_address)
        return docs

    def _ensure_services(self, cw: CarWash, services: List[Dict[str, Any]]):
        car_type_map = {ct.name: ct.id for ct in cw.settings.car_types.all()}
        for srv in services:
            ct_name = srv['car_type']
            if ct_name not in car_type_map:
                # skip if car type not found
                continue
            duration = timedelta(minutes=int(srv.get('duration_minutes', 15)))
            is_extra = bool(srv.get('is_extra', False))
            Services.objects.get_or_create(
                car_wash=cw,
                car_type_id=car_type_map[ct_name],
                name=srv['name'],
                defaults={
                    'description': srv.get('description', ''),
                    'price': int(srv.get('price', 0)),
                    'duration': duration,
                    'is_extra': is_extra,
                }
            )

    def _create_demo(self, data: Dict[str, Any], with_reviews: bool, boxes_override: int = None) -> Dict[str, Any]:
        summary = {"users": 0, "boxes": 0, "services": 0, "orders": 0, "reviews": 0}

        # Users
        owner_data = data['users']['owner']
        owner = self._get_or_create_user(owner_data['username'], owner_data['phone_number'], owner_data['password'])
        summary["users"] += 1

        manager_users = []
        for m in data['users'].get('managers', []):
            manager_users.append(self._get_or_create_user(m['username'], m['phone_number'], m['password']))
            summary["users"] += 1

        washer_users = []
        for w in data['users'].get('washers', []):
            washer_users.append(self._get_or_create_user(w['username'], w['phone_number'], w['password']))
            summary["users"] += 1

        customer_users = []
        for c in data['users'].get('customers', []):
            cu = self._get_or_create_user(c['username'], c['phone_number'], c['password'])
            customer_users.append((cu, c.get('cars', [])))
            summary["users"] += 1

        # Car wash
        cw_data = data['car_wash']
        boxes_num = boxes_override if boxes_override is not None else int(cw_data.get('boxes', 1))


        cw = CarWash.objects.create(
            owner=owner,
            name=cw_data['name'],
            address=cw_data.get('address', ''),
            location=cw_data.get('location', ''),
            is_active=bool(cw_data.get('is_active', False)),
        )
        cw.initialize(
            settings_data=cw_data.get('settings', {}),
            documents_data=cw_data.get('documents', {}),
            boxes_amount=boxes_num
        )

        # Ensure M2M relations
        if manager_users:
            cw.managers.set(manager_users)
        if washer_users:
            cw.washers.set(washer_users)

        # Settings, documents, boxes
        self._ensure_settings(cw, cw_data.get('settings', {}))
        self._ensure_documents(cw, cw_data.get('documents', {}))
        summary["boxes"] = self._ensure_boxes(cw, boxes_num)

        # Cars for customers
        car_map = {}  # (owner_id, plate) -> Car
        for cu, cars in customer_users:
            for plate in cars:
                car, _ = Car.objects.get_or_create(owner=cu, number=plate)
                car_map[(cu.id, plate)] = car

        # Services
        self._ensure_services(cw, data.get('services', []))
        summary["services"] = cw.services.count()

        # Orders
        box_list = list(cw.boxes.all())
        service_by_name_and_type = {}
        for s in cw.services.all():
            service_by_name_and_type[(s.name, s.car_type.name)] = s

        rating_agg = []
        for ord_data in data.get('orders', []):
            customer = User.objects.get(phone_number=ord_data['customer_phone'])
            car = car_map.get((customer.id, ord_data['car_number']))
            if not car:
                car, _ = Car.objects.get_or_create(owner=customer, number=ord_data['car_number'])
            services_objs = []
            for srv_name in ord_data.get('services', []):
                key = (srv_name, ord_data.get('car_type'))
                if key in service_by_name_and_type:
                    services_objs.append(service_by_name_and_type[key])

            # pick box (1-based index in config)
            box_idx = max(min(int(ord_data.get('box', 1)) - 1, len(box_list) - 1), 0) if box_list else None
            box = box_list[box_idx] if box_list else None
            washer = None
            if ord_data.get('washer_phone'):
                washer = User.objects.get(phone_number=ord_data['washer_phone'])

            created_at = now() + timedelta(minutes=int(ord_data.get('created_offset_min', -5)))
            started_at = None
            finished_at = None
            if 'started_offset_min' in ord_data:
                started_at = now() + timedelta(minutes=int(ord_data['started_offset_min']))
            if 'finished_offset_min' in ord_data:
                finished_at = now() + timedelta(minutes=int(ord_data['finished_offset_min']))

            # Calculate total duration and price from services
            total_duration = sum((s.duration for s in services_objs), timedelta(0)) or timedelta(minutes=15)
            total_price = sum((s.price for s in services_objs), 0) or 0

            order = Orders.objects.create(
                user=customer,
                car_wash=cw,
                car=car,
                box=box,
                washer=washer,
                created_at=created_at,
                started_at=started_at,
                finished_at=finished_at,
                total_price=total_price,
                duration=total_duration,
                status=ord_data.get('status', OrderStatus.EN_ROUTE),
            )
            if services_objs:
                order.services.set(services_objs)

            summary["orders"] += 1

            # Queue entries for waiting orders
            if order.status in (OrderStatus.EN_ROUTE, OrderStatus.ON_SITE):
                order.car_wash.add_to_queue(order)

            # Completed review
            if (with_reviews or ord_data.get('with_review')) and order.status == OrderStatus.COMPLETED:
                rating_value = int(ord_data.get('rating', 5))
                if not hasattr(order, 'review'):
                    UserReview.objects.create(user=customer, order=order, rating=rating_value)
                    rating_agg.append(rating_value)

        # Rating aggregation
        if rating_agg:
            rating_obj, _ = Rating.objects.get_or_create(car_wash=cw)
            # Recalculate using all existing reviews for that wash
            all_reviews = UserReview.objects.filter(order__car_wash=cw)
            count = all_reviews.count()
            avg = 0
            if count:
                avg = round(sum(r.rating for r in all_reviews) / count, 2)
            rating_obj.count = count
            rating_obj.average = avg
            rating_obj.save(update_fields=['count', 'average'])
            summary["reviews"] = count

        return summary
