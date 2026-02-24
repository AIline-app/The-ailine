from django.urls import path, include
from rest_framework.routers import DefaultRouter

from api.rating.views import OrderReviewViewSet, CarWashRatingViewSet, CarWashReviewsViewSet
from iLine.constants import UUID_REGEX

router = DefaultRouter()
router.register(
    fr'car-wash/(?P<car_wash_id>{UUID_REGEX})/order/(?P<order_id>{UUID_REGEX})/review',
    OrderReviewViewSet,
    basename='car-wash-order-review',
)
router.register(
    fr'car-wash/(?P<car_wash_id>{UUID_REGEX})/rating',
    CarWashRatingViewSet,
    basename='car-wash-rating',
)
router.register(
    fr'car-wash/(?P<car_wash_id>{UUID_REGEX})/reviews',
    CarWashReviewsViewSet,
    basename='car-wash-reviews',
)

urlpatterns = [
    path('', include(router.urls)),
]
