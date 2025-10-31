# API Endpoints cần implement cho Backend Django

## 📋 Tổng quan
Đây là danh sách các API endpoints cần thiết để hỗ trợ ứng dụng dating Flutter.

---

## 🔐 Authentication APIs (Đã có)
- ✅ `POST /api/users/register/` - Đăng ký tài khoản
- ✅ `POST /api/users/login/` - Đăng nhập
- ✅ `POST /api/users/google-signin/` - Đăng nhập Google
- ✅ `GET /api/users/profile/` - Lấy thông tin profile
- ✅ `PUT /api/users/profile/` - Cập nhật profile

---

## 🎯 Discover APIs (Cần implement)

### 1. Lấy danh sách người dùng để swipe
```http
GET /api/users/discover/
Authorization: Bearer <token>

Query Parameters:
- page: int (mặc định 1)
- gender: string (optional) - "male", "female", "other"
- min_age: int (optional)
- max_age: int (optional)

Response 200:
{
  "count": 50,
  "next": "http://localhost:8000/api/users/discover/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "username": "Mai Lan",
      "age": 23,
      "bio": "Thích nghệ thuật, du lịch",
      "avatar": "http://localhost:8000/media/avatars/user1.jpg",
      "location": "Hà Nội",
      "distance_km": 5.2,
      "hobbies": "Nghệ thuật, Du lịch, Ẩm thực",
      "images": [
        "http://localhost:8000/media/profiles/user1_1.jpg",
        "http://localhost:8000/media/profiles/user1_2.jpg"
      ]
    }
  ]
}
```

**Django View Implementation:**
```python
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination
from django.contrib.gis.measure import Distance
from django.contrib.gis.geos import Point

class DiscoverViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination
    
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
        liked_ids = Like.objects.filter(from_user=user).values_list('to_user_id', flat=True)
        queryset = queryset.exclude(id__in=liked_ids)
        
        return queryset
```

---

### 2. Swipe (Like/Dislike)
```http
POST /api/users/swipe/
Authorization: Bearer <token>

Request Body:
{
  "target_user_id": 5,
  "action": "like"  // hoặc "dislike"
}

Response 200:
{
  "matched": true,  // true nếu match (2 người like nhau)
  "match_id": 12    // ID của match nếu matched = true
}
```

**Django View Implementation:**
```python
from rest_framework.decorators import action
from rest_framework.response import Response

@action(detail=False, methods=['post'])
def swipe(self, request):
    target_user_id = request.data.get('target_user_id')
    action = request.data.get('action')
    
    if action == 'like':
        # Tạo Like
        like = Like.objects.create(
            from_user=request.user,
            to_user_id=target_user_id
        )
        
        # Kiểm tra xem người kia đã like mình chưa
        reverse_like = Like.objects.filter(
            from_user_id=target_user_id,
            to_user=request.user
        ).exists()
        
        if reverse_like:
            # Tạo Match
            match = Match.objects.create()
            match.users.add(request.user, target_user_id)
            
            return Response({
                'matched': True,
                'match_id': match.id
            })
    
    return Response({'matched': False})
```

---

## ❤️ Like APIs (Cần implement)

### 3. Lấy danh sách người đã thích bạn
```http
GET /api/users/likes/
Authorization: Bearer <token>

Query Parameters:
- page: int

Response 200:
{
  "count": 10,
  "results": [
    {
      "id": 5,
      "from_user_id": 10,
      "from_user_name": "Lan Anh",
      "from_user_age": 24,
      "from_user_avatar": "http://localhost:8000/media/avatars/user10.jpg",
      "from_user_bio": "Yêu thích du lịch",
      "distance_km": 2.5,
      "created_at": "2025-01-20T10:30:00Z"
    }
  ]
}
```

---

### 4. Thích lại (Like back)
```http
POST /api/users/like-back/
Authorization: Bearer <token>

Request Body:
{
  "user_id": 10
}

Response 200:
{
  "matched": true,
  "match_id": 15
}
```

---

### 5. Xóa lượt thích
```http
DELETE /api/users/likes/{id}/
Authorization: Bearer <token>

Response 204: No Content
```

---

## 💑 Match APIs (Cần implement)

### 6. Lấy danh sách matches
```http
GET /api/users/matches/
Authorization: Bearer <token>

Response 200:
{
  "count": 8,
  "results": [
    {
      "id": 12,
      "user_id": 15,
      "user_name": "Minh Tuấn",
      "user_age": 27,
      "user_avatar": "http://localhost:8000/media/avatars/user15.jpg",
      "last_message": "Xin chào!",
      "last_message_time": "2025-01-20T14:30:00Z",
      "matched_at": "2025-01-20T10:00:00Z",
      "has_unread_messages": true
    }
  ]
}
```

**Django Model:**
```python
class Match(models.Model):
    users = models.ManyToManyField(settings.AUTH_USER_MODEL)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
```

---

### 7. Xóa match (Unmatch)
```http
DELETE /api/users/matches/{id}/
Authorization: Bearer <token>

Response 204: No Content
```

---

## 📊 Models cần thêm vào Django

### Like Model
```python
# users/models.py

class Like(models.Model):
    from_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='likes_given'
    )
    to_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='likes_received'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('from_user', 'to_user')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['to_user', 'created_at']),
        ]
```

### Match Model
```python
class Match(models.Model):
    user1 = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='matches_as_user1'
    )
    user2 = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='matches_as_user2'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user1', 'created_at']),
            models.Index(fields=['user2', 'created_at']),
        ]
    
    def get_other_user(self, current_user):
        return self.user2 if self.user1 == current_user else self.user1
```

---

## 🚀 Các bước thực hiện

1. **Tạo models mới:**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

2. **Tạo serializers:**
   - LikeSerializer
   - MatchSerializer
   - DiscoverSerializer

3. **Tạo ViewSets:**
   - DiscoverViewSet
   - LikeViewSet
   - MatchViewSet

4. **Cập nhật URLs:**
   ```python
   # users/urls.py
   from rest_framework.routers import DefaultRouter
   
   router = DefaultRouter()
   router.register(r'discover', DiscoverViewSet, basename='discover')
   router.register(r'likes', LikeViewSet, basename='likes')
   router.register(r'matches', MatchViewSet, basename='matches')
   
   urlpatterns = [
       # ... existing urls
   ] + router.urls
   ```

5. **Test APIs bằng Postman**

---

## 🔥 Firebase Realtime Database Structure

```json
{
  "chats": {
    "chat_5_10": {
      "info": {
        "last_message": "Xin chào!",
        "last_message_time": "2025-01-20T14:30:00Z",
        "last_sender_id": 5
      },
      "messages": {
        "-N1234567": {
          "sender_id": 5,
          "receiver_id": 10,
          "text": "Xin chào!",
          "timestamp": "2025-01-20T14:30:00Z",
          "is_read": true,
          "image_url": null
        }
      }
    }
  }
}
```

**Lưu ý:** 
- Room ID được tạo theo format: `chat_{userId_nhỏ_hơn}_{userId_lớn_hơn}`
- Flutter app sẽ tự động xử lý realtime chat qua Firebase
- Backend Django không cần xử lý chat (dùng Firebase thay thế)

---

## ✅ Checklist Implementation

- [ ] Tạo Like model
- [ ] Tạo Match model
- [ ] Implement DiscoverViewSet
- [ ] Implement swipe API
- [ ] Implement LikeViewSet
- [ ] Implement like-back API
- [ ] Implement MatchViewSet
- [ ] Test tất cả APIs
- [ ] Cấu hình Firebase Realtime Database
- [ ] Test end-to-end flow
