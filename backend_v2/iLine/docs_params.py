from datetime import date

from drf_spectacular.utils import OpenApiParameter

date_from_param = OpenApiParameter(
    name="date_from",
    required=True,
    type=date,
)
date_to_param = OpenApiParameter(
    name="date_to",
    required=False,
    type=date,
)