from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.orders.views import OrdersViewSet
from iLine.constants import UUID_REGEX

router = DefaultRouter()
router.register(
    fr'car-wash/(?P<car_wash_id>{UUID_REGEX})/order',
    OrdersViewSet,
    basename='car-wash-user-orders',
)

urlpatterns = [
    path('', include(router.urls)),
]
