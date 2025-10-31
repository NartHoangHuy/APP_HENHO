import requests
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, viewsets
from rest_framework.decorators import action
from django.contrib.auth import authenticate
from django.db.models import Q
from rest_framework_simplejwt.tokens import RefreshToken
from .models import UserProfile, Like, Match
from .serializers import (
    RegisterSerializer, LoginSerializer, UserProfileSerializer,
    EditProfileSerializer, DiscoverUserSerializer, LikeSerializer, MatchSerializer
)
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser


class RegisterAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Đăng ký thành công!'}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginAPIView(APIView):
    permission_classes = [AllowAny]

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
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request):
        serializer = UserProfileSerializer(
            request.user, context={'request': request})
        return Response(serializer.data)

    def put(self, request):
        print(f"📦 Received data: {request.data}")
        print(f"📋 Content-Type: {request.content_type}")

        serializer = EditProfileSerializer(
            request.user, data=request.data, partial=True)
        if serializer.is_valid():
            user = serializer.save()
            print(f"✅ Profile updated: {user.username}")
            return Response({'message': 'Cập nhật thành công!', 'user': UserProfileSerializer(user, context={'request': request}).data})
        print(f"❌ Validation errors: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GoogleSignInAPIView(APIView):
    permission_classes = [AllowAny]

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
            'user': UserProfileSerializer(user, context={'request': request}).data
        })


