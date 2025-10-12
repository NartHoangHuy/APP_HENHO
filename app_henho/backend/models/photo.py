from django.db import models
from .user import User

class Photo(models.Model):
    url = models.CharField(max_length=200)
    user = models.ForeignKey(User, related_name='photos', on_delete=models.CASCADE)