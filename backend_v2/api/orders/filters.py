from django.db.models import F, Window
from django.db.models.functions import RowNumber
from django_filters import FilterSet, MultipleChoiceFilter
from rest_framework.filters import SearchFilter

from orders.models import Orders
from orders.utils.enums import OrderStatus


class OrdersSearchFilter(SearchFilter):

    search_param = 'car_number'

    def filter_queryset(self, request, queryset, view):

        queryset = super().filter_queryset(request, queryset, view)

        search_fields = self.get_search_fields(view, request)
        search_terms = self.get_search_terms(request)

        if not search_fields or not search_terms:
            return queryset

        # Use window function to pick latest order per car
        annotated = queryset.annotate(
            rn=Window(
                expression=RowNumber(),
                partition_by=[F('car')],
                order_by=[F('created_at').desc(nulls_last=True), F('id').desc()],
            )
        )

        return annotated.filter(rn=1)


class OrdersFilterSet(FilterSet):
    status = MultipleChoiceFilter(
        field_name='status',
        choices=OrderStatus.choices,
    )

    class Meta:
        model = Orders
        fields = ('status', 'box', 'washer')