# ==================== DISCOVER VIEWSET ====================
class DiscoverViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet để lấy danh sách người dùng cho tính năng discover/swipe"""
    permission_classes = [IsAuthenticated]
    serializer_class = DiscoverUserSerializer

    def get_queryset(self):
        user = self.request.user
        queryset = UserProfile.objects.exclude(id=user.id)

        # Lọc theo giới tính
        gender = self.request.query_params.get('gender')
        if gender:
            queryset = queryset.filter(gender=gender)

        # Lọc theo tuổi
        min_age = self.request.query_params.get('min_age')
        max_age = self.request.query_params.get('max_age')
        if min_age:
            queryset = queryset.filter(age__gte=min_age)
        if max_age:
            queryset = queryset.filter(age__lte=max_age)

        # Loại trừ người đã like/dislike
        liked_ids = Like.objects.filter(
            from_user=user).values_list('to_user_id', flat=True)
        queryset = queryset.exclude(id__in=liked_ids)

        # Loại trừ người đã match
        matched_user1_ids = Match.objects.filter(
            user1=user).values_list('user2_id', flat=True)
        matched_user2_ids = Match.objects.filter(
            user2=user).values_list('user1_id', flat=True)
        queryset = queryset.exclude(
            Q(id__in=matched_user1_ids) | Q(id__in=matched_user2_ids))

        return queryset.order_by('?')  # Random order

    @action(detail=False, methods=['post'])
    def swipe(self, request):
        """
        API để xử lý swipe (like/dislike)
        Body: {
            "target_user_id": 5,
            "action": "like" hoặc "dislike"
        }
        """
        target_user_id = request.data.get('target_user_id')
        action = request.data.get('action')

        if not target_user_id or not action:
            return Response(
                {'error': 'Thiếu thông tin target_user_id hoặc action'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            target_user = UserProfile.objects.get(id=target_user_id)
        except UserProfile.DoesNotExist:
            return Response(
                {'error': 'Người dùng không tồn tại'},
                status=status.HTTP_404_NOT_FOUND
            )

        if action == 'like':
            # Tạo Like
            like, created = Like.objects.get_or_create(
                from_user=request.user,
                to_user=target_user
            )

            # Kiểm tra xem người kia đã like mình chưa
            reverse_like_exists = Like.objects.filter(
                from_user=target_user,
                to_user=request.user
            ).exists()

            if reverse_like_exists:
                # Tạo Match (đảm bảo user1_id < user2_id)
                user1, user2 = sorted(
                    [request.user, target_user], key=lambda u: u.id)
                match, match_created = Match.objects.get_or_create(
                    user1=user1,
                    user2=user2
                )

                return Response({
                    'matched': True,
                    'match_id': match.id,
                    'message': f'Bạn và {target_user.username} đã match!'
                }, status=status.HTTP_200_OK)

            return Response({
                'matched': False,
                'message': 'Đã like thành công'
            }, status=status.HTTP_200_OK)

        elif action == 'dislike':
            # Tạo Like với flag dislike (hoặc có thể tạo model riêng)
            # Ở đây đơn giản chỉ tạo Like để đánh dấu đã xem
            Like.objects.get_or_create(
                from_user=request.user,
                to_user=target_user
            )
            return Response({
                'matched': False,
                'message': 'Đã dislike'
            }, status=status.HTTP_200_OK)

        return Response(
            {'error': 'Action không hợp lệ. Chỉ chấp nhận "like" hoặc "dislike"'},
            status=status.HTTP_400_BAD_REQUEST
        )


# ==================== LIKE VIEWSET ====================
class LikeViewSet(viewsets.ModelViewSet):
    """ViewSet để quản lý likes"""
    permission_classes = [IsAuthenticated]
    serializer_class = LikeSerializer

    def get_queryset(self):
        """Lấy danh sách người đã like mình"""
        return Like.objects.filter(to_user=self.request.user).select_related('from_user')

    @action(detail=False, methods=['post'])
    def like_back(self, request):
        """
        API để like lại người đã like mình
        Body: {"user_id": 10}
        """
        user_id = request.data.get('user_id')

        if not user_id:
            return Response(
                {'error': 'Thiếu thông tin user_id'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            target_user = UserProfile.objects.get(id=user_id)
        except UserProfile.DoesNotExist:
            return Response(
                {'error': 'Người dùng không tồn tại'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Kiểm tra người kia đã like mình chưa
        like_exists = Like.objects.filter(
            from_user=target_user,
            to_user=request.user
        ).exists()

        if not like_exists:
            return Response(
                {'error': 'Người này chưa like bạn'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Tạo like ngược lại
        Like.objects.get_or_create(
            from_user=request.user,
            to_user=target_user
        )

        # Tạo Match
        user1, user2 = sorted([request.user, target_user], key=lambda u: u.id)
        match, created = Match.objects.get_or_create(
            user1=user1,
            user2=user2
        )

        return Response({
            'matched': True,
            'match_id': match.id,
            'message': f'Bạn và {target_user.username} đã match!'
        }, status=status.HTTP_200_OK)

    def destroy(self, request, *args, **kwargs):
        """Xóa lượt thích"""
        instance = self.get_object()
        # Chỉ cho phép xóa nếu là người nhận like
        if instance.to_user != request.user:
            return Response(
                {'error': 'Bạn không có quyền xóa like này'},
                status=status.HTTP_403_FORBIDDEN
            )
        self.perform_destroy(instance)
        return Response(
            {'message': 'Đã xóa like thành công'},
            status=status.HTTP_204_NO_CONTENT
        )


# ==================== MATCH VIEWSET ====================
class MatchViewSet(viewsets.ModelViewSet):
    """ViewSet để quản lý matches"""
    permission_classes = [IsAuthenticated]
    serializer_class = MatchSerializer

    def get_queryset(self):
        """Lấy danh sách matches của user"""
        user = self.request.user
        return Match.objects.filter(
            Q(user1=user) | Q(user2=user)
        ).select_related('user1', 'user2')

    def destroy(self, request, *args, **kwargs):
        """Xóa match (unmatch)"""
        instance = self.get_object()
        # Kiểm tra user có quyền xóa không
        if instance.user1 != request.user and instance.user2 != request.user:
            return Response(
                {'error': 'Bạn không có quyền xóa match này'},
                status=status.HTTP_403_FORBIDDEN
            )

        # Xóa các like tương ứng
        other_user = instance.get_other_user(request.user)
        Like.objects.filter(
            Q(from_user=request.user, to_user=other_user) |
            Q(from_user=other_user, to_user=request.user)
        ).delete()

        self.perform_destroy(instance)
        return Response(
            {'message': 'Đã unmatch thành công'},
            status=status.HTTP_204_NO_CONTENT
        )


class CityListAPIView(APIView):
    """API để lấy danh sách thành phố"""
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import City
        from .serializers import CitySerializer

        cities = City.objects.filter(is_active=True)
        serializer = CitySerializer(cities, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class HobbyListAPIView(APIView):
    """API để lấy danh sách sở thích"""
    permission_classes = [AllowAny]

    def get(self, request):
        from .models import Hobby
        from .serializers import HobbySerializer

        hobbies = Hobby.objects.filter(is_active=True)
        serializer = HobbySerializer(hobbies, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
