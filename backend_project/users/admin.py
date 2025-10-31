from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import UserProfile, Like, Match, City, Hobby


@admin.register(UserProfile)
class UserProfileAdmin(UserAdmin):
    list_display = ('username', 'email', 'age',
                    'gender', 'location', 'date_joined')
    list_filter = ('gender', 'date_joined')
    search_fields = ('username', 'email', 'location')

    fieldsets = UserAdmin.fieldsets + (
        ('Thông tin hồ sơ', {
            'fields': ('avatar', 'bio', 'birthday', 'gender', 'location', 'latitude', 'longitude', 'age', 'hobbies', 'is_profile_complete')
        }),
    )


@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = ('name', 'display_order', 'is_active', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('name',)
    ordering = ('display_order', 'name')
    list_editable = ('display_order', 'is_active')


@admin.register(Hobby)
class HobbyAdmin(admin.ModelAdmin):
    list_display = ('name', 'icon', 'display_order', 'is_active', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('name',)
    ordering = ('display_order', 'name')
    list_editable = ('icon', 'display_order', 'is_active')


@admin.register(Like)
class LikeAdmin(admin.ModelAdmin):
    list_display = ('from_user', 'to_user', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('from_user__username', 'to_user__username')
    date_hierarchy = 'created_at'

    def has_add_permission(self, request):
        return False  # Không cho phép thêm like từ admin


@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ('user1', 'user2', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('user1__username', 'user2__username')
    date_hierarchy = 'created_at'

    def has_add_permission(self, request):
        return False  # Không cho phép thêm match từ admin
