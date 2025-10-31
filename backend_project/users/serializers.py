from rest_framework import serializers
from .models import UserProfile, Like, Match, City, Hobby
from django.contrib.auth.password_validation import validate_password
from django.core import exceptions


class CitySerializer(serializers.ModelSerializer):
    """Serializer cho danh sách thành phố"""
    class Meta:
        model = City
        fields = ('id', 'name', 'display_order')


class HobbySerializer(serializers.ModelSerializer):
    """Serializer cho danh sách sở thích"""
    class Meta:
        model = Hobby
        fields = ('id', 'name', 'icon', 'display_order')


class UserProfileSerializer(serializers.ModelSerializer):
    avatar_url = serializers.SerializerMethodField()
    photos_urls = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = (
            'id', 'username', 'email', 'avatar', 'avatar_url', 'photos', 'photos_urls', 'bio',
            'birthday', 'gender', 'location', 'latitude', 'longitude',
            'age', 'hobbies', 'interested_in', 'is_profile_complete', 'date_joined', 'updated_at'
        )
        read_only_fields = ('id', 'date_joined',
                            'updated_at', 'is_profile_complete')

    def get_avatar_url(self, obj):
        request = self.context.get('request')
        if obj.avatar and hasattr(obj.avatar, 'url'):
            if request:
                return request.build_absolute_uri(obj.avatar.url)
            return obj.avatar.url
        return None

    def get_photos_urls(self, obj):
        """Convert relative photo paths to absolute URLs"""
        request = self.context.get('request')
        print(
            f"🔍 UserProfileSerializer.get_photos_urls for user {obj.username}")
        print(f"   obj.photos type: {type(obj.photos)}, value: {obj.photos}")

        if obj.photos and isinstance(obj.photos, list):
            print(f"   ✅ Photos found: {len(obj.photos)} photos")
            if request:
                urls = [request.build_absolute_uri(
                    f'/media/{photo}') for photo in obj.photos]
                print(f"   Generated URLs: {urls}")
                return urls
            return [f'/media/{photo}' for photo in obj.photos]
        print(f"   ⚠️ No photos found or not a list")
        return []


class DiscoverUserSerializer(serializers.ModelSerializer):
    """Serializer cho danh sách discover - hiển thị thông tin cơ bản"""
    avatar_url = serializers.SerializerMethodField()
    photos_urls = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = (
            'id', 'username', 'age', 'bio', 'avatar', 'avatar_url', 'photos', 'photos_urls',
            'location', 'hobbies', 'gender', 'interested_in'
        )

    def get_avatar_url(self, obj):
        request = self.context.get('request')
        if obj.avatar and hasattr(obj.avatar, 'url'):
            if request:
                return request.build_absolute_uri(obj.avatar.url)
            return obj.avatar.url
        return None

    def get_photos_urls(self, obj):
        """Convert relative photo paths to absolute URLs"""
        request = self.context.get('request')
        if obj.photos and isinstance(obj.photos, list):
            if request:
                return [request.build_absolute_uri(f'/media/{photo}') for photo in obj.photos]
            return [f'/media/{photo}' for photo in obj.photos]
        return []


class LikeSerializer(serializers.ModelSerializer):
    """Serializer cho Like - bao gồm đầy đủ thông tin user để hiển thị detail"""
    from_user_name = serializers.CharField(
        source='from_user.username', read_only=True)
    from_user_age = serializers.IntegerField(
        source='from_user.age', read_only=True)
    from_user_gender = serializers.CharField(
        source='from_user.gender', read_only=True)
    from_user_avatar = serializers.SerializerMethodField()
    from_user_bio = serializers.CharField(
        source='from_user.bio', read_only=True)
    from_user_location = serializers.CharField(
        source='from_user.location', read_only=True)
    from_user_hobbies = serializers.CharField(
        source='from_user.hobbies', read_only=True)
    from_user_interested_in = serializers.ListField(
        source='from_user.interested_in', read_only=True)
    from_user_photos = serializers.SerializerMethodField()

    class Meta:
        model = Like
        fields = (
            'id', 'from_user', 'from_user_name', 'from_user_age', 'from_user_gender',
            'from_user_avatar', 'from_user_bio', 'from_user_location',
            'from_user_hobbies', 'from_user_interested_in', 'from_user_photos',
            'to_user', 'is_like', 'created_at'
        )
        read_only_fields = ('from_user', 'created_at')

    def get_from_user_avatar(self, obj):
        request = self.context.get('request')
        if obj.from_user.avatar and hasattr(obj.from_user.avatar, 'url'):
            if request:
                return request.build_absolute_uri(obj.from_user.avatar.url)
            return obj.from_user.avatar.url
        return None

    def get_from_user_photos(self, obj):
        """Trả về list URLs của photos"""
        request = self.context.get('request')
        photos = obj.from_user.photos or []

        if not photos:
            return []

        photo_urls = []
        for photo_path in photos:
            if photo_path:
                # Build full URL
                if request:
                    full_url = request.build_absolute_uri(
                        f'/media/{photo_path}')
                else:
                    full_url = f'/media/{photo_path}'
                photo_urls.append(full_url)

        return photo_urls


