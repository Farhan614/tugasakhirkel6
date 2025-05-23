# core/views.py

from django.shortcuts import render

def landing_page(request):
    context = {}
    return render(request, 'core/landing_page.html', context)

def visi_misi_view(request):
    """
    Menampilkan halaman Visi dan Misi Klinik.
    """
    context = {} # Tidak perlu data tambahan untuk halaman statis ini
    return render(request, 'core/visi_misi.html', context)

def layanan_umum_view(request):
    context = {}
    return render(request, 'core/layanan_umum.html', context)

# View baru untuk Layanan Konseling
def layanan_konseling_view(request):
    context = {}
    return render(request, 'core/layanan_konseling.html', context)

# View baru untuk Layanan KIA
def layanan_kia_view(request):
    context = {}
    return render(request, 'core/layanan_kia.html', context)
