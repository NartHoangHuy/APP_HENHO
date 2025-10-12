from django.db import models
from .user import User

class Hobby(models.Model):
    name = models.CharField(max_length=50, unique=True)
    users = models.ManyToManyField(User, related_name='hobbies')