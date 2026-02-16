from django.contrib import admin

from services.models import Services


class ServicesCarWashFilter(admin.SimpleListFilter):
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


class ServicesCarTypeFilter(admin.SimpleListFilter):
    title = 'Car type'
    parameter_name = 'car_type'

    def lookups(self, request, model_admin):
        types = (
            model_admin.get_queryset(request)
            .values('car_type__id', 'car_type__name')
            .exclude(car_type__id__isnull=True)
            .order_by('car_type__name', 'car_type__id')
            .distinct()
        )
        results = []
        for t in types:
            name = t['car_type__name'] or ''
            uid = str(t['car_type__id'])
            label = (name if name else uid) + f" · {uid}"
            results.append((uid, label))
        return results

    def queryset(self, request, queryset):
        if self.value():
            return queryset.filter(car_type_id=self.value())
        return queryset


@admin.register(Services)
class ServicesAdmin(admin.ModelAdmin):
    list_display = (
        'name', 'car_wash', 'car_type', 'price', 'duration', 'is_extra', 'id'
    )
    list_filter = (ServicesCarWashFilter, ServicesCarTypeFilter, 'is_extra')
    search_fields = ('name', 'description', 'id', 'car_wash__name')
    raw_id_fields = ('car_wash', 'car_type')
    ordering = ('name',)
    list_select_related = ('car_wash', 'car_type')
    list_per_page = 50
