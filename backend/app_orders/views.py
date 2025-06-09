from datetime import timedelta
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import JSONParser, MultiPartParser
from rest_framework.response import Response
from django.utils.translation import gettext_lazy as _
from django.utils import timezone
from django.http import HttpResponseNotAllowed, HttpResponse
from AstSmartTime.settings import API_KEY

from .serializers import (OrderSerializer, Order, PaymentSerializers, OrderCancelSerializer,
                          CreateOrderSerializer, OrderCallBackSerializer, payment, encrypted_payment, PaymentData, two_stage_payment)
from .permissions import IsOwnerOnly
from app_adminwork.permissions import IsManager


class ListOrder(generics.ListAPIView):
    """Получение списка заказов."""
    permission_classes = (IsAuthenticated, IsOwnerOnly,)
    serializer_class = OrderSerializer

    def get_queryset(self):
        return Order.objects.filter(customer=self.request.user, rated=0, status__in=['Done', 'Reserve', 'In progress'])


class OrderCreate(generics.CreateAPIView):
    """Создание заказа."""
    serializer_class = CreateOrderSerializer
    parser_classes = (JSONParser, MultiPartParser)
    permission_classes = (IsAuthenticated,)

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            headers = self.get_success_headers(serializer.data)
            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED, headers=headers
            )
        else:
            return HttpResponseNotAllowed(_('Api key is not correct'))


class OrderDetail(generics.RetrieveUpdateDestroyAPIView):
    """Информация о заказе"""
    queryset = Order.objects.all()
    permission_classes = (IsAuthenticated,)
    http_method_names = ['get', 'put', 'patch', 'delete']
    serializer_class = OrderSerializer

    def get(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().get(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def put(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().put(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def patch(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            return super().patch(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))

    def delete(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:

            return super().delete(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class OrderCancel(generics.RetrieveUpdateDestroyAPIView):
    """Отмена заказа"""
    queryset = Order.objects.all()
    permission_classes = (IsAuthenticated, IsOwnerOnly,)
    http_method_names = ['put']
    serializer_class = OrderCancelSerializer

    def put(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            two_stage_payment(
                id_payment=PaymentData.objects.get(order=self.kwargs['pk']).id_payment,
                action="reject"
            )
            return super().put(request)
        else:
            return HttpResponseNotAllowed(_('Give me correct api key'))


class ListOrderIsReserve(generics.ListAPIView):
    """Получение админом списка заказов со статусом Reserve по конкретной мойке."""
    permission_classes = (IsAuthenticated, IsManager, )
    serializer_class = OrderSerializer

    def get_queryset(self):
        return Order.objects.filter(status='Reserve', payment_status='Created', car_wash_id=self.kwargs['pk']).order_by('time_start')


class OrderCallBackAPI(generics.GenericAPIView):
    """Коллбек об оплате."""
    serializer_class = OrderCallBackSerializer
    permission_classes = (AllowAny,)
    parser_classes = (JSONParser, MultiPartParser)
    http_method_names = ['post']

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            raise ValidationError(serializer.errors)

        return Response(data={"accepted": True})


class PaymentAPI(generics.CreateAPIView):
    """Произведение оплаты за заказ"""
    serializer_class = PaymentSerializers
    permission_classes = (IsAuthenticated, IsOwnerOnly,)
    parser_classes = (JSONParser, MultiPartParser)
    http_method_names = ['post', 'put', 'delete']

    def post(self, request, *args, **kwargs):
        if request.headers['api_key'] == API_KEY:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            headers = self.get_success_headers(serializer.data)
            order = Order.objects.get(id=self.kwargs['pk'])
            if 'id_card' not in serializer.data:
                payment_data = {
                    "cardholder": (serializer.data["owner"]).lower(),
                    "month": serializer.data["end_date"][:2],
                    "pan": serializer.data["number"],
                    "validity": serializer.data["end_date"],
                    "year": "20" + serializer.data["end_date"][-2:],
                    "cvv": request.data["cvv"]
                }
                data = payment(
                    order_id=order.id,
                    amount=order.final_price,
                    if_save=serializer.data['if_save'],
                    last_number=f'{serializer.data["number"][:6] + "******" + serializer.data["number"][-4:]}',
                    id_card=None,
                    card_data=encrypted_payment(message=payment_data),
                )
            else:
                id_card = serializer.data['id_card']
                data = payment(
                    order_id=order.id,
                    amount=order.final_price,
                    card_data=None,
                    if_save=None,
                    last_number=None,
                    id_card=id_card
                )

            if timezone.now() > order.date_create + timedelta(minutes=10):
                order.status = 'Canceled'
                order.payment_status = 'Timeout'
                order.save()
                return HttpResponse('Время вышло. Пожалуйста, создайте новый заказ.')
            # print(base64.b64encode(encrypted_payment(message=payment_data)))
            order.payment_status = 'Sent'
            order.save()
            return Response(
                data,
                status=status.HTTP_201_CREATED, headers=headers
            )
        else:
            return HttpResponseNotAllowed(_('Api key is not correct'))
