from django.db import transaction
from django.db.models import Count, Sum
from rest_framework import serializers

from accounts.models import User
from api.accounts.serializers import BaseRegisterUserSerializer, UserSerializer
from orders.utils.enums import OrderStatus


class ManagerWriteSerializer(BaseRegisterUserSerializer):
    def validate(self, attrs):
        attrs['user'] = self.get_user(attrs['phone_number'])
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = validated_data.pop('user')
        car_wash = validated_data.pop('car_wash')
        if not user:
            user = User.objects.create_user(**validated_data)
            user.send_manager_invitation()
        car_wash.managers.add(user)
        return user


class WasherWriteSerializer(BaseRegisterUserSerializer):
    def validate(self, attrs):
        # TODO validate
        attrs['user'] = self.get_user(attrs['phone_number'])
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        user = validated_data.pop('user')
        car_wash = validated_data.pop('car_wash')
        if not user:
            user = User.objects.create_user(**validated_data)
        car_wash.washers.add(user)
        return user


class ByWasherEarningsReadSerializer(serializers.Serializer):
    washer = UserSerializer(many=False, read_only=True)
    orders_count = serializers.IntegerField(read_only=True)
    revenue = serializers.IntegerField(read_only=True)
    earned = serializers.IntegerField(read_only=True)


class WasherEarningsReadSerializer(serializers.Serializer):
    washers_percent = serializers.IntegerField(read_only=True)
    by_washer_earnings = ByWasherEarningsReadSerializer(many=True, read_only=True)


class WasherEarningsWriteSerializer(serializers.Serializer):
    date_from = serializers.DateField(required=True)
    date_to = serializers.DateField(required=False, default=None)


    def create(self, validated_data):
        car_wash = validated_data.pop('car_wash')
        date_from = validated_data.pop('date_from')
        date_to = validated_data.pop('date_to')

        qs = car_wash.orders.filter(
            status=OrderStatus.COMPLETED,
        )

        if date_to is not None:
            qs = qs.filter(
                finished_at__date__range=(date_from, date_to),
            )
        else:
            qs = qs.filter(
                finished_at__date=date_from,
            )

        rows = (
            qs.values('washer_id', 'washer__username', 'washer__phone_number', 'washer__created_at')
              .annotate(
                  orders_count=Count('id', distinct=True),
                  revenue=Sum('total_price'),
              )
              .order_by('washer__phone_number')
        )

        percent = car_wash.settings.percent_washers
        washers = []
        for row in rows:
            revenue = row['revenue'] or 0
            washers.append({
                'washer': {
                    'id': row['washer_id'],
                    'name': row['washer__username'],
                    'phone_number': row['washer__phone_number'],
                    'created_at': row['washer__created_at'],
                },
                'orders_count': row['orders_count'] or 0,
                'revenue': revenue,
                'earned': int(revenue * percent / 100),
            })

        return {
            'washers_percent': percent,
            'by_washer_earnings': washers,
        }

    def to_representation(self, instance):
        return WasherEarningsReadSerializer(instance, context=self.context).data
