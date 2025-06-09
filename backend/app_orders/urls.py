from django.urls import path

from .views import OrderCreate, ListOrder, OrderDetail, OrderCallBackAPI, ListOrderIsReserve, PaymentAPI, OrderCancel

urlpatterns = [
    path('', ListOrder.as_view(), name='orders'),
    path('reserve/<int:pk>', ListOrderIsReserve.as_view(), name='reserve'),
    path('create', OrderCreate.as_view(), name='order_create'),
    path('<int:pk>', OrderDetail.as_view(), name='order_detail'),
    path('<int:pk>/payment', PaymentAPI.as_view(), name='payment_create'),
    path('<int:pk>/cancel', OrderCancel.as_view(), name='order_cancel'),
    path('callback', OrderCallBackAPI.as_view(), name='callback'),
]
