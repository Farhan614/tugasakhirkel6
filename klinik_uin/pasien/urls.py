from django.urls import path
from . import views

app_name = 'pasien'

urlpatterns = [
    path('', views.pasien_dashboard, name='pasien_dashboard'),
    path('register/', views.register_pasien, name='register_pasien'),
    path('login/', views.login_pasien, name='login_pasien'),
    path('logout/', views.logout_pasien, name='logout_pasien'),
    path('konsultasi-online/', views.konsultasi_online, name='konsultasi_online'),
    path('konsultasi/<int:konsultasi_id>/', views.detail_konsultasi_pasien, name='detail_konsultasi_pasien'),
    path('edit-profil/', views.edit_profil_pasien, name='edit_profil_pasien'),
    path('midtrans-callback/', views.midtrans_callback, name='midtrans_callback'),
    path('resep/<int:resep_id>/', views.detail_resep_pasien, name='detail_resep_pasien'),
    path('payment/<int:resep_id>/', views.payment, name='payment'),
    ]