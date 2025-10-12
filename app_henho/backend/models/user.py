from django.db import models

class User(models.Model):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    name = models.CharField(max_length=50)
    age = models.IntegerField(null=True, blank=True)
    location = models.CharField(max_length=100, null=True, blank=True)
    bio = models.TextField(null=True, blank=True)
    avatar = models.CharField(max_length=200, null=True, blank=True)
    # hobbies: ManyToMany in Hobby model