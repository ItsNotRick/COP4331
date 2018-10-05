from django.shortcuts import render
from django.http import HttpResponse
from django.http import JsonResponse
from django.contrib.auth.hashers import BCryptPasswordHasher, check_password, make_password
import json
from . import models
import os

# Create your views here.
def index(request):
    return HttpResponse("Hello, you have reached the API.")

def register(request):
    print("hello!!! {}".format( request.method))
    if request.method == "GET":
        return HttpResponse("Hello, you have reached the API registry")
    
    if request.POST['username'] is None:
        return HttpResponse("empty username")
    
    if request.POST['password'] is None:
        return HttpResponse("empty password")
     
    if models.Player.objects.filter(username= request.POST['username'] ).exists():
        return HttpResponse("duplicate user.")
    
    create_user(request.POST['username'], request.POST['password'])
    
    
    return HttpResponse("user registered!")

def create_user(u_name, pwd):
    new_user = models.Player(username=u_name, pwd_hash=make_password(pwd, hasher='pbkdf2_sha256'))
    new_user.save()

def download_song(request):
    song_file = ''
    
    if request.method == "GET":
        return HttpResponse('')
    
    if request.POST['name'] is None:
        return HttpResponse('empty name')
    
    # this should actually be able to catch any injection attacks but
    elif models.Song.objects.filter(name = request.POST['name']).exists() is not True:
        return HttpResponse('Song does not Exist')
    
    song_file = request.POST['name'].replace('.', '').replace('|', '').replace('*','').replace('?', '').replace('~','') + '.json'
    
    with open(os.path.join(os.path.dirname(__file__), "Songs/{}".format(song_file) ) ) as f:
        song_data = json.load(f)
    return JsonResponse(song_data)

