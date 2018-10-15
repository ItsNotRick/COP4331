from . import views
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('', views.index, name='index'),
    path('register', views.register, name='register'),
    path('download_song', views.download_song, name='download_song'),
    path('download_beatmap', views.download_beatmap, name='download_beatmap')
]
