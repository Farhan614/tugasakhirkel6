from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login, authenticate, logout
from django.contrib.auth.forms import AuthenticationForm
from django.contrib import messages
from django.utils import timezone
from dokter.models import JanjiTemu
from perawat.models import Perawat, PemeriksaanAwal
import logging
from dokter.models import Poli
from django.contrib.auth.models import User
import pytz

logger = logging.getLogger(__name__)

def login_perawat(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None and hasattr(user, 'perawat'):
                login(request, user)
                logger.info(f"Perawat {username} berhasil login pada {timezone.now()}")
                messages.success(request, f"Selamat datang, {user.perawat.nama}!")
                return redirect('perawat:dashboard_perawat')
            else:
                messages.error(request, "Akun ini bukan perawat atau kredensial salah.")
        else:
            messages.error(request, "Username atau password salah.")
    else:
        form = AuthenticationForm()
    return render(request, 'perawat/login.html', {'form': form})

def logout_perawat(request):
    logout(request)
    messages.success(request, "Anda telah logout.")
    return redirect('perawat:login_perawat')

def register_perawat(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        nama = request.POST.get('nama')
        telepon = request.POST.get('telepon')
        email = request.POST.get('email')
        poli_id = request.POST.get('poli')

        if User.objects.filter(username=username).exists():
            messages.error(request, "Username sudah digunakan.")
            return redirect('perawat:register_perawat')

        try:
            poli = Poli.objects.get(id=poli_id)
            user = User.objects.create_user(username=username, password=password, email=email)
            Perawat.objects.create(
                user=user,
                nama=nama,
                telepon=telepon,
                email=email,
                poli=poli
            )
            logger.info(f"Perawat baru {username} berhasil terdaftar pada {timezone.now()}")
            messages.success(request, f"Registrasi berhasil untuk {nama}. Silakan login.")
            return redirect('perawat:login_perawat')
        except Poli.DoesNotExist:
            messages.error(request, "Poli tidak ditemukan.")
        except Exception as e:
            messages.error(request, f"Terjadi kesalahan: {str(e)}")
    else:
        polies = Poli.objects.all()
        return render(request, 'perawat/register.html', {'polies': polies})
    
@login_required
def profile_perawat(request):
    perawat = request.user.perawat
    return render(request, 'perawat/profile.html', {'perawat': perawat})
    

@login_required
def dashboard_perawat(request):
    try:
        perawat = request.user.perawat
        wib = pytz.timezone('Asia/Jakarta')
        today = timezone.localtime(timezone.now(), wib).date()

        # Debugging: Cetak tanggal dalam UTC dan WIB
        now_utc = timezone.now()
        now_wib = timezone.localtime(now_utc, wib)
        logger.info(f"Now UTC: {now_utc}, Now WIB: {now_wib}, Today: {today}")

        # Filter tanggal dengan cara manual untuk menghindari masalah CONVERT_TZ
        start_of_day_wib = wib.localize(timezone.datetime(today.year, today.month, today.day, 0, 0, 0))
        end_of_day_wib = wib.localize(timezone.datetime(today.year, today.month, today.day, 23, 59, 59))
        start_of_day_utc = start_of_day_wib.astimezone(pytz.UTC)
        end_of_day_utc = end_of_day_wib.astimezone(pytz.UTC)

        # Janji temu yang belum diperiksa perawat, pada hari ini
        janji_temu_hari_ini = JanjiTemu.objects.filter(
            dokter__poli=perawat.poli,
            tanggal__range=(start_of_day_utc, end_of_day_utc),
            status__in=['Menunggu', 'Dipanggil'],
            diperiksa_perawat=False
        ).order_by('tanggal')

        # Janji temu yang belum diperiksa, tetapi di luar hari ini
        janji_temu_lain = JanjiTemu.objects.filter(
            dokter__poli=perawat.poli,
            status__in=['Menunggu', 'Dipanggil'],
            diperiksa_perawat=False
        ).exclude(tanggal__range=(start_of_day_utc, end_of_day_utc)).order_by('tanggal')

        # Janji temu yang sudah diperiksa perawat
        janji_temu_selesai = JanjiTemu.objects.filter(
            dokter__poli=perawat.poli,
            tanggal__range=(start_of_day_utc, end_of_day_utc),
            status__in=['Menunggu', 'Dipanggil'],
            diperiksa_perawat=True
        ).order_by('tanggal')

        # Debugging: Tampilkan semua janji temu tanpa filter poli
        semua_janji_temu = JanjiTemu.objects.filter(
            tanggal__range=(start_of_day_utc, end_of_day_utc),
            status__in=['Menunggu', 'Dipanggil'],
            diperiksa_perawat=False
        ).order_by('tanggal')

        # Logging untuk debugging
        logger.info(f"Perawat: {perawat.nama}, Today: {today}")
        logger.info(f"Poli Perawat: {perawat.poli}")
        logger.info(f"Start of Day (UTC): {start_of_day_utc}, End of Day (UTC): {end_of_day_utc}")
        logger.info(f"Janji Temu Hari Ini (Belum Diperiksa) - Query Raw: {JanjiTemu.objects.filter(dokter__poli=perawat.poli, tanggal__range=(start_of_day_utc, end_of_day_utc), status__in=['Menunggu', 'Dipanggil'], diperiksa_perawat=False).query}")
        logger.info(f"Janji Temu Hari Ini (Belum Diperiksa): {list(janji_temu_hari_ini.values('id', 'tanggal', 'status', 'diperiksa_perawat', 'dokter__poli__nama', 'pasien__nama'))}")
        logger.info(f"Janji Temu Lain (Belum Diperiksa, Tanggal Lain): {list(janji_temu_lain.values('id', 'tanggal', 'status', 'diperiksa_perawat', 'dokter__poli__nama', 'pasien__nama'))}")
        logger.info(f"Janji Temu Selesai (Sudah Diperiksa): {list(janji_temu_selesai.values('id', 'tanggal', 'status', 'diperiksa_perawat', 'dokter__poli__nama', 'pasien__nama'))}")
        logger.info(f"Semua Janji Temu (Tanpa Filter Poli): {list(semua_janji_temu.values('id', 'tanggal', 'status', 'diperiksa_perawat', 'dokter__poli__nama', 'pasien__nama'))}")

        return render(request, 'perawat/dashboard.html', {
            'janji_temu_hari_ini': janji_temu_hari_ini,
            'janji_temu_lain': janji_temu_lain,
            'janji_temu_selesai': janji_temu_selesai,
            'nama_perawat': perawat.nama,
            'poli': perawat.poli,
            'today': today,
        })
    except AttributeError:
        messages.error(request, "Akun Anda belum terdaftar sebagai perawat. Silakan hubungi admin.")
        return redirect('login')

@login_required
def periksa_pasien(request, janji_temu_id):
    perawat = request.user.perawat
    janji_temu = get_object_or_404(JanjiTemu, id=janji_temu_id, dokter__poli=perawat.poli)

    if janji_temu.diperiksa_perawat:
        messages.error(request, "Pasien ini sudah diperiksa oleh perawat.")
        return redirect('perawat:dashboard_perawat')

    if request.method == 'POST':
        tekanan_darah = request.POST.get('tekanan_darah')
        suhu_badan = request.POST.get('suhu_badan')
        berat_badan = request.POST.get('berat_badan')
        tinggi_badan = request.POST.get('tinggi_badan')
        catatan = request.POST.get('catatan')

        # Buat pemeriksaan awal
        PemeriksaanAwal.objects.create(
            janji_temu=janji_temu,
            perawat=perawat,
            tekanan_darah=tekanan_darah,
            suhu_badan=float(suhu_badan) if suhu_badan else None,
            berat_badan=float(berat_badan) if berat_badan else None,
            tinggi_badan=float(tinggi_badan) if tinggi_badan else None,
            catatan=catatan,
        )

        # Tandai bahwa pasien sudah diperiksa
        janji_temu.diperiksa_perawat = True
        janji_temu.save()

        messages.success(request, f"Pemeriksaan awal untuk {janji_temu.pasien.nama} berhasil disimpan.")
        return redirect('perawat:dashboard_perawat')

    return render(request, 'perawat/periksa_pasien.html', {
        'janji_temu': janji_temu,
    })