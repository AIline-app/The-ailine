from django.shortcuts import get_object_or_404
from rest_framework import mixins, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from api.car_wash.permissions import ReadOnly
from api.car_wash.views import CarWashInRouteMixin
from api.orders.permissions import IsOrderOwner
from api.rating.serializers import (
    UserReviewWriteSerializer,
    UserReviewReadSerializer,
    CarWashRatingSerializer,
)
from orders.models import Orders
from rating.models import Rating, UserReview


class OrderReviewViewSet(CarWashInRouteMixin,
                         mixins.CreateModelMixin,
                         mixins.RetrieveModelMixin,
                         GenericViewSet,
                         ):
    """Create a review for the user's completed order. No updates allowed."""
    permission_classes = (IsOrderOwner,)
    serializer_class = UserReviewWriteSerializer

    def get_queryset(self):

        return self.request.user.reviews.all()

    def get_serializer_context(self):

        ctx = super().get_serializer_context()
        ctx['order'] = get_object_or_404(Orders, pk=self.kwargs['order_id'])
        return ctx
    #
    # def create(self, request, *args, **kwargs):
    #     order = get_object_or_404(Orders, pk=self.kwargs['order_id'])
    #     # Prevent duplicate reviews (OneToOneField on order enforces, but we return 400 gracefully)
    #     if hasattr(order, 'review'):
    #         return Response({'detail': 'Review already exists for this order.'}, status=status.HTTP_400_BAD_REQUEST)
    #     serializer = self.get_serializer(data=request.data)
    #     serializer.is_valid(raise_exception=True)
    #     instance = serializer.save()
    #     return Response(UserReviewReadSerializer(instance, context=self.get_serializer_context()).data, status=status.HTTP_201_CREATED)
    #

class CarWashRatingViewSet(CarWashInRouteMixin, GenericViewSet):
    """Get current rating (count, average) of the car wash."""
    permission_classes = (IsAuthenticated,)

    def list(self, request, *args, **kwargs):
        rating, _ = Rating.objects.get_or_create(car_wash=self.car_wash)
        return Response(CarWashRatingSerializer(rating).data, status=status.HTTP_200_OK)


class CarWashReviewsViewSet(CarWashInRouteMixin, mixins.ListModelMixin, GenericViewSet):
    """List user reviews for the car wash."""
    permission_classes = (IsAuthenticated,)
    serializer_class = UserReviewReadSerializer

    def get_queryset(self):
        return UserReview.objects.filter(order__car_wash=self.car_wash).select_related('order', 'user')
