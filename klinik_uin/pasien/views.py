from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from dokter.models import Pasien, JanjiTemu, Dokter, Poli  # Impor Poli
from datetime import datetime
import pytz
from dokter.models import Konsultasi, PesanKonsultasi  # Impor model baru
from django.utils import timezone
from apoteker.models import PengeluaranObat, Resep
from django.conf import settings
import midtransclient
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
import logging

@csrf_exempt
def midtrans_callback(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        order_id = data.get('order_id')
        status_code = data.get('status_code')
        transaction_status = data.get('transaction_status')

        # Tentukan apakah ini untuk JanjiTemu atau Resep berdasarkan order_id
        if order_id.startswith('JT-'):
            try:
                janji_temu = JanjiTemu.objects.get(transaction_id=order_id)
                if transaction_status == 'settlement':
                    janji_temu.status_pembayaran = 'Dibayar'
                elif transaction_status in ['pending']:
                    janji_temu.status_pembayaran = 'Menunggu Pembayaran'
                elif transaction_status in ['deny', 'cancel', 'expire']:
                    janji_temu.status_pembayaran = 'Gagal'
                janji_temu.save()
                return JsonResponse({'status': 'success'})
            except JanjiTemu.DoesNotExist:
                pass
        elif order_id.startswith('RESEP-'):
            try:
                resep = Resep.objects.get(midtrans_transaction_id=order_id)
                if transaction_status == 'settlement':
                    resep.status_pembayaran = 'Dibayar'
                elif transaction_status in ['pending']:
                    resep.status_pembayaran = 'Sedang Diproses'
                elif transaction_status in ['deny', 'cancel', 'expire']:
                    resep.status_pembayaran = 'Gagal'
                resep.save()
                return JsonResponse({'status': 'success'})
            except Resep.DoesNotExist:
                pass

        return JsonResponse({'status': 'error', 'message': 'Transaksi tidak ditemukan'}, status=404)

    return JsonResponse({'status': 'error', 'message': 'Invalid request'}, status=400)

@login_required
def detail_resep_pasien(request, resep_id):
    pasien = request.user.pasien
    resep = get_object_or_404(Resep, id=resep_id, pasien=pasien)
    
    # Ambil informasi pengeluaran obat (jika ada)
    try:
        pengeluaran = resep.pengeluaranobat
    except PengeluaranObat.DoesNotExist:
        pengeluaran = None
    
    # Hitung total keseluruhan harga dari semua obat dalam resep
    total_resep = sum(detail.jumlah * detail.obat.harga for detail in resep.detail.all())

    context = {
        'resep': resep,
        'pengeluaran': pengeluaran,
        'total_resep': total_resep,
    }
    return render(request, 'pasien/detail_resep.html', context)

def register_pasien(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        nik = request.POST.get('nik')
        nama = request.POST.get('nama')
        telepon = request.POST.get('telepon')
        email = request.POST.get('email')
        alamat = request.POST.get('alamat')
        jenis_kelamin = request.POST.get('jenis_kelamin')
        metode_pembayaran = request.POST.get('metode_pembayaran')
        nama_asuransi = request.POST.get('nama_asuransi')
        nomor_asuransi = request.POST.get('nomor_asuransi')
        tanggal_lahir = request.POST.get('tanggal_lahir')

        if Pasien.objects.filter(nik=nik).exists():
            messages.error(request, "NIK sudah terdaftar.")
            return redirect('pasien:register_pasien')

        from django.contrib.auth.models import User
        user = User.objects.create_user(username=username, password=password, email=email)
        pasien = Pasien.objects.create(
            user=user,
            nik=nik,
            nama=nama,
            telepon=telepon,
            email=email,
            alamat=alamat,
            jenis_kelamin=jenis_kelamin,
            metode_pembayaran=metode_pembayaran,
            nama_asuransi=nama_asuransi,
            nomor_asuransi=nomor_asuransi,
            tanggal_lahir=tanggal_lahir,
        )
        messages.success(request, "Registrasi berhasil. Silakan login.")
        return redirect('pasien:login_pasien')

    return render(request, 'pasien/register.html')

def login_pasien(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user and hasattr(user, 'pasien'):
            login(request, user)
            messages.success(request, "Login berhasil.")
            return redirect('pasien:pasien_dashboard')
        else:
            messages.error(request, "Username atau password salah.")
    return render(request, 'pasien/login.html')

def logout_pasien(request):
    logout(request)
    messages.success(request, "Logout berhasil.")
    return redirect('pasien:login_pasien')

logger = logging.getLogger(__name__)

@login_required
def pasien_dashboard(request):
    pasien = request.user.pasien
    janji_temu = JanjiTemu.objects.filter(pasien=pasien)
    dokters = Dokter.objects.filter(poli__isnull=False)
    poli_list = Poli.objects.all()
    konsultasi = Konsultasi.objects.filter(pasien=pasien).order_by('-tanggal_konsultasi')
    resep_list = Resep.objects.filter(pasien=pasien).order_by('-tanggal_dibuat')

    for k in konsultasi:
        k.cek_timer()

    if request.method == 'POST' and 'buat_janji' in request.POST:
        dokter_id = request.POST.get('dokter')
        tanggal_str = request.POST.get('tanggal')
        keluhan = request.POST.get('keluhan')

        if not dokter_id:
            messages.error(request, "Harap pilih dokter.")
            return redirect('pasien:pasien_dashboard')

        try:
            dokter = Dokter.objects.get(id=dokter_id, poli__isnull=False)
        except Dokter.DoesNotExist:
            messages.error(request, "Dokter tidak ditemukan atau tidak memiliki poli. Silakan pilih dokter lain.")
            return redirect('pasien:pasien_dashboard')

        try:
            tanggal_naive = datetime.strptime(tanggal_str, '%Y-%m-%dT%H:%M')
            wib = pytz.timezone('Asia/Jakarta')
            tanggal = wib.localize(tanggal_naive).astimezone(pytz.UTC)  # Konversi ke UTC
        except ValueError:
            messages.error(request, "Format tanggal tidak valid. Gunakan format YYYY-MM-DD HH:MM.")
            return redirect('pasien:pasien_dashboard')

        # Buat janji temu
        janji_temu = JanjiTemu.objects.create(
            pasien=pasien,
            dokter=dokter,
            tanggal=tanggal,
            keluhan_utama=keluhan,
            status_pembayaran='Menunggu Pembayaran'
        )

        # Validasi biaya konsultasi
        if janji_temu.biaya_konsultasi <= 0:
            janji_temu.status_pembayaran = 'Gagal'
            janji_temu.save()
            messages.error(request, "Biaya konsultasi tidak valid. Harus lebih besar dari 0.")
            logger.error(f"Biaya konsultasi tidak valid untuk JanjiTemu ID {janji_temu.id}: {janji_temu.biaya_konsultasi}")
            return redirect('pasien:pasien_dashboard')

        # Buat transaksi Midtrans
        snap = midtransclient.Snap(
            is_production=settings.MIDTRANS_IS_PRODUCTION,
            server_key=settings.MIDTRANS_SERVER_KEY,
            client_key=settings.MIDTRANS_CLIENT_KEY
        )

        transaction_data = {
            "transaction_details": {
                "order_id": f"JT-{janji_temu.id}",
                "gross_amount": int(janji_temu.biaya_konsultasi)
            },
            "customer_details": {
                "first_name": pasien.nama,
                "email": pasien.email or "pasien@example.com",
                "phone": pasien.telepon
            },
            "item_details": [
                {
                    "id": f"JT-{janji_temu.id}",
                    "price": int(janji_temu.biaya_konsultasi),
                    "quantity": 1,
                    "name": f"Konsultasi dengan {dokter.nama}"
                }
            ]
        }

        logger.info(f"Mencoba membuat transaksi Midtrans untuk JanjiTemu ID {janji_temu.id}, order_id: {transaction_data['transaction_details']['order_id']}")
        logger.debug(f"Data transaksi: {transaction_data}")

        try:
            transaction = snap.create_transaction(transaction_data)
            if 'token' not in transaction:
                raise ValueError("Respons Midtrans tidak mengandung token")
            transaction_token = transaction['token']
            janji_temu.transaction_id = transaction_data['transaction_details']['order_id']
            janji_temu.save()
            logger.info(f"Transaksi berhasil dibuat untuk JanjiTemu ID {janji_temu.id}, token: {transaction_token}")
            messages.success(request, f"Janji temu berhasil dibuat. Silakan lakukan pembayaran untuk mengkonfirmasi.")
            return render(request, 'pasien/payment.html', {
                'transaction_token': transaction_token,
                'janji_temu': janji_temu,
                'midtrans_client_key': settings.MIDTRANS_CLIENT_KEY
            })
        except Exception as e:
            janji_temu.status_pembayaran = 'Gagal'
            janji_temu.save()
            error_message = f"Gagal membuat transaksi Midtrans untuk JanjiTemu ID {janji_temu.id}: {str(e)}"
            logger.error(error_message, exc_info=True)
            messages.error(request, error_message)
            return redirect('pasien:pasien_dashboard')

    context = {
        'janji_temu': janji_temu,
        'dokters': dokters,
        'poli_list': poli_list,
        'konsultasi': konsultasi,
        'resep_list': resep_list,
    }
    return render(request, 'pasien/dashboard.html', context)

@login_required
def edit_profil_pasien(request):
    pasien = request.user.pasien

    if request.method == 'POST':
        nik = request.POST.get('nik')
        if Pasien.objects.filter(nik=nik).exclude(id=pasien.id).exists():
            messages.error(request, "NIK sudah digunakan oleh pasien lain.")
        else:
            pasien.nik = nik
            pasien.nama = request.POST.get('nama')
            pasien.telepon = request.POST.get('telepon')
            pasien.golongan_darah = request.POST.get('golongan_darah')
            pasien.berat_badan = request.POST.get('berat_badan')
            pasien.tinggi_badan = request.POST.get('tinggi_badan')
            pasien.riwayat_penyakit = request.POST.get('riwayat_penyakit')
            pasien.riwayat_alergi = request.POST.get('riwayat_alergi')
            pasien.riwayat_pengobatan = request.POST.get('riwayat_pengobatan')
            pasien.obat_saat_ini = request.POST.get('obat_saat_ini')
            pasien.email = request.POST.get('email', pasien.email)
            pasien.alamat = request.POST.get('alamat', pasien.alamat)
            pasien.jenis_kelamin = request.POST.get('jenis_kelamin', pasien.jenis_kelamin)
            pasien.metode_pembayaran = request.POST.get('metode_pembayaran', pasien.metode_pembayaran)
            pasien.nama_asuransi = request.POST.get('nama_asuransi', pasien.nama_asuransi)
            pasien.nomor_asuransi = request.POST.get('nomor_asuransi', pasien.nomor_asuransi)
            pasien.tanggal_lahir = request.POST.get('tanggal_lahir', pasien.tanggal_lahir)
            pasien.save()
            messages.success(request, "Profil berhasil diperbarui.")
            return redirect('pasien:pasien_dashboard')

    context = {
        'pasien': pasien,
    }
    return render(request, 'pasien/edit_profil.html', context)

@login_required
def konsultasi_online(request):
    pasien = request.user.pasien
    dokters = Dokter.objects.all()
    poli_list = Poli.objects.all()

    if request.method == 'POST':
        dokter_id = request.POST.get('dokter')
        keluhan = request.POST.get('keluhan')
        dokter = get_object_or_404(Dokter, id=dokter_id)
        # Buat konsultasi baru
        konsultasi = Konsultasi.objects.create(
            pasien=pasien,
            dokter=dokter,
        )
        # Tambahkan pesan awal dari pasien
        PesanKonsultasi.objects.create(
            konsultasi=konsultasi,
            pengirim='Pasien',
            isi=keluhan,
        )
        messages.success(request, "Konsultasi online berhasil dikirim. Tunggu respons dari dokter.")
        return redirect('pasien:pasien_dashboard')

    return render(request, 'pasien/konsultasi_online.html', {
        'pasien': pasien,
        'dokters': dokters,
        'poli_list': poli_list,
    })

@login_required
def detail_konsultasi_pasien(request, konsultasi_id):

    pasien = request.user.pasien
    konsultasi = get_object_or_404(Konsultasi, id=konsultasi_id, pasien=pasien)
    
    konsultasi.cek_timer()

    if request.method == 'POST':
        isi_pesan = request.POST.get('isi_pesan')
        if konsultasi.status == 'Selesai':
            messages.error(request, "Konsultasi ini sudah selesai. Anda tidak dapat mengirim pesan lagi.")
        else:
            PesanKonsultasi.objects.create(
                konsultasi=konsultasi,
                pengirim='Pasien',
                isi=isi_pesan,
            )
            konsultasi.update_waktu_aktivitas()  # Reset timer
            messages.success(request, "Pesan berhasil dikirim.")
        return redirect('pasien:detail_konsultasi_pasien', konsultasi_id=konsultasi.id)

    # Hitung sisa waktu (dalam detik) untuk digunakan di JavaScript
    sisa_waktu = 0
    if konsultasi.status == 'Direspons' and konsultasi.waktu_aktivitas_terakhir:
        waktu_sekarang = timezone.now()
        selisih_waktu = (waktu_sekarang - konsultasi.waktu_aktivitas_terakhir).total_seconds()
        sisa_waktu = max(0, (30 * 60) - selisih_waktu)  # Sisa waktu dalam detik (30 menit = 1800 detik)

    return render(request, 'pasien/detail_konsultasi.html', {
        'konsultasi': konsultasi,
        'sisa_waktu': int(sisa_waktu),  # Kirim sisa waktu ke template
    })

@login_required
def payment(request, resep_id):
    pasien = request.user.pasien
    resep = get_object_or_404(Resep, id=resep_id, pasien=pasien)
    
    logger.info(f"Memulai pembayaran untuk Resep ID {resep.id} oleh {pasien.nama}")

    if resep.status_pembayaran != 'Belum Dibayar':
        messages.error(request, "Resep ini sudah dalam proses pembayaran atau telah dibayar.")
        logger.warning(f"Pembayaran ditolak untuk Resep ID {resep.id}: Status {resep.status_pembayaran}")
        return redirect('pasien:detail_resep_pasien', resep_id=resep.id)

    # Hitung total resep
    total_resep = sum(detail.jumlah * detail.obat.harga for detail in resep.detail.all())
    logger.info(f"Total biaya untuk Resep ID {resep.id}: {total_resep}")

    if total_resep <= 0:
        resep.status_pembayaran = 'Gagal'
        resep.save()
        logger.error(f"Total biaya tidak valid untuk Resep ID {resep.id}: {total_resep}")
        messages.error(request, "Total biaya tidak valid. Harus lebih besar dari 0.")
        return redirect('pasien:detail_resep_pasien', resep_id=resep.id)

    # Buat transaksi Midtrans
    snap = midtransclient.Snap(
        is_production=settings.MIDTRANS_IS_PRODUCTION,
        server_key=settings.MIDTRANS_SERVER_KEY,
        client_key=settings.MIDTRANS_CLIENT_KEY
    )

    order_id = f"RESEP-{resep.id}"
    if resep.midtrans_transaction_id:
        logger.warning(f"Order ID {order_id} sudah ada untuk Resep ID {resep.id}. Mencoba memeriksa status.")
        try:
            status_response = snap.status(order_id)
            logger.info(f"Status transaksi untuk Order ID {order_id}: {status_response}")
            if status_response['transaction_status'] in ['settlement', 'capture']:
                resep.status_pembayaran = 'Dibayar'
                resep.save()
                messages.success(request, "Pembayaran sudah selesai sebelumnya.")
                return redirect('pasien:detail_resep_pasien', resep_id=resep.id)
            elif status_response['transaction_status'] in ['pending']:
                messages.warning(request, "Pembayaran masih dalam proses. Silakan tunggu.")
                return redirect('pasien:detail_resep_pasien', resep_id=resep.id)
            elif status_response['transaction_status'] in ['deny', 'cancel', 'expire']:
                resep.status_pembayaran = 'Gagal'
                resep.midtrans_transaction_id = None  # Reset untuk mencoba ulang
                resep.save()
                logger.info(f"Transaksi sebelumnya gagal untuk Order ID {order_id}. Mencoba ulang.")
        except Exception as e:
            logger.error(f"Gagal memeriksa status transaksi untuk Order ID {order_id}: {str(e)}")

    # Jika order_id sudah ada di Midtrans tetapi tidak di database, tambahkan suffix unik
    attempt = 1
    while True:
        try:
            transaction_data = {
                "transaction_details": {
                    "order_id": order_id if attempt == 1 else f"{order_id}-{attempt}",
                    "gross_amount": int(total_resep)
                },
                "customer_details": {
                    "first_name": pasien.nama,
                    "email": pasien.email or "pasien@example.com",
                    "phone": pasien.telepon
                },
                "item_details": [
                    {
                        "id": f"OBAT-{detail.id}",
                        "price": int(detail.obat.harga),
                        "quantity": detail.jumlah,
                        "name": detail.obat.nama
                    } for detail in resep.detail.all()
                ]
            }

            logger.debug(f"Data transaksi Midtrans: {transaction_data}")
            transaction = snap.create_transaction(transaction_data)
            if 'token' not in transaction:
                raise ValueError("Respons Midtrans tidak mengandung token")
            transaction_token = transaction['token']
            resep.midtrans_transaction_id = transaction_data['transaction_details']['order_id']
            resep.status_pembayaran = 'Sedang Diproses'
            resep.save()
            logger.info(f"Transaksi Midtrans berhasil dibuat untuk Resep ID {resep.id}, token: {transaction_token}")
            return render(request, 'pasien/payment_resep.html', {
                'transaction_token': transaction_token,
                'resep': resep,
                'midtrans_client_key': settings.MIDTRANS_CLIENT_KEY,
                'total_resep': total_resep,
            })
        except midtransclient.error.TransactionError as e:
            if "order_id has already been taken" in str(e):
                attempt += 1
                logger.warning(f"Order ID {order_id} sudah digunakan. Mencoba dengan suffix {attempt}")
                continue
            raise
        except Exception as e:
            resep.status_pembayaran = 'Gagal'
            resep.save()
            logger.error(f"Gagal membuat transaksi Midtrans untuk Resep ID {resep.id}: {str(e)}", exc_info=True)
            messages.error(request, f"Gagal membuat transaksi pembayaran: {str(e)}")
            return redirect('pasien:detail_resep_pasien', resep_id=resep.id)