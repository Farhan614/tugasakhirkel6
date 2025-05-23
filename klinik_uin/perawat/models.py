from django.db import models
from django.contrib.auth.models import User
from dokter.models import JanjiTemu, Pasien

class Perawat(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    nama = models.CharField(max_length=100)
    telepon = models.CharField(max_length=15, blank=True)
    email = models.EmailField(blank=True)
    poli = models.ForeignKey('dokter.Poli', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return self.nama

class PemeriksaanAwal(models.Model):
    janji_temu = models.OneToOneField(JanjiTemu, on_delete=models.CASCADE, related_name='pemeriksaan_awal')
    perawat = models.ForeignKey(Perawat, on_delete=models.SET_NULL, null=True)
    tanggal_pemeriksaan = models.DateTimeField(auto_now_add=True)
    tekanan_darah = models.CharField(max_length=10, blank=True)  # Format: "120/80"
    suhu_badan = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)  # Misalnya: 36.5
    berat_badan = models.DecimalField(max_digits=5, decimal_places=1, blank=True, null=True)  # Misalnya: 70.5 kg
    tinggi_badan = models.DecimalField(max_digits=5, decimal_places=1, blank=True, null=True)  # Misalnya: 165.0 cm
    catatan = models.TextField(blank=True)

    def __str__(self):
        return f"Pemeriksaan Awal - {self.janji_temu.pasien.nama} oleh {self.perawat.nama}"