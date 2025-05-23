from django.db import models
from dokter.models import Pasien, Dokter

class Obat(models.Model):
    nama = models.CharField(max_length=100)
    stok = models.IntegerField(default=0)
    harga = models.DecimalField(max_digits=10, decimal_places=2)
    deskripsi = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.nama

    def kurangi_stok(self, jumlah):
        if self.stok >= jumlah:
            self.stok -= jumlah
            self.save()
            return True
        return False

class Resep(models.Model):
    STATUS_CHOICES = [
        ('Menunggu', 'Menunggu'),
        ('Diproses', 'Diproses'),
        ('Selesai', 'Selesai'),
    ]
    STATUS_PEMBAYARAN_CHOICES = [
        ('Belum Dibayar', 'Belum Dibayar'),
        ('Sedang Diproses', 'Sedang Diproses'),
        ('Dibayar', 'Dibayar'),
        ('Gagal', 'Gagal'),
    ]
    dokter = models.ForeignKey(Dokter, on_delete=models.CASCADE)
    pasien = models.ForeignKey(Pasien, on_delete=models.CASCADE)
    tanggal_dibuat = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Menunggu')
    catatan = models.TextField(blank=True, null=True)
    status_pembayaran = models.CharField(
        max_length=20,
        choices=STATUS_PEMBAYARAN_CHOICES,
        default='Belum Dibayar'
    )
    midtrans_transaction_id = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        help_text="ID transaksi dari Midtrans"
    )

    def __str__(self):
        return f"Resep {self.id} - {self.pasien.nama} ({self.status})"

class DetailResep(models.Model):
    resep = models.ForeignKey(Resep, on_delete=models.CASCADE, related_name='detail')
    obat = models.ForeignKey(Obat, on_delete=models.CASCADE)
    jumlah = models.IntegerField()

    def __str__(self):
        return f"{self.obat.nama} (x{self.jumlah})"

class Apoteker(models.Model):
    user = models.OneToOneField('auth.User', on_delete=models.CASCADE)
    nama = models.CharField(max_length=100)
    nomor_lisensi = models.CharField(max_length=50)
    telepon = models.CharField(max_length=15)

    def __str__(self):
        return self.nama

class PengeluaranObat(models.Model):
    resep = models.OneToOneField(Resep, on_delete=models.CASCADE)  # Ubah ke OneToOneField
    apoteker = models.ForeignKey(Apoteker, on_delete=models.CASCADE)
    tanggal_pengeluaran = models.DateTimeField(auto_now_add=True)
    catatan = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Pengeluaran untuk Resep {self.resep.id}"