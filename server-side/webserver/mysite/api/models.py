from django.db import models
from django.contrib.auth.hashers import make_password, check_password

# Auto-increment id primary keys are 
# automatically added unless otherwise specified.


class Player(models.Model):
    # id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=256)
    pwd_hash = models.CharField(max_length=256, editable=False)
    num_maps_created = models.IntegerField(default = 0)
    def __str__(self):
        return self.username


class Song(models.Model):
    name = models.CharField(max_length=256)
    artist = models.CharField(max_length=256,default=None, blank=True,null=True)
    bpm = models.IntegerField(default=0)
    genre = models.CharField(max_length=256)
    timeSig = models.IntegerField(default=0)
    def __str__(self):
        return self.name

class BeatMap(models.Model):
    difficulty = models.IntegerField(default=0)
    creator = models.ForeignKey(Player, on_delete=models.CASCADE)
    song = models.ForeignKey(Song, on_delete=models.CASCADE)
    def __str__(self):
        return self.id

class Play(models.Model):
    player = models.ForeignKey(Player, on_delete=models.CASCADE)
    beat_map = models.ForeignKey(BeatMap, on_delete=models.CASCADE)
    score = models.PositiveIntegerField(default=0)
    rating = models.IntegerField(default=None, blank=True, null=True)
    def __str__(self):
        return self.id