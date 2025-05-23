from django.contrib import admin
from django.urls import path, include
from dokter.views import CustomLoginView
from django.contrib.auth.views import LogoutView
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('', include('core.urls')),# <-- URL untuk Landing Page
    path('admin/', admin.site.urls),
    path('dokter/', include('dokter.urls')),  # Hapus namespace='dokter'
    path('pasien/', include('pasien.urls')),  # Hapus namespace='pasien'
    path('apoteker/', include('apoteker.urls')),
    path('dokter/login/', CustomLoginView.as_view(), name='login'),
    path('dokter/logout/', LogoutView.as_view(), name='logout'),
    path('perawat/', include('perawat.urls')),  # Tambahkan
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)