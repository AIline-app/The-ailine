from datetime import timedelta
from django.db import transaction
from django.db.models import Q
from django.utils import timezone
from rest_framework.exceptions import ValidationError

from .models import Order, Service, ItemService
from app_washes.models import CarWash, Administrator
from app_adminwork.models import SlotsInWash
from AstSmartTime.constants import COMMISSION
from .serializers import notify_for_admin


@transaction.atomic
def create_order_for_new_user(*, customer, admin_user, washer_id: int, service_ids: list[int]) -> Order:
    """
    Создаёт заказ для только что созданного клиента.
    - car_wash берём из авторизованного администратора (admin_user).
      Если у админа несколько моек, берём первую (по id). При желании можно
      поменять стратегию (напр. обязательный car_wash_id).
    - washer_id — PK мойщика (как ожидает Order.washer).
    - service_ids — список PK услуг Service.

    Возвращает созданный Order.
    """

    # 1) Находим администратора по текущему юзеру.
    admin = Administrator.objects.filter(Q(boss=admin_user) | Q(phone=admin_user)).first()
    if not admin:
        raise ValidationError('Текущий пользователь не является администратором.')

    # 2) Определяем мойку. Если несколько — берём первую.
    car_wash = admin.wash.order_by('id').first()
    if not car_wash:
        raise ValidationError('За администратором не закреплена ни одна автомойка.')

    # 3) Проверка валидации мойки
    if car_wash.is_validate is False:
        raise ValidationError('Car Wash is not valid')

    # 4) Собираем услуги
    services = list(Service.objects.filter(id__in=service_ids))
    if not services:
        raise ValidationError('Список услуг пуст или невалиден.')

    # 5) Создаём заказ (без расчётов)
    new_order = Order.objects.create(
        customer=customer,
        car_wash=car_wash,
        washer_id=washer_id,
    )

    # 6) Позиции услуг + расчёт времени/стоимости
    time_work = 0
    price = 0
    for item in services:
        time_work += item.time_work
        price += item.price
        ItemService.objects.create(service=item, order=new_order)

    # 7) Расчёт time_start/time_end по логике очереди/слотов
    slots_qs = SlotsInWash.objects.select_for_update().filter(wash=car_wash).only('status')
    slots_count = slots_qs.count()
    free_slot_count = SlotsInWash.objects.filter(wash=car_wash, status='Free').count()

    active_qs = Order.objects.filter(
        car_wash=car_wash, status__in=['Reserve', 'In progress'], time_end__isnull=False
    ).order_by('-time_end')

    has_any_free = slots_qs.filter(status__in=['Free', None]).exists()
    reserve_count = Order.objects.filter(car_wash=car_wash, status='Reserve').count()

    if has_any_free and reserve_count <= free_slot_count:
        new_order.time_start = timezone.now() + timedelta(minutes=30)
    else:
        if active_qs.exists():
            idx = max(0, min(slots_count - 1, active_qs.count() - 1))
            last_candidate = active_qs[idx]
            if last_candidate.time_end < timezone.now():
                new_order.time_start = timezone.now() + timedelta(minutes=30)
            else:
                new_order.time_start = last_candidate.time_end
        else:
            new_order.time_start = timezone.now() + timedelta(minutes=30)

    new_order.time_work = time_work
    new_order.price = price
    new_order.time_end = new_order.time_start + timedelta(minutes=time_work)
    new_order.commission = (new_order.price / 100) * COMMISSION
    new_order.final_price = new_order.price + new_order.commission
    new_order.save()

    # 8) Обновляем last_time мойки
    active_now_qs = Order.objects.filter(
        car_wash=car_wash, status__in=['Reserve', 'In progress']
    ).order_by('-time_end')

    if active_now_qs.count() < car_wash.slots:
        car_wash.last_time = timezone.now()
    else:
        idx = max(0, min(slots_count - 1, active_now_qs.count() - 1))
        car_wash.last_time = active_now_qs[idx].time_end if active_now_qs else timezone.now()

    # 9) Нотификация (не роняем транзакцию, если упадёт)
    try:
        notify_for_admin(car_wash, f'Клиент с номером {customer.number_auto} встал в очередь')
    except Exception:
        pass

    car_wash.save()
    return new_order
