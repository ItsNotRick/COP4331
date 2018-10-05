from django.contrib import admin

from .models import Player
from .models import Song
# Register your models here.

admin.site.register(Player)
admin.site.register(Song)
