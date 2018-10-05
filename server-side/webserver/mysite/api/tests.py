from django.test import TestCase
from .models import Player
from django.contrib.auth.hashers import check_password
from .views import create_user
# Create your tests here.

class PlayerTestCase(TestCase):
    def setUp(self):
        create_user("user1", "ThisShouldBeHashed")
        create_user("user2", "yoyoyo")
    def test_users_created(self):
        self.assertEqual(check_password("ThisShouldBeHashed", Player.objects.filter(username='user1')[0].pwd_hash ), True )