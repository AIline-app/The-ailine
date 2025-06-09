from datetime import timedelta
from collections import defaultdict

from rest_framework import generics
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import AllowAny
from django.http import HttpResponseNotAllowed
from django.utils.translation import gettext_lazy as _
from django.utils import timezone

from AstSmartTime.settings import API_KEY
from app_washes.models import CarWash, Administrator
from app_orders.models import Order
from .serializers import (SlotSerializers, AdminCarWashDetailSerializer,
                          AdminListCarWashSerializer, ArchiveListOrders)
from .models import SlotsInWash
from .permissions import IsManager


class SlotInProgress(generics.UpdateAPIView):
    """Вьюсет для добавления заказа в слот мойки"""
    queryset = SlotsInWash.objects.all().order_by('id')
    permission_classes = (IsManager,)
    serializer_class = SlotSerializers
    http_method_names = ['put']

    def put(self, request, *args, **kwargs):  # по возможности ничего не трогать. Всё работает!
        if request.headers['api_key'] == API_KEY:
            pk = kwargs.get('pk')
            instance = SlotsInWash.objects.get(pk=pk)
            serializer = SlotSerializers(data=request.data, instance=instance)
            wash = CarWash.objects.get(pk=self.kwargs['wash_id'])
            serializer.is_valid(raise_exception=True)
            serializer.save()
            if request.data['status'] != 'Free':
                orders = Order.objects.filter(status='Reserve', car_wash=wash).order_by('time_end')
                slots = SlotsInWash.objects.filter(wash=wash)
                count_slots = []
                for slot in slots:
                    try:
                        count_slots.append(slot.order.time_end)
                    except AttributeError:
                        count_slots.append(timezone.now())
                for order in orders:
                    time = timezone.now() + timedelta(days=10000)
                    for slot in count_slots:
                        if slot < time:
                            time = slot  # самое раннее время
                    order.time_start = time
                    order.time_end = time + timedelta(minutes=order.time_work)
                    order.save()
                    for slot in range(len(count_slots)):
                        if count_slots[slot] == time:
                            count_slots[slot] += timedelta(minutes=order.time_work)
                            break
                last_order = Order.objects.filter(car_wash=wash, status__in=['Reserve', 'In progress']).order_by('-time_end')

                if len(last_order) < wash.slots:  # Если заказов в слотах и в очереди меньше количества слотов у мойки
                    wash.last_time = timezone.now()
                else:
                    wash.last_time = last_order[len(slots) - 1].time_end
            return super().put(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class AdminWashDetail(generics.RetrieveAPIView):
    """Получение админом информации о мойке"""
    queryset = CarWash.objects.all()
    permission_classes = (IsManager,)
    serializer_class = AdminCarWashDetailSerializer
    http_method_names = ['get']


class AdminWashList(generics.ListAPIView):
    permission_classes = (IsManager,)
    serializer_class = AdminListCarWashSerializer
    http_method_names = ['get']

    def get_queryset(self):
        return Administrator.objects.get(phone=self.request.user.phone).wash.all()


class ArchiveOrderForAdmin(generics.ListAPIView):
    permission_classes = (AllowAny,)
    pagination_class = PageNumberPagination
    serializer_class = ArchiveListOrders

    def get_queryset(self):
        date_from = self.request.GET.get('created_from')
        date_to = self.request.GET.get('created_to')
        box = self.request.GET.get('box_id')
        wash = Administrator.objects.get(phone=self.request.user.phone).wash.all()[0]
        queryset = Order.objects.filter(car_wash=wash, status='Done', payment_status='Fulfilled').order_by('-date_create')
        if date_from is not None:
            date_from = timezone.datetime.strptime(date_from, '%Y-%m-%d').date()
            date_to = timezone.datetime.strptime(date_to, '%Y-%m-%d').date()
            queryset = queryset.filter(date_create__gte=date_from, date_create__lte=date_to)
            if box is not None:
                queryset = queryset.filter(box_id=box)
        if box is not None:
            queryset = queryset.filter(box_id=box)

        return queryset
