from django.contrib import admin
from .models import Dokter, Pasien, JanjiTemu, RekamMedis, Poli, Konsultasi, PesanKonsultasi
from django import forms
from apoteker.models import Apoteker, Obat, Resep, DetailResep, PengeluaranObat

@admin.register(Dokter)
class DokterAdmin(admin.ModelAdmin):
    list_display = ('nama', 'spesialisasi', 'user')
    search_fields = ('nama', 'spesialisasi')

@admin.register(Pasien)
class PasienAdmin(admin.ModelAdmin):
    list_display = ('nama', 'nik', 'email', 'telepon')
    search_fields = ('nama', 'nik')

@admin.register(JanjiTemu)
class JanjiTemuAdmin(admin.ModelAdmin):
    list_display = ('pasien', 'dokter', 'tanggal', 'status', 'kode_antrian')
    list_filter = ('status', 'dokter')

@admin.register(RekamMedis)
class RekamMedisAdmin(admin.ModelAdmin):
    list_display = ('pasien', 'dokter', 'tanggal')
    search_fields = ('diagnosa', 'resep')

@admin.register(Apoteker)
class ApotekerAdmin(admin.ModelAdmin):
    list_display = ('nama', 'user', 'telepon')
    search_fields = ('nama', 'telepon')

@admin.register(Obat)
class ObatAdmin(admin.ModelAdmin):
    list_display = ('nama', 'stok', 'harga')
    search_fields = ('nama', 'deskripsi')

@admin.register(Resep)
class ResepAdmin(admin.ModelAdmin):
    list_display = ('dokter', 'pasien', 'tanggal_dibuat', 'status')
    list_filter = ('status', 'dokter')
    search_fields = ('pasien__nama', 'dokter__nama')

@admin.register(DetailResep)
class DetailResepAdmin(admin.ModelAdmin):
    list_display = ('resep', 'obat', 'jumlah')
    search_fields = ('obat__nama',)

@admin.register(PengeluaranObat)
class PengeluaranObatAdmin(admin.ModelAdmin):
    list_display = ('resep', 'apoteker', 'tanggal_pengeluaran')
    list_filter = ('apoteker',)
    search_fields = ('resep__pasien__nama',)

admin.site.register(Poli)

from django.contrib.auth.models import Permission

admin.site.register(Permission)
