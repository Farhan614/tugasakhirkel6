from django.contrib import admin
from .models import Perawat, PemeriksaanAwal
from dokter.models import JanjiTemu  # Untuk referensi JanjiTemu di PemeriksaanAwal

@admin.register(Perawat)
class PerawatAdmin(admin.ModelAdmin):
    list_display = ('nama', 'user', 'telepon', 'poli')
    search_fields = ('nama', 'telepon', 'email')
    list_filter = ('poli',)

@admin.register(PemeriksaanAwal)
class PemeriksaanAwalAdmin(admin.ModelAdmin):
    list_display = ('janji_temu', 'perawat', 'tanggal_pemeriksaan', 'tekanan_darah', 'suhu_badan')
    search_fields = ('janji_temu__pasien__nama', 'perawat__nama')
    list_filter = ('perawat', 'tanggal_pemeriksaan')
    readonly_fields = ('tanggal_pemeriksaan',)  # Tanggal dibuat otomatis, jadi hanya dibaca

    def get_queryset(self, request):
        # Optimalkan query dengan prefetch_related untuk data terkait
        qs = super().get_queryset(request)
        return qs.select_related('janji_temu', 'janji_temu__pasien', 'janji_temu__dokter', 'perawat')