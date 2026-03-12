from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiResponse

from api.rating.serializers import (
    UserReviewWriteSerializer,
    UserReviewReadSerializer,
    CarWashRatingSerializer,
)


OrderReviewViewSetDocs = extend_schema_view(
    create=extend_schema(
        summary='Create a review for the completed order',
        description='Create a new review for a user\'s completed order within the specified car wash route.',
        request=UserReviewWriteSerializer,
        responses={
            201: UserReviewReadSerializer,
            400: OpenApiResponse(description='Validation error'),
            403: OpenApiResponse(description='Forbidden'),
            404: OpenApiResponse(description='Not found'),
        },
        tags=['Rating'],
    ),
    retrieve=extend_schema(
        summary='Retrieve a review',
        responses={
            200: UserReviewReadSerializer,
            403: OpenApiResponse(description='Forbidden'),
            404: OpenApiResponse(description='Not found'),
        },
        tags=['Rating'],
    ),
)


CarWashRatingViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary='Get car wash rating',
        description='Returns current reviews count and average rating for the car wash.',
        responses={200: CarWashRatingSerializer},
        tags=['Rating'],
    ),
)


CarWashReviewsViewSetDocs = extend_schema_view(
    list=extend_schema(
        summary='List car wash reviews',
        description='List user reviews left for the specified car wash.',
        responses={200: UserReviewReadSerializer},
        tags=['Rating'],
    ),
)
