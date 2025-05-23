from django.urls import path
from . import views

app_name = 'apoteker'

urlpatterns = [
    path('login/', views.CustomLoginViewApoteker.as_view(), name='login_apoteker'),
    path('logout/', views.logout_apoteker, name='logout_apoteker'),  # URL baru untuk logout
    path('dashboard/', views.dashboard_apoteker, name='dashboard_apoteker'),
    path('proses-resep/<int:resep_id>/', views.proses_resep, name='proses_resep'),
    path('keluarkan-obat/<int:resep_id>/', views.keluarkan_obat, name='keluarkan_obat'),
    path('kelola-obat/', views.kelola_obat, name='kelola_obat'),
    path('edit-obat/<int:obat_id>/', views.edit_obat, name='edit_obat'),
    path('resep-selesai/<int:resep_id>/', views.detail_resep_selesai, name='detail_resep_selesai'),  # URL baru
]