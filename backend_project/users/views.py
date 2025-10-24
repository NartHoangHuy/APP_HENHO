import requests
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .models import UserProfile
from .serializers import RegisterSerializer, LoginSerializer, UserProfileSerializer, EditProfileSerializer

from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser


class RegisterAPIView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Đăng ký thành công!'}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginAPIView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']
            try:
                user = UserProfile.objects.get(email=email)
                user = authenticate(
                    request, username=user.username, password=password)
            except UserProfile.DoesNotExist:
                user = None
            if user:
                refresh = RefreshToken.for_user(user)
                return Response({
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                })
            return Response({'error': 'Email hoặc mật khẩu không đúng'}, status=status.HTTP_401_UNAUTHORIZED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        serializer = EditProfileSerializer(
            request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Cập nhật thành công!', 'user': serializer.data})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GoogleSignInAPIView(APIView):
    def post(self, request):
        id_token = request.data.get('id_token')
        if not id_token:
            return Response({'error': 'Missing id_token'}, status=status.HTTP_400_BAD_REQUEST)
        # Xác thực id_token với Google
        google_url = f'https://oauth2.googleapis.com/tokeninfo?id_token={id_token}'
        resp = requests.get(google_url)
        if resp.status_code != 200:
            return Response({'error': 'Invalid token'}, status=status.HTTP_401_UNAUTHORIZED)
        data = resp.json()
        email = data.get('email')
        name = data.get('name', '')
        avatar_url = data.get('picture', '')

        user, created = UserProfile.objects.get_or_create(
            email=email,
            defaults={'username': name}
        )
        if avatar_url and not user.avatar:
            user.avatar = avatar_url
            user.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserProfileSerializer(user).data
        })
