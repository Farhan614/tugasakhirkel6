# core/urls.py
from django.urls import path
from . import views

app_name = 'core'  # Menentukan namespace untuk app 'core'

urlpatterns = [
    # URL untuk Landing Page (biasanya root dari app core)
    path('', views.landing_page, name='landing_page'),

    # URL baru untuk Visi Misi
    path('profil/visi-misi/', views.visi_misi_view, name='visi_misi'),
    path('layanan/umum/', views.layanan_umum_view, name='layanan_umum'),
    path('layanan/konseling/', views.layanan_konseling_view, name='layanan_konseling'),
    path('layanan/kia/', views.layanan_kia_view, name='layanan_kia'),

    # Tambahkan URL untuk halaman publik lainnya di sini nanti
    # path('profil/struktur-organisasi/', views.struktur_view, name='struktur_organisasi'),
    # path('informasi/artikel/', views.artikel_list_view, name='artikel_list'),
    # ... etc
]