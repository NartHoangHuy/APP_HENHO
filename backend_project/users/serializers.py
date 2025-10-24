from rest_framework import serializers
from .models import UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = (
            'id', 'username', 'email', 'avatar', 'bio', 'birthday', 'gender',
            'location', 'age', 'hobbies'
        )


class EditProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = (
            'avatar', 'bio', 'birthday', 'gender', 'username', 'email',
            'location', 'age', 'hobbies'
        )
        extra_kwargs = {
            'username': {'required': False},
            'email': {'required': False},
        }


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = UserProfile
        # Chỉ bắt buộc các trường này khi đăng ký
        fields = ('username', 'email', 'password')

    def create(self, validated_data):
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
