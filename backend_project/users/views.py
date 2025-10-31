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

        # Handle multiple photo uploads (photo_1, photo_2, ..., photo_5)
        photo_files = []
        for i in range(1, 6):  # photo_1 to photo_5
            photo_key = f'photo_{i}'
            if photo_key in request.FILES:
                photo_files.append(request.FILES[photo_key])

        # Save photos and get paths
        saved_photo_paths = []
        if photo_files:
            import os
            from django.core.files.storage import default_storage

            for photo in photo_files:
                # Save to media/photos/
                file_path = default_storage.save(f'photos/{photo.name}', photo)
                saved_photo_paths.append(file_path)
                print(f"📸 Saved photo: {file_path}")

        # Check avatar requirement: Must have avatar (from FILES or existing)
        has_avatar = 'avatar' in request.FILES or request.user.avatar
        has_new_photos = len(saved_photo_paths) > 0

        # Count total images (avatar + photos)
        total_images = 0
        if has_avatar:
            total_images += 1
        if has_new_photos:
            total_images += len(saved_photo_paths)
        elif request.user.photos:
            total_images += len(request.user.photos)

        # Validation: Require at least 2 images (avatar + 1 photo minimum)
        if total_images < 2:
            return Response(
                {'error': 'Cần tối thiểu 2 ảnh (1 ảnh đại diện + 1 ảnh phụ)'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Convert QueryDict to regular dict to avoid immutability issues
        data = {}
        for key in request.data.keys():
            if key not in ['avatar', 'photo_1', 'photo_2', 'photo_3', 'photo_4', 'photo_5']:
                data[key] = request.data[key]

        # Add photos to data if any were uploaded
        if saved_photo_paths:
            # Replace existing photos with new ones (not merge)
            data['photos'] = saved_photo_paths
            print(f"📷 Total photos uploaded: {len(saved_photo_paths)}")

        serializer = EditProfileSerializer(
            request.user, data=data, partial=True)
        if serializer.is_valid():
            user = serializer.save()

            # Handle avatar separately after save
            if 'avatar' in request.FILES:
                user.avatar = request.FILES['avatar']
                user.save()
                print(f"📷 Avatar saved: {user.avatar.name}")

            print(f"✅ Profile updated: {user.username}")
            return Response({'message': 'Cập nhật thành công!', 'user': UserProfileSerializer(user, context={'request': request}).data})
        print(f"❌ Validation errors: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UpdateInterestsAPIView(APIView):
    """API endpoint to update user's interested_in array"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        interest = request.data.get('interest')
        if not interest:
            return Response(
                {'error': 'Interest field is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = request.user

        # Initialize interested_in if it's None
        if user.interested_in is None:
            user.interested_in = []

        # Add interest if not already present
        if interest not in user.interested_in:
            user.interested_in.append(interest)
            user.save()
            print(f"✅ Added interest '{interest}' to user {user.username}")
        else:
            print(
                f"ℹ️ Interest '{interest}' already exists for user {user.username}")

        return Response({
            'message': 'Interest added successfully',
            'interested_in': user.interested_in
        })

    def delete(self, request):
        """Remove an interest from user's list"""
        interest = request.data.get('interest')
        if not interest:
            return Response(
                {'error': 'Interest field is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = request.user

        if user.interested_in and interest in user.interested_in:
            user.interested_in.remove(interest)
            user.save()
            print(f"✅ Removed interest '{interest}' from user {user.username}")

        return Response({
            'message': 'Interest removed successfully',
            'interested_in': user.interested_in or []
        })


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

        # 🎯 MODE: "Kết bạn bốn phương" - trộn tất cả (bỏ qua filters)
        mode = self.request.query_params.get('mode')
        if mode == 'all':
            # Chỉ loại trừ người đã like và match, không lọc theo gender/age/hobby
            liked_ids = Like.objects.filter(
                from_user=user).values_list('to_user_id', flat=True)
            queryset = queryset.exclude(id__in=liked_ids)

            matched_user1_ids = Match.objects.filter(
                user1=user).values_list('user2_id', flat=True)
            matched_user2_ids = Match.objects.filter(
                user2=user).values_list('user1_id', flat=True)
            queryset = queryset.exclude(
                Q(id__in=matched_user1_ids) | Q(id__in=matched_user2_ids))

            return queryset.order_by('?')  # Random order

        # 🔍 FILTER: Theo sở thích cụ thể
        hobby = self.request.query_params.get('hobby')
        if hobby and hobby.strip():  # Check if hobby is not empty
            print(f"🔍 Filtering by hobby: '{hobby}'")
            # Chỉ lấy users có hobby trong interested_in array
            queryset = queryset.filter(interested_in__contains=[hobby])
            print(f"📊 Found {queryset.count()} users with hobby '{hobby}'")

            # ❌ Loại bỏ người đã like và match (giống mode='all')
            liked_ids = Like.objects.filter(
                from_user=user).values_list('to_user_id', flat=True)
            queryset = queryset.exclude(id__in=liked_ids)
            print(f"   After excluding liked: {queryset.count()} users")

            matched_user1_ids = Match.objects.filter(
                user1=user).values_list('user2_id', flat=True)
            matched_user2_ids = Match.objects.filter(
                user2=user).values_list('user1_id', flat=True)
            queryset = queryset.exclude(
                Q(id__in=matched_user1_ids) | Q(id__in=matched_user2_ids))
            print(f"   After excluding matched: {queryset.count()} users")

            return queryset.order_by('?')  # Random order

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
            # Tạo hoặc update Like với is_like=True
            like, created = Like.objects.update_or_create(
                from_user=request.user,
                to_user=target_user,
                defaults={'is_like': True}
            )

            # Kiểm tra xem người kia đã like mình chưa (is_like=True)
            reverse_like_exists = Like.objects.filter(
                from_user=target_user,
                to_user=request.user,
                is_like=True
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
            # Tạo hoặc update Like với is_like=False (đánh dấu đã dislike)
            Like.objects.update_or_create(
                from_user=request.user,
                to_user=target_user,
                defaults={'is_like': False}
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
        """Lấy danh sách người đã like mình (chỉ lấy is_like=True)"""
        return Like.objects.filter(
            to_user=self.request.user,
            is_like=True
        ).select_related('from_user')

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

        # Kiểm tra người kia đã like mình chưa (is_like=True)
        like_exists = Like.objects.filter(
            from_user=target_user,
            to_user=request.user,
            is_like=True
        ).exists()

        if not like_exists:
            return Response(
                {'error': 'Người này chưa like bạn'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Tạo like ngược lại với is_like=True
        Like.objects.update_or_create(
            from_user=request.user,
            to_user=target_user,
            defaults={'is_like': True}
        )

        # Tạo Match
        user1, user2 = sorted([request.user, target_user], key=lambda u: u.id)
        match, created = Match.objects.get_or_create(
            user1=user1,
            user2=user2
        )

        # 🔥 XÓA Like gốc sau khi match để không hiển thị lại trong "Lượt thích"
        Like.objects.filter(
            from_user=target_user,
            to_user=request.user,
            is_like=True
        ).delete()

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
