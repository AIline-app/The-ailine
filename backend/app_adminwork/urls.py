from django.urls import path

from .views import SlotInProgress, AdminWashDetail, AdminWashList, ArchiveOrderForAdmin

urlpatterns = [
    path(r'<int:wash_id>/slot/<int:pk>', SlotInProgress.as_view(), name='slot_in'),
    path('', AdminWashList.as_view(), name='admin_wash_list'),
    path(r'<int:pk>', AdminWashDetail.as_view(), name='admin_wash_detail'),
    path(r'archive', ArchiveOrderForAdmin.as_view(), name='archive')
]
