from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include

from Dj_project import settings

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include("app_main.urls")),  # main page and base template
]

if settings.DEBUG:
    urlpatterns.extend(static(settings.STATIC_URL, document_root=settings.STATIC_ROOT))
