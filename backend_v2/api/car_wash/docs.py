from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiResponse

from api.car_wash.serializers import (
    CarWashWriteSerializer,
    CarSerializer,
    BoxSerializer,
    CarWashReadSerializer,
    CarWashQueueSerializer,
    CarWashEarningsWriteSerializer,
    CarWashEarningsReadSerializer,
)


CarWashViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary="List car washes",
        description="List public car washes for anonymous users and both public and own car washes for authenticated users.",
        responses={200: CarWashReadSerializer},
        tags=["Car wash"],
    ),
    retrieve=extend_schema(
        summary="Retrieve a car wash",
        description="Retrieve a car wash by id. Returns detailed info for owners, public info otherwise.",
        responses={200: CarWashReadSerializer, 404: OpenApiResponse(description="Not found")},
        tags=["Car wash"],
    ),
    create=extend_schema(
        summary="Create a car wash",
        description="Create a new car wash with settings, documents and initial boxes amount.",
        request=CarWashWriteSerializer,
        responses={201: CarWashReadSerializer, 400: OpenApiResponse(description="Validation error")},
        tags=["Car wash"],
    ),
    update=extend_schema(
        summary="Update a car wash",
        description="Update existing car wash fields, nested settings/documents and boxes amount.",
        request=CarWashWriteSerializer,
        responses={200: CarWashReadSerializer, 400: OpenApiResponse(description="Validation error")},
        tags=["Car wash"],
    ),
    partial_update=extend_schema(
        summary="Partially update a car wash",
        request=CarWashWriteSerializer,
        responses={200: CarWashReadSerializer},
        tags=["Car wash"],
    ),
    destroy=extend_schema(
        summary="Delete a car wash",
        responses={204: OpenApiResponse(description="Deleted"), 403: OpenApiResponse(description="Forbidden")},
        tags=["Car wash"],
    ),
    queue=extend_schema(
        summary="Get car wash queue data",
        description="Returns approximate wait time and cars amount in queue for a car wash.",
        responses={200: CarWashQueueSerializer},
        tags=["Car wash"],
    ),
    earnings=extend_schema(
        summary="Calculate car wash earnings",
        description="Calculate total earnings and breakdown by car types for the specified period.",
        request=CarWashEarningsWriteSerializer,
        responses={200: CarWashEarningsReadSerializer, 400: OpenApiResponse(description="Validation error"), 403: OpenApiResponse(description="Forbidden")},
        tags=["Earnings"],
    ),
)


BoxViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary="List boxes",
        responses={200: BoxSerializer},
        tags=["Boxes"],
    ),
    retrieve=extend_schema(
        summary="Retrieve a box",
        responses={200: BoxSerializer, 404: OpenApiResponse(description="Not found")},
        tags=["Boxes"],
    ),
    create=extend_schema(
        summary="Create a box",
        request=BoxSerializer,
        responses={201: BoxSerializer, 400: OpenApiResponse(description="Validation error")},
        tags=["Boxes"],
    ),
    update=extend_schema(
        summary="Update a box",
        request=BoxSerializer,
        responses={200: BoxSerializer},
        tags=["Boxes"],
    ),
    partial_update=extend_schema(
        summary="Partially update a box",
        request=BoxSerializer,
        responses={200: BoxSerializer},
        tags=["Boxes"],
    ),
    destroy=extend_schema(
        summary="Delete a box",
        responses={204: OpenApiResponse(description="Deleted")},
        tags=["Boxes"],
    ),
)


CarViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary="List my cars",
        responses={200: CarSerializer},
        tags=["Cars"],
    ),
    retrieve=extend_schema(
        summary="Retrieve my car by number",
        responses={200: CarSerializer, 404: OpenApiResponse(description="Not found")},
        tags=["Cars"],
    ),
    create=extend_schema(
        summary="Register a new car",
        request=CarSerializer,
        responses={201: CarSerializer, 400: OpenApiResponse(description="Validation error")},
        tags=["Cars"],
    ),
    update=extend_schema(
        summary="Update my car",
        request=CarSerializer,
        responses={200: CarSerializer},
        tags=["Cars"],
    ),
    partial_update=extend_schema(
        summary="Partially update my car",
        request=CarSerializer,
        responses={200: CarSerializer},
        tags=["Cars"],
    ),
    destroy=extend_schema(
        summary="Delete my car",
        responses={204: OpenApiResponse(description="Deleted")},
        tags=["Cars"],
    ),
)
