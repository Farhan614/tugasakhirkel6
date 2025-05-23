from django.urls import path
from . import views

app_name = 'dokter'

urlpatterns = [
    path('dashboard/', views.dashboard_dokter, name='dashboard_dokter'),
    path('panggil/<int:janji_id>/', views.panggil_pasien, name='panggil_pasien'),
    path('edit_foto/', views.edit_foto_dokter, name='edit_foto_dokter'),
    path('rekam_medis/<int:janji_id>/', views.rekam_medis, name='rekam_medis_janji'),
    path('laporan/pdf/', views.export_laporan_pdf, name='export_laporan_pdf'),
    path('respons-konsultasi/<int:konsultasi_id>/', views.respons_konsultasi, name='respons_konsultasi'),
]