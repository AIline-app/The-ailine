from django.contrib import admin

from .models import Order


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'customer', 'car_wash', 'time_start', 'time_work',
                    'final_price', 'status']
    list_filter = ['car_wash']
    search_fields = ['customer']


# @admin.register(ItemService)
# class ServiceAdmin(admin.ModelAdmin):
#     list_display = ['order', 'service']
#     list_filter = ['service']
