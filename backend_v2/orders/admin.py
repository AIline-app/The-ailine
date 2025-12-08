from django.contrib import admin

from orders.models import Orders


class WasherFilter(admin.SimpleListFilter):
    title = 'Washer'
    parameter_name = 'washer'

    def lookups(self, request, model_admin):
        washers = (
            model_admin.get_queryset(request)
            .values('washer__id', 'washer__phone_number', 'washer__username')
            .exclude(washer__id__isnull=True)
            .order_by('washer__phone_number', 'washer__id')
            .distinct()
        )
        results = []
        for w in washers:
            parts = []
            if w['washer__phone_number']:
                parts.append(w['washer__phone_number'])
            if w['washer__username']:
                parts.append(w['washer__username'])
            parts.append(str(w['washer__id']))
            label = ' — '.join(parts[:-1]) + f" · {parts[-1]}"
            results.append((str(w['washer__id']), label))
        return results

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(washer_id=self.value())
        return queryset


class UserFilter(admin.SimpleListFilter):
    title = 'Client'
    parameter_name = 'user'

    def lookups(self, request, model_admin):
        users = (
            model_admin.get_queryset(request)
            .values('user__id', 'user__phone_number', 'user__username')
            .exclude(user__id__isnull=True)
            .order_by('user__phone_number', 'user__id')
            .distinct()
        )
        results = []
        for u in users:
            parts = []
            if u['user__phone_number']:
                parts.append(u['user__phone_number'])
            if u['user__username']:
                parts.append(u['user__username'])
            parts.append(str(u['user__id']))
            label = ' — '.join(parts[:-1]) + f" · {parts[-1]}"
            results.append((str(u['user__id']), label))
        return results

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(user_id=self.value())
        return queryset


class CarWashFilter(admin.SimpleListFilter):
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


class BoxFilter(admin.SimpleListFilter):
    title = 'Box'
    parameter_name = 'box'

    def lookups(self, request, model_admin):
        boxes = (
            model_admin.get_queryset(request)
            .values('box__id', 'box__name')
            .exclude(box__id__isnull=True)
            .order_by('box__name', 'box__id')
            .distinct()
        )
        results = []
        for b in boxes:
            name = b['box__name'] or ''
            uid = str(b['box__id'])
            label = (name if name else uid) + f" · {uid}"
            results.append((uid, label))
        return results

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(box_id=self.value())
        return queryset


@admin.register(Orders)
class OrdersAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'status', 'user', 'car', 'car_wash', 'box', 'washer',
        'total_price', 'created_at', 'started_at', 'finished_at'
    )
    list_filter = (
        'status', CarWashFilter, BoxFilter, UserFilter, WasherFilter, 'created_at', 'started_at', 'finished_at'
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
