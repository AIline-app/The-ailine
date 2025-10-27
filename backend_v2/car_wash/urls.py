from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.car_wash.views import CarWashViewSet, CarViewSet, BoxViewSet

router = DefaultRouter()
router.register(r'carwash', CarWashViewSet, basename='car-wash')
router.register(r"user/car", CarViewSet, basename="user-car")

urlpatterns = [
    path("", include(router.urls)),
    path('carwash/<uuid:carwash_id>/boxes/', BoxViewSet.as_view({
        'get': 'list',
        'post': 'create'
    }), name='car-wash-boxes-list'),
    path('carwash/<uuid:carwash_id>/boxes/<uuid:box_id>/', BoxViewSet.as_view({
        'get': 'retrieve',
        'put': 'update',
        'patch': 'partial_update',
        'delete': 'destroy'
    }), name='car-wash-boxes-detail'),
]
