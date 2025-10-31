# 🎯 API Documentation - Dating App Backend

Server đang chạy tại: `http://192.168.1.111:8000`

---

## 📋 Danh Sách API Endpoints

### 🔐 **Authentication APIs** (Đã có)

#### 1. Đăng ký
```http
POST /api/users/register/
Content-Type: application/json

Body:
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}

Response 201:
{
  "message": "Đăng ký thành công!"
}
```

#### 2. Đăng nhập
```http
POST /api/users/login/
Content-Type: application/json

Body:
{
  "email": "test@example.com",
  "password": "password123"
}

Response 200:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

#### 3. Lấy Profile
```http
GET /api/users/profile/
Authorization: Bearer <access_token>

Response 200:
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "avatar": null,
  "bio": "",
  "birthday": null,
  "gender": null,
  "location": "",
  "age": null,
  "hobbies": ""
}
```

#### 4. Cập nhật Profile
```http
PUT /api/users/profile/
Authorization: Bearer <access_token>
Content-Type: application/json

Body:
{
  "username": "New Name",
  "bio": "Hello world",
  "birthday": "2000-01-15",
  "gender": "male",
  "location": "Hà Nội",
  "age": 25,
  "hobbies": "Bơi lội, Du lịch, Nghệ thuật"
}

Response 200:
{
  "message": "Cập nhật thành công!",
  "user": { ... }
}
```

---

### 🎯 **Discover APIs** (MỚI)

#### 5. Lấy danh sách người dùng để swipe
```http
GET /api/users/discover/?page=1&gender=female&min_age=20&max_age=30
Authorization: Bearer <access_token>

Query Parameters:
- page: int (optional, default=1)
- gender: string (optional) - "male", "female"
- min_age: int (optional)
- max_age: int (optional)

Response 200:
{
  "count": 15,
  "next": "http://192.168.1.111:8000/api/users/discover/?page=2",
  "previous": null,
  "results": [
    {
      "id": 5,
      "username": "Mai Lan",
      "age": 23,
      "bio": "Thích nghệ thuật, du lịch",
      "avatar": "http://192.168.1.111:8000/media/avatars/user5.jpg",
      "avatar_url": "http://192.168.1.111:8000/media/avatars/user5.jpg",
      "location": "Hà Nội",
      "hobbies": "Nghệ thuật, Du lịch, Ẩm thực",
      "gender": "female"
    }
  ]
}
```

#### 6. Swipe (Like/Dislike)
```http
POST /api/users/discover/swipe/
Authorization: Bearer <access_token>
Content-Type: application/json

Body:
{
  "target_user_id": 5,
  "action": "like"
}
// action có thể là "like" hoặc "dislike"

Response 200 (Không match):
{
  "matched": false,
  "message": "Đã like thành công"
}

Response 200 (Match):
{
  "matched": true,
  "match_id": 12,
  "message": "Bạn và Mai Lan đã match!"
}
```

---

### ❤️ **Like APIs** (MỚI)

#### 7. Lấy danh sách người đã thích bạn
```http
GET /api/users/likes/?page=1
Authorization: Bearer <access_token>

Response 200:
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 10,
      "from_user": 8,
      "from_user_name": "Lan Anh",
      "from_user_age": 24,
      "from_user_avatar": "http://192.168.1.111:8000/media/avatars/user8.jpg",
      "from_user_bio": "Yêu thích du lịch",
      "from_user_location": "Đà Nẵng",
      "to_user": 1,
      "created_at": "2025-10-26T10:30:00Z"
    }
  ]
}
```

#### 8. Like Back (Thích lại)
```http
POST /api/users/likes/like_back/
Authorization: Bearer <access_token>
Content-Type: application/json

Body:
{
  "user_id": 8
}

Response 200:
{
  "matched": true,
  "match_id": 15,
  "message": "Bạn và Lan Anh đã match!"
}
```

#### 9. Xóa lượt thích
```http
DELETE /api/users/likes/{id}/
Authorization: Bearer <access_token>

Response 204: No Content
```

---

### 💑 **Match APIs** (MỚI)

#### 10. Lấy danh sách matches
```http
GET /api/users/matches/?page=1
Authorization: Bearer <access_token>

Response 200:
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 12,
      "other_user": 5,
      "other_user_name": "Mai Lan",
      "other_user_age": 23,
      "other_user_avatar": "http://192.168.1.111:8000/media/avatars/user5.jpg",
      "other_user_bio": "Thích nghệ thuật, du lịch",
      "created_at": "2025-10-26T09:00:00Z"
    }
  ]
}
```

#### 11. Xóa match (Unmatch)
```http
DELETE /api/users/matches/{id}/
Authorization: Bearer <access_token>

Response 204: No Content
```

---

## 🔥 Luồng hoạt động của App

### 1. **Discover Flow**
1. User mở màn hình Discover
2. App gọi `GET /api/users/discover/` để lấy danh sách user
3. User swipe right (like) hoặc left (dislike)
4. App gọi `POST /api/users/discover/swipe/` với action tương ứng
5. Nếu matched=true, hiển thị popup "It's a Match!"

### 2. **Like Flow**
1. User mở màn hình "Người thích bạn"
2. App gọi `GET /api/users/likes/` để lấy danh sách
3. User có thể:
   - Tap vào để xem profile chi tiết
   - Like back: gọi `POST /api/users/likes/like_back/`
   - Xóa: gọi `DELETE /api/users/likes/{id}/`

### 3. **Match Flow**
1. User mở màn hình "Matches"
2. App gọi `GET /api/users/matches/` để lấy danh sách
3. User tap vào để chat (Firebase Realtime Database)
4. User có thể unmatch: gọi `DELETE /api/users/matches/{id}/`

---

## 🧪 Test với Postman/cURL

### Ví dụ test Swipe API:

```bash
# 1. Login để lấy token
curl -X POST http://192.168.1.111:8000/api/users/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# 2. Swipe (Like)
curl -X POST http://192.168.1.111:8000/api/users/discover/swipe/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_access_token>" \
  -d '{"target_user_id":5,"action":"like"}'

# 3. Lấy danh sách likes
curl -X GET http://192.168.1.111:8000/api/users/likes/ \
  -H "Authorization: Bearer <your_access_token>"

# 4. Lấy danh sách matches
curl -X GET http://192.168.1.111:8000/api/users/matches/ \
  -H "Authorization: Bearer <your_access_token>"
```

---

## ✅ Tổng kết

**Đã implement:**
- ✅ Like Model với unique constraint
- ✅ Match Model với relationship
- ✅ DiscoverViewSet với filtering (gender, age)
- ✅ Swipe API (like/dislike) với auto-match
- ✅ LikeViewSet để xem người thích mình
- ✅ Like Back API
- ✅ MatchViewSet để xem danh sách matches
- ✅ Unmatch API
- ✅ Admin panel cho Like & Match

**Backend hoàn chỉnh cho:**
- Discover/Swipe functionality
- Like management
- Match management
- Chat (sử dụng Firebase Realtime Database)

**Next steps:**
1. Test tất cả APIs với Postman
2. Tạo dummy data để test
3. Integrate với Flutter app
4. Implement Firebase Realtime Chat
