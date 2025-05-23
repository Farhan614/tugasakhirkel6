from django.db import models, transaction
from django.contrib.auth.models import User
from django.utils import timezone
from django.db import IntegrityError
import logging

class Poli(models.Model):
    nama = models.CharField(max_length=50, unique=True)
    
    def __str__(self):
        return self.nama

class Dokter(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    nama = models.CharField(max_length=100)
    spesialisasi = models.CharField(max_length=50)
    jadwal_praktik = models.CharField(max_length=100, help_text="Masukkan hari praktik, pisahkan dengan koma")
    foto = models.ImageField(upload_to='dokter/foto/', null=True, blank=True, default='dokter/foto/default.jpg')
    poli = models.ForeignKey(Poli, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return self.nama

    def get_jadwal_list(self):
        return self.jadwal_praktik.split(',')
       
class Pasien(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    nik = models.CharField(max_length=16, unique=True)
    nama = models.CharField(max_length=100)
    telepon = models.CharField(max_length=15)
    email = models.EmailField(max_length=254, blank=True, null=True)
    alamat = models.TextField(blank=True, null=True)
    jenis_kelamin = models.CharField(max_length=10, choices=[('L', 'Laki-laki'), ('P', 'Perempuan')], blank=True, null=True)
    metode_pembayaran = models.CharField(max_length=50, choices=[('Tunai', 'Tunai'), ('Asuransi', 'Asuransi'), ('Kartu Kredit', 'Kartu Kredit')], blank=True, null=True)
    nama_asuransi = models.CharField(max_length=100, blank=True, null=True)
    nomor_asuransi = models.CharField(max_length=50, blank=True, null=True)
    tanggal_lahir = models.DateField(blank=True, null=True)
    golongan_darah = models.CharField(max_length=2, choices=[('A', 'A'), ('B', 'B'), ('AB', 'AB'), ('O', 'O')], blank=True)
    berat_badan = models.DecimalField(max_digits=5, decimal_places=1, blank=True, null=True)
    tinggi_badan = models.DecimalField(max_digits=5, decimal_places=1, blank=True, null=True)
    riwayat_penyakit = models.TextField(blank=True)
    riwayat_alergi = models.TextField(blank=True)
    riwayat_pengobatan = models.TextField(blank=True)
    obat_saat_ini = models.TextField(blank=True)

    def __str__(self):
        return self.nama
    
logger = logging.getLogger(__name__)

class JanjiTemu(models.Model):
    STATUS_CHOICES = [
        ('Menunggu', 'Menunggu'),
        ('Dipanggil', 'Dipanggil'),
        ('Selesai', 'Selesai'),
    ]
    STATUS_PEMBAYARAN_CHOICES = [
        ('Menunggu Pembayaran', 'Menunggu Pembayaran'),
        ('Dibayar', 'Dibayar'),
        ('Gagal', 'Gagal'),
    ]
    pasien = models.ForeignKey(Pasien, on_delete=models.CASCADE)
    dokter = models.ForeignKey(Dokter, on_delete=models.CASCADE)
    tanggal = models.DateTimeField()
    keluhan_utama = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Menunggu')
    status_pembayaran = models.CharField(max_length=50, choices=STATUS_PEMBAYARAN_CHOICES, default='Menunggu Pembayaran')
    biaya_konsultasi = models.DecimalField(max_digits=10, decimal_places=2, default=100000.00)
    transaction_id = models.CharField(max_length=100, blank=True, null=True)
    kode_antrian = models.CharField(max_length=20, blank=True, unique=True)
    diperiksa_perawat = models.BooleanField(default=False)  # Field baru

    def __str__(self):
        return f"Janji Temu - {self.pasien.nama} dengan {self.dokter.nama}"

    def save(self, *args, **kwargs):
        if not self.kode_antrian:
            date_str = self.tanggal.strftime('%Y%m%d')
            base_code = f"U{date_str}-"
            attempts = 50
            for i in range(1, attempts + 1):
                code = f"{base_code}{str(i).zfill(3)}"
                if not JanjiTemu.objects.filter(kode_antrian=code).exists():
                    self.kode_antrian = code
                    break
            else:
                raise ValueError("Gagal menghasilkan kode antrian unik setelah beberapa percobaan.")
        super().save(*args, **kwargs)

class RekamMedis(models.Model):
    pasien = models.ForeignKey(Pasien, on_delete=models.CASCADE)
    dokter = models.ForeignKey(Dokter, on_delete=models.CASCADE)
    tanggal = models.DateTimeField(auto_now_add=True)
    diagnosa = models.TextField()
    resep = models.OneToOneField('apoteker.Resep', on_delete=models.SET_NULL, null=True, blank=True)
    catatan = models.TextField(blank=True)

    def __str__(self):
        return f"Rekam Medis {self.pasien} - {self.dokter}"
    
class Konsultasi(models.Model):
    STATUS_CHOICES = [
        ('Menunggu', 'Menunggu'),
        ('Direspons', 'Direspons'),
        ('Selesai', 'Selesai'),
    ]

    pasien = models.ForeignKey(Pasien, on_delete=models.CASCADE, related_name='konsultasi')
    dokter = models.ForeignKey(Dokter, on_delete=models.CASCADE, related_name='konsultasi')
    tanggal_konsultasi = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Menunggu')
    waktu_aktivitas_terakhir = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Konsultasi {self.pasien.nama} dengan Dr. {self.dokter.nama} pada {self.tanggal_konsultasi}"

    def update_waktu_aktivitas(self):
        self.waktu_aktivitas_terakhir = timezone.now()
        self.save()

    def cek_timer(self):
        if self.status == 'Direspons' and self.waktu_aktivitas_terakhir:
            waktu_sekarang = timezone.now()
            selisih_waktu = (waktu_sekarang - self.waktu_aktivitas_terakhir).total_seconds()
            if selisih_waktu >= 30 * 60:
                self.status = 'Selesai'
                self.save()
                return True
        return False

class PesanKonsultasi(models.Model):
    konsultasi = models.ForeignKey(Konsultasi, on_delete=models.CASCADE, related_name='pesan')
    pengirim = models.CharField(max_length=20, choices=[('Pasien', 'Pasien'), ('Dokter', 'Dokter')])
    isi = models.TextField()
    tanggal_kirim = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Pesan dari {self.pengirim} pada {self.tanggal_kirim}"