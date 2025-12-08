from django.contrib import admin

from car_wash.models import Car, Box
from car_wash.models.car_wash import CarWash, CarWashSettings, CarWashDocuments, CarType


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


class OwnerFilter(admin.SimpleListFilter):
    title = 'Owner'
    parameter_name = 'owner'

    def lookups(self, request, model_admin):
        owners = (
            model_admin.get_queryset(request)
            .values('owner__id', 'owner__phone_number', 'owner__username')
            .exclude(owner__id__isnull=True)
            .order_by('owner__phone_number', 'owner__id')
            .distinct()
        )
        results = []
        for o in owners:
            parts = []
            if o['owner__phone_number']:
                parts.append(o['owner__phone_number'])
            if o['owner__username']:
                parts.append(o['owner__username'])
            parts.append(str(o['owner__id']))
            label = ' — '.join(parts[:-1]) + f" · {parts[-1]}"
            results.append((str(o['owner__id']), label))
        return results

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(owner_id=self.value())
        return queryset


class CarWashNameFilter(admin.SimpleListFilter):
    title = 'Car wash'
    parameter_name = 'car_wash'

    def lookups(self, request, model_admin):
        washes = (
            model_admin.get_queryset(request)
            .values('car_wash__id', 'car_wash__name')
            .exclude(car_wash__id__isnull=True)
            .order_by('car_wash__name', 'car_wash__id')
            .distinct()
        )
        results = []
        for w in washes:
            name = w['car_wash__name'] or ''
            uid = str(w['car_wash__id'])
            label = (name if name else uid) + f" · {uid}"
            results.append((uid, label))
        return results

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(car_wash_id=self.value())
        return queryset


@admin.register(CarWash)
class CarWashAdmin(admin.ModelAdmin):
    list_display = ('name', 'owner', 'address', 'is_active', 'created_at', 'id')
    list_filter = ('is_active', OwnerFilter, 'created_at')
    search_fields = ('name', 'address', 'id', 'owner__phone_number')
    ordering = ('-created_at',)
    raw_id_fields = ('owner',)
    filter_horizontal = ('managers', 'washers')
    inlines = [CarWashSettingsInline, CarWashDocumentsInline, BoxInline]
    list_select_related = ('owner',)


@admin.register(Box)
class BoxAdmin(admin.ModelAdmin):
    list_display = ('name', 'car_wash', 'id')
    list_filter = (CarWashNameFilter,)
    search_fields = ('name', 'id', 'car_wash__name')
    raw_id_fields = ('car_wash',)
    list_select_related = ('car_wash',)


@admin.register(Car)
class CarAdmin(admin.ModelAdmin):
    list_display = ('number', 'owner', 'id')
    list_filter = (OwnerFilter,)
    search_fields = ('number', 'id', 'owner__phone_number')
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
