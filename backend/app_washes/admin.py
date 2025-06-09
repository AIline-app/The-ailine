from django.contrib import admin

from .models import CarWash, Administrator


@admin.register(CarWash)
class CarWashAdmin(admin.ModelAdmin):
    list_display = ('user', 'title', 'inn', 'address', 'slots', 'rating')
    list_filter = ('title', 'rating')
    ordering = ('pk',)


@admin.register(Administrator)
class AdministratorAdmin(admin.ModelAdmin):
    list_display = ('boss', 'phone', 'name',)
    filter_horizontal = ('wash',)
    ordering = ('pk',)
