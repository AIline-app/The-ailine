from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiResponse

from api.orders.serializers import (
    OrdersCreateSerializer,
    OrdersReadSerializer,
    OrdersManualCreateSerializer,
    OrdersStartSerializer,
    OrdersFinishSerializer,
    OrdersUpdateServicesSerializer,
)


OrdersViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary='List orders',
        description='List orders for the car wash in route. Non-managers only see their own orders.',
        responses={200: OrdersReadSerializer},
        tags=['Orders'],
    ),
    retrieve=extend_schema(
        summary='Retrieve an order',
        responses={200: OrdersReadSerializer, 404: OpenApiResponse(description='Not found')},
        tags=['Orders'],
    ),
    create=extend_schema(
        summary='Create an order',
        request=OrdersCreateSerializer,
        responses={201: OrdersReadSerializer, 400: OpenApiResponse(description='Validation error')},
        tags=['Orders'],
    ),
    destroy=extend_schema(
        summary='Cancel an order',
        description='Soft-cancels the order by setting status to CANCELED.',
        responses={204: OpenApiResponse(description='Canceled')},
        tags=['Orders'],
    ),
    manual=extend_schema(
        summary='Create an order manually (manager)',
        description='Managers can create orders for clients by providing client info.',
        request=OrdersManualCreateSerializer,
        responses={201: OrdersReadSerializer, 400: OpenApiResponse(description='Validation error'), 403: OpenApiResponse(description='Forbidden')},
        tags=['Orders'],
    ),
    queue=extend_schema(
        summary='Get queue info for order',
        description='Returns updated order with computed queue-related data.',
        # request=CarWashOrderQueueSerializer,
        responses={200: OrdersReadSerializer},
        tags=['Orders'],
    ),
    start=extend_schema(
        summary='Start order (manager)',
        request=OrdersStartSerializer,
        responses={200: OrdersReadSerializer, 400: OpenApiResponse(description='Validation error'), 403: OpenApiResponse(description='Forbidden')},
        tags=['Orders'],
    ),
    finish=extend_schema(
        summary='Finish order (manager)',
        request=OrdersFinishSerializer,
        responses={200: OrdersReadSerializer, 400: OpenApiResponse(description='Validation error'), 403: OpenApiResponse(description='Forbidden')},
        tags=['Orders'],
    ),
    update_services=extend_schema(
        summary='Update order services (manager)',
        request=OrdersUpdateServicesSerializer,
        responses={200: OrdersReadSerializer, 400: OpenApiResponse(description='Validation error'), 403: OpenApiResponse(description='Forbidden')},
        tags=['Orders'],
    ),
)
