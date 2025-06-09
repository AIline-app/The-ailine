from django.urls import path

from app_users.views import DetailUserAPI, RegisterUserAPI, LoginAPIView, MyTokenRefreshView, UpdateUserPasswordView, CreateOrUpdateBankCard, ListBankCard, CallBackCashOut, CreateCashOutData, LogoutView
from app_washes.views import AdminListAPI

urlpatterns = [
    path('me', DetailUserAPI.as_view(), name='user_detail'),
    path('me/bankcard/<int:pk>', CreateOrUpdateBankCard.as_view(), name='bank_card'),
    path('me/bankcard', CreateOrUpdateBankCard.as_view(), name='create_bank_card'),
    path('me/listcard', ListBankCard.as_view(), name='list_card'),
    path('me/cashout', CreateCashOutData.as_view(), name='cash_out'),
    path('callback', CallBackCashOut.as_view(), name='callback'),

    path('register', RegisterUserAPI.as_view(), name='user_register'),

    path('login', LoginAPIView.as_view(), name='user_login'),
    path('logout', LogoutView.as_view(), name='user_logout'),
    path('token/refresh', MyTokenRefreshView.as_view(), name='user_update_access_token'),  # todo при обновлении старый токен удалять
    path('me/admins', AdminListAPI.as_view(), name='admins_inside_washes'),
    path('restore', UpdateUserPasswordView.as_view(), name='restore_password'),
]
