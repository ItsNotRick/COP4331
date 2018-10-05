from django.test import TestCase, Client
from .models import Player
from django.contrib.auth.hashers import check_password
from .views import create_user
import json
# Create your tests here.

class PlayerTestCase(TestCase):
    def test_user_created(self):
        c = Client()
        body = {"username": "user1", "password": "ThisShouldBeHashed"}

        response = c.post("/api/register", json.dumps(body), content_type="application/json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(check_password("ThisShouldBeHashed", Player.objects.filter(username="user1")[0].pwd_hash), True )
    
    def test_no_username(self):
        c = Client()
        body = {"username": "","password": "ThisShouldntBeEntered"}
        response = c.post("/api/register", json.dumps(body), content_type="application/json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b"empty username")
        # I don"t know if this is a valid assertion
        # self.assertEqual(Player.objects.filter(username = "").count(), 0))
    
    def test_no_password(self):
        c = Client()
        body =  {"username": "blankPassword", "password": ""}
        response = c.post("/api/register", json.dumps(body), content_type="application/json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b"empty password")
        self.assertEqual(Player.objects.filter(username = "blankPassword").count(), 0)
    
    def test_duplicates(self):
        c = Client()
        body1 = {"username": "dupe","password": "first"}
        body2 = {"username": "dupe", "password":"second"}
        response1 = c.post("/api/register", json.dumps(body1), content_type="application/json")
        response2 = c.post("/api/register", json.dumps(body1), content_type="application/json")
        self.assertEqual(response1.status_code, 200)
        self.assertEqual(response2.status_code, 200)

        self.assertEqual(response1.content, b"user registered!")
        self.assertEqual(response2.content, b"duplicate user.")
        
        self.assertEqual(Player.objects.filter(username = "dupe").count(), 1)