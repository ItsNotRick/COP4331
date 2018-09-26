from django.shortcuts import render
from django.http import HttpResponse
from django.http import JsonResponse
from . import models

# Create your views here.
def index(request):
    return HttpResponse("Hello, you have reached the API.")

# @csrf_exempt
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
    
    new_user = models.Player(username=request.POST['username'], pwd_hash=request.POST['password'])
    new_user.save()
    

    return HttpResponse("user registered!")
    
    