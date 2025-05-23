from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.exceptions import ObjectDoesNotExist
from .models import Apoteker, Resep, Obat, DetailResep, PengeluaranObat
from django.urls import reverse
from django.contrib.auth.views import LoginView
from django.contrib.auth import logout  # Tambah impor ini

class CustomLoginViewApoteker(LoginView):
    template_name = 'apoteker/login.html'

    def get_success_url(self):
        user = self.request.user
        if user.is_authenticated:
            try:
                user.apoteker
                return reverse('apoteker:dashboard_apoteker')
            except AttributeError:
                messages.error(self.request, "Akun Anda tidak memiliki akses sebagai apoteker.")
                return reverse('apoteker:login_apoteker')
        return reverse('apoteker:login_apoteker')

@login_required
def dashboard_apoteker(request):
    try:
        apoteker = request.user.apoteker
        resep_menunggu = Resep.objects.filter(status='Menunggu').order_by('-tanggal_dibuat')
        resep_diproses = Resep.objects.filter(status='Diproses').order_by('-tanggal_dibuat')
        resep_selesai = Resep.objects.filter(status='Selesai').order_by('-tanggal_dibuat')

        return render(request, 'apoteker/dashboard.html', {
            'apoteker': apoteker,
            'resep_menunggu': resep_menunggu,
            'resep_diproses': resep_diproses,
            'resep_selesai': resep_selesai,
        })
    except ObjectDoesNotExist:
        messages.error(request, "Akun Anda belum terdaftar sebagai apoteker. Silakan hubungi admin.")
        return redirect('apoteker:login_apoteker')

@login_required
def proses_resep(request, resep_id):
    try:
        apoteker = request.user.apoteker
        resep = get_object_or_404(Resep, id=resep_id)

        if resep.status == 'Selesai':
            messages.error(request, "Resep ini sudah selesai dan tidak dapat diproses lagi.")
            return redirect('apoteker:dashboard_apoteker')

        if request.method == 'POST':
            # Ubah status menjadi "Diproses"
            resep.status = 'Diproses'
            resep.save()
            messages.success(request, f"Resep untuk {resep.pasien.nama} sedang diproses.")
            return redirect('apoteker:dashboard_apoteker')

        return render(request, 'apoteker/proses_resep.html', {
            'resep': resep,
            'apoteker': apoteker,
        })
    except ObjectDoesNotExist:
        messages.error(request, "Akun Anda belum terdaftar sebagai apoteker. Silakan hubungi admin.")
        return redirect('apoteker:login_apoteker')

@login_required
def keluarkan_obat(request, resep_id):
    try:
        apoteker = request.user.apoteker
        resep = get_object_or_404(Resep, id=resep_id)

        if resep.status == 'Selesai':
            messages.error(request, "Resep ini sudah selesai dan obat sudah dikeluarkan.")
            return redirect('apoteker:dashboard_apoteker')

        if request.method == 'POST':
            catatan = request.POST.get('catatan', '')
            # Cek stok obat
            for detail in resep.detail.all():
                if not detail.obat.kurangi_stok(detail.jumlah):
                    messages.error(request, f"Stok {detail.obat.nama} tidak mencukupi. Sisa stok: {detail.obat.stok}")
                    return redirect('apoteker:keluarkan_obat', resep_id=resep.id)

            # Catat pengeluaran obat
            PengeluaranObat.objects.create(
                resep=resep,
                apoteker=apoteker,
                catatan=catatan
            )
            # Ubah status resep menjadi "Selesai"
            resep.status = 'Selesai'
            resep.save()
            messages.success(request, f"Obat untuk {resep.pasien.nama} berhasil dikeluarkan.")
            return redirect('apoteker:dashboard_apoteker')

        return render(request, 'apoteker/keluarkan_obat.html', {
            'resep': resep,
            'apoteker': apoteker,
        })
    except ObjectDoesNotExist:
        messages.error(request, "Akun Anda belum terdaftar sebagai apoteker. Silakan hubungi admin.")
        return redirect('apoteker:login_apoteker')

@login_required
def kelola_obat(request):
    try:
        apoteker = request.user.apoteker
        obat_list = Obat.objects.all()

        if request.method == 'POST':
            nama = request.POST.get('nama')
            stok = request.POST.get('stok')
            harga = request.POST.get('harga')
            deskripsi = request.POST.get('deskripsi', '')

            if Obat.objects.filter(nama=nama).exists():
                messages.error(request, f"Obat dengan nama {nama} sudah ada.")
            else:
                Obat.objects.create(
                    nama=nama,
                    stok=int(stok),
                    harga=float(harga),
                    deskripsi=deskripsi
                )
                messages.success(request, f"Obat {nama} berhasil ditambahkan.")
            return redirect('apoteker:kelola_obat')

        return render(request, 'apoteker/kelola_obat.html', {
            'apoteker': apoteker,
            'obat_list': obat_list,
        })
    except ObjectDoesNotExist:
        messages.error(request, "Akun Anda belum terdaftar sebagai apoteker. Silakan hubungi admin.")
        return redirect('apoteker:login_apoteker')

@login_required
def edit_obat(request, obat_id):
    try:
        apoteker = request.user.apoteker
        obat = get_object_or_404(Obat, id=obat_id)

        if request.method == 'POST':
            nama = request.POST.get('nama')
            stok = request.POST.get('stok')
            harga = request.POST.get('harga')
            deskripsi = request.POST.get('deskripsi', '')

            if Obat.objects.filter(nama=nama).exclude(id=obat.id).exists():
                messages.error(request, f"Obat dengan nama {nama} sudah ada.")
            else:
                obat.nama = nama
                obat.stok = int(stok)
                obat.harga = float(harga)
                obat.deskripsi = deskripsi
                obat.save()
                messages.success(request, f"Obat {nama} berhasil diperbarui.")
            return redirect('apoteker:kelola_obat')

        return render(request, 'apoteker/edit_obat.html', {
            'apoteker': apoteker,
            'obat': obat,
        })
    except ObjectDoesNotExist:
        messages.error(request, "Akun Anda belum terdaftar sebagai apoteker. Silakan hubungi admin.")
        return redirect('apoteker:login_apoteker')

@login_required
def detail_resep_selesai(request, resep_id):
    try:
        apoteker = request.user.apoteker
        # Pastikan resep selesai dan terkait dengan apoteker ini
        resep = get_object_or_404(
            Resep,
            id=resep_id,
            status='Selesai',
            pengeluaranobat__apoteker=apoteker
        )
        
        # Ambil informasi pengeluaran obat
        pengeluaran = resep.pengeluaranobat_set.first()
        
        context = {
            'resep': resep,
            'pengeluaran': pengeluaran,
        }
        return render(request, 'apoteker/detail_resep_selesai.html', context)
    except ObjectDoesNotExist:
        messages.error(request, "Akun Anda belum terdaftar sebagai apoteker. Silakan hubungi admin.")
        return redirect('apoteker:login_apoteker')

@login_required
def logout_apoteker(request):
    logout(request)
    messages.success(request, "Logout berhasil.")
    return redirect('apoteker:login_apoteker')