class MatchSerializer(serializers.ModelSerializer):
    """Serializer cho Match"""
    other_user = serializers.SerializerMethodField()
    other_user_name = serializers.SerializerMethodField()
    other_user_age = serializers.SerializerMethodField()
    other_user_avatar = serializers.SerializerMethodField()
    other_user_bio = serializers.SerializerMethodField()

    class Meta:
        model = Match
        fields = (
            'id', 'other_user', 'other_user_name', 'other_user_age',
            'other_user_avatar', 'other_user_bio', 'created_at'
        )
        read_only_fields = ('created_at',)

    def get_other_user(self, obj):
        request = self.context.get('request')
        current_user = request.user if request else None
        if current_user:
            other = obj.get_other_user(current_user)
            return other.id
        return None

    def get_other_user_name(self, obj):
        request = self.context.get('request')
        current_user = request.user if request else None
        if current_user:
            other = obj.get_other_user(current_user)
            return other.username
        return None

    def get_other_user_age(self, obj):
        request = self.context.get('request')
        current_user = request.user if request else None
        if current_user:
            other = obj.get_other_user(current_user)
            return other.age
        return None

    def get_other_user_avatar(self, obj):
        request = self.context.get('request')
        current_user = request.user if request else None
        if current_user and request:
            other = obj.get_other_user(current_user)
            if other.avatar and hasattr(other.avatar, 'url'):
                return request.build_absolute_uri(other.avatar.url)
        return None

    def get_other_user_bio(self, obj):
        request = self.context.get('request')
        current_user = request.user if request else None
        if current_user:
            other = obj.get_other_user(current_user)
            return other.bio
        return None


class EditProfileSerializer(serializers.ModelSerializer):
    # Override để accept cả string và number cho latitude/longitude
    latitude = serializers.FloatField(
        required=False, min_value=-90, max_value=90, allow_null=True)
    longitude = serializers.FloatField(
        required=False, min_value=-180, max_value=180, allow_null=True)

    class Meta:
        model = UserProfile
        fields = (
            'username', 'avatar', 'photos', 'bio', 'birthday', 'gender',
            'location', 'latitude', 'longitude', 'age', 'hobbies', 'interested_in'
        )
        extra_kwargs = {
            'username': {'required': False},
            'avatar': {'required': False},
            'photos': {'required': False},
            'bio': {'required': False, 'max_length': 500, 'allow_blank': True},
            'birthday': {'required': False},
            'gender': {'required': False, 'allow_blank': True},
            'location': {'required': False, 'max_length': 200, 'allow_blank': True},
            'age': {'required': False, 'min_value': 18, 'max_value': 100},
            'hobbies': {'required': False, 'allow_blank': True},
            'interested_in': {'required': False},
        }

    def validate_gender(self, value):
        """Validate gender field"""
        if value and value not in ['male', 'female', 'other']:
            raise serializers.ValidationError(
                "Gender must be 'male', 'female', or 'other'"
            )
        return value

    def validate_bio(self, value):
        """Validate bio length"""
        if value and len(value) > 500:
            raise serializers.ValidationError(
                "Bio không được vượt quá 500 ký tự"
            )
        return value

    def validate_age(self, value):
        """Validate age"""
        if value and (value < 18 or value > 100):
            raise serializers.ValidationError(
                "Tuổi phải từ 18 đến 100"
            )
        return value

    def validate_photos(self, value):
        """Validate photos list"""
        if value and len(value) > 5:
            raise serializers.ValidationError(
                "Tối đa 5 ảnh phụ"
            )
        return value

    def validate(self, attrs):
        """Cross-field validation"""
        # Nếu có latitude thì phải có longitude và ngược lại
        latitude = attrs.get('latitude')
        longitude = attrs.get('longitude')

        if (latitude is not None and longitude is None) or \
           (longitude is not None and latitude is None):
            raise serializers.ValidationError({
                'location': 'Phải có cả latitude và longitude'
            })

        return attrs


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'},
        help_text='Password phải có ít nhất 8 ký tự'
    )
    password_confirm = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}
    )

    class Meta:
        model = UserProfile
        fields = ('username', 'email', 'password', 'password_confirm')
        extra_kwargs = {
            'username': {'required': True, 'min_length': 3, 'max_length': 150},
            'email': {'required': True},
        }

    def validate_email(self, value):
        """Check email uniqueness"""
        if UserProfile.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email này đã được sử dụng")
        return value.lower()

    def validate_username(self, value):
        """Check username uniqueness and format"""
        if UserProfile.objects.filter(username=value).exists():
            raise serializers.ValidationError("Username này đã được sử dụng")
        if len(value) < 3:
            raise serializers.ValidationError(
                "Username phải có ít nhất 3 ký tự")
        return value

    def validate_password(self, value):
        """Validate password strength"""
        try:
            validate_password(value)
        except exceptions.ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value

    def validate(self, attrs):
        """Check password confirmation"""
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({
                'password_confirm': 'Mật khẩu xác nhận không khớp'
            })
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = UserProfile(
            username=validated_data['username'],
            email=validated_data['email'],
        )
        user.set_password(validated_data['password'])
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()
