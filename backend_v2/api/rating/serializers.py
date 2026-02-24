from django.db.models import Count, Sum
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from rating.models import UserReview, Rating
from orders.models import Orders
from orders.utils.enums import OrderStatus


class UserReviewReadSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user_id')
    order = serializers.ReadOnlyField(source='order_id')
    # user = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=User.objects.all())
    # order = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=User.objects.all())

    class Meta:
        model = UserReview
        fields = ('id', 'user', 'order', 'rating')


class UserReviewWriteSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())
    rating = serializers.IntegerField(min_value=1, max_value=5)
    # review = serializers.CharField(max_length=500, allow_blank=True)

    class Meta:
        model = UserReview
        fields = ('rating', 'user')

    def validate(self, attrs):
        request = self.context['request']
        order: Orders = self.context['order']
        car_wash = self.context['car_wash']

        # Ownership
        if order.user != request.user:
            raise serializers.ValidationError(_('You can review only your own orders'))  # TODO Throw 404
        # Belongs to car wash in route
        if order.car_wash_id != car_wash.id:
            raise serializers.ValidationError(_('Order does not belong to this car wash'))  # TODO Throw 404
        # Completed status only
        if order.status != OrderStatus.COMPLETED:
            raise serializers.ValidationError(_('You can review only completed orders'))
        return attrs

    def create(self, validated_data):
        request = self.context['request']
        order: Orders = self.context['order']
        instance = UserReview.objects.create(user=request.user, order=order, **validated_data)
        self._update_rating(order)
        return instance

    def update(self, instance, validated_data):
        for k, v in validated_data.items():
            setattr(instance, k, v)
        instance.save()
        self._update_rating(instance.order)
        return instance

    def to_representation(self, instance):
        return UserReviewReadSerializer(instance, context=self.context).data

    @staticmethod
    def _update_rating(order: Orders):
        # Make smarter
        car_wash = order.car_wash
        agg = UserReview.objects.filter(order__car_wash=car_wash).aggregate(cnt=Count('id'), total=Sum('rating'))
        cnt = agg['cnt'] or 0
        avg = float(agg['total']) / cnt if cnt else 0.0
        rating_obj, _ = Rating.objects.get_or_create(car_wash=car_wash, defaults={'count': cnt, 'average': avg})
        if rating_obj.count != cnt or rating_obj.average != avg:
            rating_obj.count = cnt
            rating_obj.average = avg
            rating_obj.save(update_fields=['count', 'average'])


class CarWashRatingSerializer(serializers.ModelSerializer):
    car_wash = serializers.UUIDField(source='car_wash_id', read_only=True)

    class Meta:
        model = Rating
        fields = ('car_wash', 'count', 'average')
