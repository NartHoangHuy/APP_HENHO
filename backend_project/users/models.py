from django.contrib.auth.models import AbstractUser
from django.db import models


class UserProfile(AbstractUser):
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    bio = models.TextField(blank=True, null=True)
    birthday = models.DateField(blank=True, null=True)
    gender = models.CharField(
        max_length=10,
        choices=[('male', 'Nam'), ('female', 'Nữ')],
        blank=True,
        null=True
    )
    location = models.CharField(max_length=100, blank=True, null=True)
    age = models.IntegerField(blank=True, null=True)
    # Lưu dạng chuỗi, ví dụ: "Bơi lội, Đọc sách"
    hobbies = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.username
