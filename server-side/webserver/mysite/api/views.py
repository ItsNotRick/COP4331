from django.shortcuts import render
from django.http import HttpResponse
from django.http import JsonResponse
from django.contrib.auth.hashers import BCryptPasswordHasher, check_password, make_password
import json
from .models import Player, Song, BeatMap, Play
import os

# Create your views here.
def index(request):
    return HttpResponse("Hello, you have reached the API.")

def register(request):
    
    if request.method == "GET":
        return HttpResponse("Hello, you have reached the API registry")
    
    data = json.loads(request.body)

    if data['username'] == '':
        return HttpResponse("empty username")
    
    if data['password'] == '':
        return HttpResponse("empty password")
     
    if Player.objects.filter(username= data['username'] ).exists():
        return HttpResponse("duplicate user.")
    
    create_user(data['username'], data['password'])
    
    
    return HttpResponse("user registered!")

def create_user(u_name, pwd):
    new_user = Player(username=u_name, pwd_hash=make_password(pwd, hasher='pbkdf2_sha256'))
    new_user.save()

def download_song(request):
    song_file = ''

    if request.method == "GET":
        return HttpResponse('')
    
    data = json.loads(request.body)

    if data['name'] == '':
        return HttpResponse('empty name')
    
    # this should actually be able to catch any injection attacks but
    elif Song.objects.filter(name = data['name']).exists() is not True:
        return HttpResponse('Song does not Exist')
    
    song_file = data['name'].replace('.', '').replace('|', '').replace('*','').replace('?', '').replace('~','') + '.mp3'
    with open(os.path.join(os.path.dirname(__file__), "Songs/{}".format(song_file) ), "rb" ) as f:
        song_data = f.read()
    response = HttpResponse(song_data, content_type='application/mp3')
    response['Content-Disposition'] = 'attachment; filename="song.mp3"'
    return response

    
    

# download_beatmap(request):
# with open(os.path.join(os.path.dirname(__file__), "Songs/{}".format(song_file) ) ) as f:
#         song_data = json.load(f)
#     return JsonResponse(song_data)


# def record_play(request):
#     if request.method == "GET":
#         return HttpResponse('')

#     data = json.loads(request.body)
    
#     if data['username'] == '' or Player.objects.filter(username= data['username'] ).exists() is not True:
#         return HttpResponse("invalid username")
#     # should we check a password for validation?
#     elif data['beatmap'] == '' or BeatMap.objects.filter(id= data['beatmap'] ).exists() is not True:
#         return HttpResponse('invalid beat_map')
#     elif data['score'] == '':
#         return HttpResponse('empty score')
    
#     if data['rating'] == '':
#         rating = None
#     create_play(data['username'],  data['beatmap'], data['score'],data['rating'] )

# def create_play(username, beatmap, score, rating):
#     new_play = Play(player = username, beat_map = beatmap, score = score, rating = rating)

    
    

