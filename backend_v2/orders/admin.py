from django.contrib import admin
from django.contrib.auth import get_user_model

from car_wash.models import CarWash, Box
from orders.models import Orders
from iLine.admin_filters import OrdersListFilter

User = get_user_model()


class WasherFilter(OrdersListFilter):

    title = 'Washer'
    parameter_name = 'washer'
    filter_field = "washer_id"

    def lookups(self, request, model_admin):

        return self._get_filter_list(
            queryset=User.objects.filter(executed_orders__isnull=False).distinct(),
            label_fields=("username", "phone_number", "id"),
            ordering=("username", "-id"),
        )


class UserFilter(OrdersListFilter):

    title = 'Client'
    parameter_name = 'user'
    filter_field = "user_id"

    def lookups(self, request, model_admin):

        return self._get_filter_list(
            queryset=User.objects.all(),
            label_fields=("username", "phone_number", "id"),
            ordering=("username", "-id"),
        )


class CarWashFilter(OrdersListFilter):

    title = 'Car wash'
    parameter_name = 'car_wash'
    filter_field = "car_wash_id"

    def lookups(self, request, model_admin):

        return self._get_filter_list(queryset=CarWash.objects.all())


class BoxFilter(OrdersListFilter):

    title = 'Box'
    parameter_name = 'box'
    filter_field = "box_id"

    def lookups(self, request, model_admin):

        return self._get_filter_list(queryset=Box.objects.all())


@admin.register(Orders)
class OrdersAdmin(admin.ModelAdmin):

    list_display = (
        'id',
        'status',
        'user',
        'car',
        'car_wash',
        'box',
        'washer',
        'total_price',
        'started_at',
        'finished_at',
        'created_at',
    )
    list_filter = (
        'status',
        CarWashFilter,
        BoxFilter,
        UserFilter,
        WasherFilter,
        'started_at',
        'finished_at',
        'created_at',
    )
    search_fields = (
        'id', 'user__phone_number', 'car__number', 'car_wash__name'
    )
    raw_id_fields = ('user', 'car', 'car_wash', 'box', 'washer')
    filter_horizontal = ('services',)
    date_hierarchy = 'created_at'
    ordering = ('-created_at',)
    list_select_related = ('user', 'car', 'car_wash', 'box', 'washer')
    list_per_page = 50
