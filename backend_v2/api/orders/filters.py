from django.db.models import F, Window
from django.db.models.functions import RowNumber
from rest_framework.filters import BaseFilterBackend


class LatestCarNumberFilterBackend(BaseFilterBackend):
    """
    Custom filter that searches by car_number prefix and returns
    the latest order per matching car (if any).
    """
    search_param = 'car_number'

    def filter_queryset(self, request, queryset, view):
        search_term = request.query_params.get(self.search_param)

        if not search_term:
            return queryset

        # Constrain to cars whose number starts with the search term
        base_qs = queryset.filter(car__number__istartswith=search_term)

        # Use window function to pick latest order per car
        annotated = base_qs.annotate(
            rn=Window(
                expression=RowNumber(),
                partition_by=[F('car')],
                order_by=[F('created_at').desc(nulls_last=True), F('id').desc()],
            )
        )
        return annotated.filter(rn=1)
