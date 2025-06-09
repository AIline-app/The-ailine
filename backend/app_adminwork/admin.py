from django.contrib import admin

from .models import SlotsInWash


@admin.register(SlotsInWash)
class SlotAdmin(admin.ModelAdmin):
    list_display = ('pk', 'order', 'wash', 'status')
    ordering = ('pk',)
