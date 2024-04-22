from django.urls import path

from app_main.views import *

urlpatterns = [
    path("", IndexView.as_view(), name="home"),

]
