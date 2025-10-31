from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator


class UserProfile(AbstractUser):
    # Basic Info
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    bio = models.TextField(max_length=500, blank=True, null=True,
                           help_text='Giới thiệu bản thân (tối đa 500 ký tự)')
    birthday = models.DateField(blank=True, null=True, help_text='Ngày sinh')

    # Gender với validation
    gender = models.CharField(
        max_length=10,
        choices=[('male', 'Nam'), ('female', 'Nữ'), ('other', 'Khác')],
        blank=True,
        null=True,
        help_text='Giới tính'
    )

    # Location Info
    location = models.CharField(
        max_length=200, blank=True, null=True, help_text='Địa chỉ/Thành phố')
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        help_text='Vĩ độ',
        validators=[MinValueValidator(-90), MaxValueValidator(90)]
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        help_text='Kinh độ',
        validators=[MinValueValidator(-180), MaxValueValidator(180)]
    )

    # Additional Info
    age = models.IntegerField(
        blank=True,
        null=True,
        help_text='Tuổi',
        validators=[MinValueValidator(18), MaxValueValidator(100)]
    )
    hobbies = models.TextField(
        blank=True, null=True, help_text='Sở thích (phân cách bằng dấu phẩy)')

    # Profile completion
    is_profile_complete = models.BooleanField(
        default=False, help_text='Profile đã hoàn thành chưa')

    # Timestamps
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'User Profile'
        verbose_name_plural = 'User Profiles'
        ordering = ['-date_joined']

    def __str__(self):
        return f"{self.username} ({self.email})"

    def save(self, *args, **kwargs):
        # Auto calculate profile completion
        required_fields = [self.avatar, self.bio,
                           self.birthday, self.gender, self.location]
        self.is_profile_complete = all(required_fields)
        super().save(*args, **kwargs)

    @property
    def display_location(self):
        """Format location cho display"""
        if self.location:
            return self.location
        if self.latitude and self.longitude:
            return f"{self.latitude}, {self.longitude}"
        return "Chưa cập nhật"


class Like(models.Model):
    """Model để lưu lượt thích giữa các người dùng"""
    from_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='likes_given',
        verbose_name='Người thích'
    )
    to_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='likes_received',
        verbose_name='Người được thích'
    )
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name='Thời gian')

    class Meta:
        unique_together = ('from_user', 'to_user')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['to_user', 'created_at']),
            models.Index(fields=['from_user', 'created_at']),
        ]
        verbose_name = 'Lượt thích'
        verbose_name_plural = 'Lượt thích'

    def __str__(self):
        return f"{self.from_user.username} thích {self.to_user.username}"


class Match(models.Model):
    """Model để lưu match giữa 2 người dùng (cả 2 đều like nhau)"""
    user1 = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='matches_as_user1',
        verbose_name='Người dùng 1'
    )
    user2 = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='matches_as_user2',
        verbose_name='Người dùng 2'
    )
    created_at = models.DateTimeField(
        auto_now_add=True, verbose_name='Thời gian match')

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user1', 'created_at']),
            models.Index(fields=['user2', 'created_at']),
        ]
        verbose_name = 'Match'
        verbose_name_plural = 'Matches'

    def __str__(self):
        return f"Match giữa {self.user1.username} và {self.user2.username}"

    def get_other_user(self, current_user):
        """Lấy user còn lại trong match"""
        return self.user2 if self.user1 == current_user else self.user1

    @classmethod
    def get_match_between(cls, user1, user2):
        """Kiểm tra xem 2 user đã match chưa"""
        return cls.objects.filter(
            models.Q(user1=user1, user2=user2) |
            models.Q(user1=user2, user2=user1)
        ).first()


class City(models.Model):
    """Model cho danh sách thành phố Việt Nam"""
    name = models.CharField(max_length=100, unique=True,
                            verbose_name='Tên thành phố')
    display_order = models.IntegerField(
        default=0, verbose_name='Thứ tự hiển thị')
    is_active = models.BooleanField(
        default=True, verbose_name='Đang hoạt động')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cities'
        ordering = ['display_order', 'name']
        verbose_name = 'Thành phố'
        verbose_name_plural = 'Thành phố'

    def __str__(self):
        return self.name


class Hobby(models.Model):
    """Model cho danh sách sở thích"""
    name = models.CharField(max_length=50, unique=True,
                            verbose_name='Tên sở thích')
    icon = models.CharField(max_length=50, blank=True,
                            null=True, verbose_name='Icon/Emoji')
    display_order = models.IntegerField(
        default=0, verbose_name='Thứ tự hiển thị')
    is_active = models.BooleanField(
        default=True, verbose_name='Đang hoạt động')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'hobbies'
        ordering = ['display_order', 'name']
        verbose_name = 'Sở thích'
        verbose_name_plural = 'Sở thích'

    def __str__(self):
        return f"{self.icon} {self.name}" if self.icon else self.name
