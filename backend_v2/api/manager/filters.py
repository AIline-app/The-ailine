import django_filters

from orders.models import Orders


class OrdersFilterSet(django_filters.FilterSet):

    date_from = django_filters.DateFilter(field_name='finished_at__date', lookup_expr='gte', required=True)
    date_to = django_filters.DateFilter(field_name='finished_at__date', lookup_expr='lte')

    class Meta:

        model = Orders
        fields = ('date_from', 'date_to')
