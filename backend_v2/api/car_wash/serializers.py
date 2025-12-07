from datetime import timedelta

from django.db import transaction
from django.db.models import Sum, Count
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from car_wash.models import Car
from car_wash.models.box import Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarType
from orders.utils.enums import OrderStatus


class CarWashCarTypesSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarType
        exclude = ('settings',)


class CarWashSettingsPrivateSerializer(serializers.ModelSerializer):
    car_types = CarWashCarTypesSerializer(many=True, read_only=False)
    class Meta:
        model = CarWashSettings
        exclude = ('car_wash',)


class CarWashSettingsPublicSerializer(serializers.ModelSerializer):
    car_types = CarWashCarTypesSerializer(many=True, read_only=True)
    class Meta:
        model = CarWashSettings
        fields = ('opens_at', 'closes_at', 'car_types')


class CarWashDocumentsPrivateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarWashDocuments
        exclude = ('car_wash',)


class CarWashPublicReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPublicSerializer(read_only=True)
    class Meta:
        model = CarWash
        fields = ('id', 'name', 'address', 'created_at', 'is_active', 'settings')


class CarWashPrivateReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    class Meta:
        model = CarWash
        exclude = ('owner',)


class CarWashReadSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    boxes_amount = serializers.IntegerField()

    class Meta:
        model = CarWash
        fields = ('id', 'name', 'address', 'created_at', 'settings', 'documents', 'boxes_amount')

    def to_representation(self, instance):
        if instance.owner == self.context['request'].user:
            return CarWashPrivateReadSerializer(instance).data
        return CarWashPublicReadSerializer(instance).data


class CarWashWriteSerializer(serializers.ModelSerializer):
    settings = CarWashSettingsPrivateSerializer(many=False)
    documents = CarWashDocumentsPrivateSerializer(many=False)
    boxes_amount = serializers.IntegerField()

    class Meta:
        model = CarWash
        fields = ('id', 'name', 'address', 'created_at', 'settings', 'documents', 'boxes_amount')

    def validate(self, attrs):
        if 'is_active' in attrs:
            attrs.pop('is_active')
        # TODO validate
        return attrs

    @transaction.atomic
    def create(self, validated_data):
        settings_data = validated_data.pop('settings')
        documents_data = validated_data.pop('documents')
        boxes_amount = validated_data.pop('boxes_amount')

        car_wash = super().create(validated_data)
        car_wash.create_settings(settings_data)
        car_wash.create_documents(documents_data)
        car_wash.create_boxes(boxes_amount)

        return car_wash

    @transaction.atomic
    def update(self, instance, validated_data):
        for field in ('settings', 'documents'):
            if field in validated_data:
                data = validated_data.pop(field)

                if 'car_types' in data:
                    car_types = data.pop('car_types')
                    instance.update_car_types(car_types)

                obj = getattr(instance, field)
                for k, v in data.items():
                    setattr(obj, k, v)
                obj.save()
        if 'boxes_amount' in validated_data:
            boxes_amount = validated_data.pop('boxes_amount')

        return super().update(instance, validated_data)

    def to_representation(self, instance):
        return CarWashReadSerializer(instance, context=self.context).data


class CarWashQueueSerializer(serializers.Serializer):
    wait_time = serializers.DurationField(read_only=True)
    car_amount = serializers.IntegerField(read_only=True)

    def create(self, validated_data):
        car_wash = validated_data.pop('car_wash')
        boxes_amount = car_wash.boxes.count()

        orders = car_wash.orders.prefetch_related(
            'services',
        ).filter(
            status__in=(OrderStatus.EN_ROUTE, OrderStatus.ON_SITE),
        )

        combined_duration = self.get_total_duration(orders)
        return {'wait_time': combined_duration/boxes_amount, 'car_amount': len(orders)}

    def get_total_duration(self, orders):
        return sum(
            (
                sum(
                    (service.duration for service in order.services),
                    timedelta(0)
                ) for order in orders
            ),
            timedelta(0)
        )


class CarWashEarningsByCarTypesReadSerializer(CarWashCarTypesSerializer):
    orders_count = serializers.IntegerField(read_only=True)


class CarWashEarningsReadSerializer(serializers.Serializer):
    total_revenue = serializers.IntegerField(read_only=True)
    orders_count = serializers.IntegerField(read_only=True)
    by_car_types = CarWashEarningsByCarTypesReadSerializer(many=True, read_only=True)


class CarWashEarningsWriteSerializer(serializers.Serializer):
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

        agg = qs.aggregate(total_revenue=Sum('total_price'), orders_count=Count('id'))
        total_revenue = agg['total_revenue'] or 0
        orders_count = agg['orders_count'] or 0

        # Counts by car type via services relationship
        car_type_rows = (
            qs.values('services__car_type__id', 'services__car_type__name')
              .annotate(orders_count=Count('id', distinct=True))
              .filter(services__car_type__id__isnull=False)
              .order_by('-orders_count')
        )
        car_types = [
            {
                'id': row['services__car_type__id'],
                'name': row['services__car_type__name'],
                'orders_count': row['orders_count'],
            }
            for row in car_type_rows
        ]
        return {
            'total_revenue': total_revenue,
            'orders_count': orders_count,
            'by_car_types': car_types,
        }

    def to_representation(self, instance):
        return CarWashEarningsReadSerializer(instance, context=self.context).data


class CarSerializer(serializers.ModelSerializer):
    class Meta:
        model = Car
        fields = ('id', 'number')

    def validate(self, attrs):
        if Car.objects.filter(number=attrs['number']).exists():
            raise serializers.ValidationError({'number': _('This car already exists')})
        # TODO validate car number
        return attrs


class BoxSerializer(serializers.ModelSerializer):
    class Meta:
        model = Box
        exclude = ('car_wash',)
