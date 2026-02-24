from django.contrib import admin

from .models import Rating, UserReview


@admin.register(Rating)
class RatingAdmin(admin.ModelAdmin):
    list_display = ("car_wash", "count", "average")
    list_select_related = ("car_wash",)
    search_fields = (
        "car_wash__name",
        "car_wash__id",
        "car_wash__owner__phone_number",
    )
    list_filter = (
        "car_wash__is_active",
    )
    raw_id_fields = ("car_wash",)
    ordering = ("-average", "-count")
    readonly_fields = ()


@admin.register(UserReview)
class UserReviewAdmin(admin.ModelAdmin):
    list_display = ("order", "user", "rating")
    list_select_related = ("user", "order", "order__car_wash")
    search_fields = (
        "user__phone_number",
        "user__username",
        "order__id",
        "order__car_wash__name",
        "order__car_wash__id",
    )
    list_filter = (
        "rating",
        "order__car_wash",
        "user__is_active",
    )
    raw_id_fields = ("user", "order")
    ordering = ("-rating",)

