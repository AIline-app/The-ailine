from django.contrib import admin


class OrdersListFilter(admin.SimpleListFilter):

    template = 'django_admin_listfilter_dropdown/dropdown_filter.html'
    filter_field = 'id'

    @staticmethod
    def _get_filter_list(queryset, label_fields=None, ordering=None):

        if label_fields is None:
            label_fields = ('name', 'id')

        if ordering is None:
            ordering = ('name', '-id')

        queryset = queryset.order_by(*ordering)

        return [
            (
                instance.id,
                ' '.join(str(getattr(instance, field)) for field in label_fields),
            ) for instance in queryset
        ]

    def queryset(self, request, queryset):

        if self.value():
            return queryset.filter(**{self.filter_field: self.value()})

        return queryset
