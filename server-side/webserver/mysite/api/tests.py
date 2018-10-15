from django.test import TestCase, Client
from .models import Player, Song, BeatMap
from django.contrib.auth.hashers import check_password
from .views import create_user
import json
import os
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

class RecordBeatMapTestCase(TestCase):
    def setUp(self):
        fish = Song(name="Fish", artist=None, bpm=180, genre='Pop', timeSig=4)
        fish.save()
    
    def test_normal_working(self):
        
        c = Client()
        
        body = {"name" : "Fish"}
        response = c.post("/api/download_beatmap", json.dumps(body), content_type="application/json")
        self.assertEqual(response.status_code,200)
        
        with open(os.path.join(os.path.dirname(__file__), "Songs/{}".format("Fish.json") ) ) as f:
            song_data = json.load(f)

        compareVal = json.loads(response.content.decode('utf-8'))
        
        self.assertEqual(song_data, compareVal)
        
    def test_wrong_name(self):
        c = Client()
        
        body = {"name" : "Turtle"}
        response = c.post("/api/download_beatmap", json.dumps(body), content_type="application/json")
        self.assertEqual(response.status_code,200)
        self.assertEqual(response.content, b"Song Turtle does not Exist")
    
    def test_no_name(self):
        c = Client()
        
        body = {"" : "lol"}
        response = c.post("/api/download_beatmap", json.dumps(body), content_type="application/json")
        self.assertEqual(response.status_code,200)
        self.assertEqual(response.content, b"empty name")

class RecordBeatMapTestCase(TestCase):
    def setUp(self):
        test_user = Player(username = 'Yash', pwd_hash="sdkjfsldkjf")
        test_song = Song(name="Fish", artist=None, bpm=180, genre='Pop', timeSig=4)
        test_map = BeatMap(difficulty=1, creator=1, Song=1) 
        
        test_user.save()
        test_song.save()
        test_map.save()

    def test_normal_working(self):
        c = Client()

        body = { "username" : "Yash", "beatmap": "1", "score" : "100" }
        response = c.post('/api/record_beatmap',  json.dumps(body), content_type="application/json")
        
        self.assertEqual(response.status_code, 200)
        compareVal = json.loads(response.content.decode('utf-8'))
        self.assertEqual(compareVal, {"message": "Score Registered!"})

        
    def test_missing_fields(self):
        pass
    def test_negative_score(self):
        pass