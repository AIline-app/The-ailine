from django.contrib import admin
from django.contrib.auth import get_user_model

from car_wash.models import Car, Box, QueueEntry
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarType
from iLine.admin_filters import OrdersListFilter

User = get_user_model()


class BoxInline(admin.TabularInline):

    model = Box
    extra = 0


class CarWashSettingsInline(admin.StackedInline):

    model = CarWashSettings
    can_delete = False
    extra = 0
    max_num = 1


class CarWashDocumentsInline(admin.StackedInline):

    model = CarWashDocuments
    can_delete = False
    extra = 0
    max_num = 1


class OwnerFilter(OrdersListFilter):

    title = 'Owner'
    parameter_name = 'owner'
    filter_field = 'owner_id'

    def lookups(self, request, model_admin):

        return self._get_filter_list(
            queryset=User.objects.filter(owner_car_washes__isnull=False).distinct(),
            label_fields=("username", "phone_number", "id"),
            ordering=("username", "-id"),
        )


class CarWashNameFilter(OrdersListFilter):

    title = 'Car wash'
    parameter_name = 'car_wash'
    filter_field = 'car_wash_id'

    def lookups(self, request, model_admin):

        return self._get_filter_list(queryset=CarWash.objects.all())


@admin.register(CarWash)
class CarWashAdmin(admin.ModelAdmin):

    list_display = (
        'id',
        'name',
        'owner',
        'address',
        'is_active',
        'created_at',
    )
    list_filter = (
        OwnerFilter,
        'is_active',
        'created_at',
    )
    search_fields = (
        'id',
        'name',
        'address',
        'owner__phone_number',
    )
    ordering = ('-created_at',)
    raw_id_fields = ('owner',)
    filter_horizontal = (
        'managers',
        'washers',
    )
    inlines = (
        CarWashSettingsInline,
        CarWashDocumentsInline,
        BoxInline,
    )
    list_select_related = ('owner',)


@admin.register(Box)
class BoxAdmin(admin.ModelAdmin):

    list_display = ('id', 'name', 'car_wash')
    list_filter = (CarWashNameFilter,)
    search_fields = ('id', 'name', 'car_wash__name')
    raw_id_fields = ('car_wash',)
    list_select_related = ('car_wash',)


@admin.register(Car)
class CarAdmin(admin.ModelAdmin):

    list_display = ('id', 'number', 'owner')
    list_filter = (OwnerFilter,)
    search_fields = ('id', 'number', 'owner__phone_number')
    raw_id_fields = ('owner',)
    list_select_related = ('owner',)


@admin.register(CarWashSettings)
class CarWashSettingsAdmin(admin.ModelAdmin):

    list_display = ('car_wash', 'opens_at', 'closes_at', 'percent_washers')
    list_filter = ('opens_at', 'closes_at')
    search_fields = ('car_wash__name',)
    raw_id_fields = ('car_wash',)


@admin.register(CarWashDocuments)
class CarWashDocumentsAdmin(admin.ModelAdmin):
    list_display = ('car_wash', 'iin')
    search_fields = ('car_wash__name', 'iin')
    raw_id_fields = ('car_wash',)


@admin.register(CarType)
class CarTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'settings', 'id')
    list_filter = ('settings',)
    search_fields = ('name', 'id', 'settings__car_wash__name')
    raw_id_fields = ('settings',)


@admin.register(QueueEntry)
class QueueEntryAdmin(admin.ModelAdmin):
    list_display = ('id', 'car_wash', 'order', 'position', 'expected_start_time', 'expected_duration', 'created_at')
    list_filter = (CarWashNameFilter, 'created_at')
    search_fields = ('id', 'order__id', 'car_wash__name')
    raw_id_fields = ('car_wash', 'order')
    list_select_related = ('car_wash', 'order')
    ordering = ('car_wash', 'position')
