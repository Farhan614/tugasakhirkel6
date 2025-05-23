from django.urls import path
from . import views

app_name = 'perawat'

urlpatterns = [
    path('dashboard/', views.dashboard_perawat, name='dashboard_perawat'),
    path('periksa/<int:janji_temu_id>/', views.periksa_pasien, name='periksa_pasien'),
    path('login/', views.login_perawat, name='login_perawat'),
    path('logout/', views.logout_perawat, name='logout_perawat'),
    path('register/', views.register_perawat, name='register_perawat'),
    path('profile/', views.profile_perawat, name='profile_perawat'),
]