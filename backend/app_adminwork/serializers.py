from datetime import timedelta

from rest_framework import serializers
from django.utils import timezone

from app_washes.models import Service
from .models import SlotsInWash, CarWash, Order
from app_orders.serializers import OrderSerializer, PaymentData, two_stage_payment, ItemServiceSerializer


class SlotSerializers(serializers.ModelSerializer):
    """Функционал работы админа. При поступлении статуса Free - бокс очищается, иначе - начинается мойка"""
    order = OrderSerializer(required=False)
    order_pk = serializers.PrimaryKeyRelatedField(queryset=Order.objects.all(), write_only=True)
    status = serializers.CharField()

    class Meta:
        model = SlotsInWash
        fields = ('order', 'status', 'order_pk')

    def update(self, instance, validated_data):

        if validated_data.get('status') != 'Free' and validated_data.get('order_pk').status == 'Reserve':
            instance.status = validated_data.get('status', instance.status)
            instance.order = validated_data.get('order_pk', instance.order)
            box_id = instance.id
            order_db = Order.objects.get(id=instance.order.id)
            order_db.time_start = timezone.now()
            order_db.time_end = order_db.time_start + timedelta(minutes=order_db.time_work)
            order_db.status = 'In progress'
            order_db.payment_status = 'Fulfilled'
            instance.status = 'In progress'
            two_stage_payment(
                id_payment=PaymentData.objects.get(order=instance.order.id).id_payment,
                action="approve"
            )
            order_db.box_id = box_id
            order_db.save()
        if validated_data.get('status') == 'Free' and validated_data.get('order_pk').status == 'In progress':
            # instance.status = validated_data.get('status', instance.status)
            order_db = Order.objects.get(id=instance.order.id)
            validated_data.pop('order_pk')
            order_db.time_end = timezone.now()
            order_db.status = 'Done'
            instance.status = 'Free'
            instance.order = None
            order_db.save()

        instance.save()
        return instance


class SlotInWashDetailSerializer(serializers.ModelSerializer):
    """Сериализатор слота в мойке"""
    order = OrderSerializer(required=False)

    class Meta:
        model = SlotsInWash
        fields = '__all__'


class AdminCarWashDetailSerializer(serializers.ModelSerializer):
    """Сериализатор мойки со слотами"""
    slot = SlotInWashDetailSerializer(many=True)

    class Meta:
        model = CarWash
        fields = ('id', 'title', 'slots', 'slot')


class AdminListCarWashSerializer(serializers.ModelSerializer):

    class Meta:
        model = CarWash
        fields = '__all__'


class ArchiveListOrders(serializers.ModelSerializer):
    customer_phone = serializers.SerializerMethodField()
    customer_name = serializers.SerializerMethodField()
    number_auto = serializers.SerializerMethodField()
    item_service = ItemServiceSerializer(many=True, required=False)
    service = serializers.PrimaryKeyRelatedField(queryset=Service.objects.all(), many=True, required=False)

    class Meta:
        model = Order
        fields = ('id', 'time_start', 'time_end', 'box_id', 'customer_phone', 'customer_name', 'price', 'final_price', 'number_auto', 'item_service', 'service')

    def get_customer_phone(self, obj):
        return obj.customer.phone

    def get_customer_name(self, obj):
        return obj.customer.username

    def get_number_auto(self, obj):
        return obj.customer.number_auto
