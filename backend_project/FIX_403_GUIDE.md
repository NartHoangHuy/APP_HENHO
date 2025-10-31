# 🧪 Test Backend APIs - Dating App

## Thay đổi đã sửa để fix lỗi 403:

### 1. Cấu hình REST_FRAMEWORK trong settings.py
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # ✅ Đổi từ IsAuthenticatedOrReadOnly
    ],
    ...
}
```

### 2. Thêm `permission_classes = [AllowAny]` cho các APIView công khai:
- ✅ RegisterAPIView
- ✅ LoginAPIView  
- ✅ GoogleSignInAPIView

---

## 📝 Các lệnh test API:

### 1️⃣ Test Register (Không cần token)
```bash
curl -X POST http://192.168.1.111:8000/api/users/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser123","email":"test123@example.com","password":"password123"}'
```

**Expected Response 201:**
```json
{
  "message": "Đăng ký thành công!"
}
```

---

### 2️⃣ Test Login (Không cần token)
```bash
curl -X POST http://192.168.1.111:8000/api/users/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test123@example.com","password":"password123"}'
```

**Expected Response 200:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

💾 **Lưu access token để dùng cho các request sau!**

---

### 3️⃣ Test Get Profile (CẦN token)
```bash
curl -X GET http://192.168.1.111:8000/api/users/profile/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

**Expected Response 200:**
```json
{
  "id": 1,
  "username": "testuser123",
  "email": "test123@example.com",
  "avatar": null,
  "bio": "",
  "birthday": null,
  "gender": null,
  "location": "",
  "age": null,
  "hobbies": ""
}
```

---

### 4️⃣ Test Update Profile (CẦN token)
```bash
curl -X PUT http://192.168.1.111:8000/api/users/profile/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "Test User Updated",
    "bio": "Hello from API test",
    "birthday": "2000-01-15",
    "gender": "male",
    "location": "Hà Nội",
    "age": 25,
    "hobbies": "Bơi lội, Du lịch"
  }'
```

---

### 5️⃣ Test Discover API (CẦN token)
```bash
curl -X GET "http://192.168.1.111:8000/api/users/discover/?gender=female&min_age=20&max_age=30" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

---

### 6️⃣ Test Swipe API (CẦN token)
```bash
curl -X POST http://192.168.1.111:8000/api/users/discover/swipe/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "target_user_id": 2,
    "action": "like"
  }'
```

---

### 7️⃣ Test Get Likes (CẦN token)
```bash
curl -X GET http://192.168.1.111:8000/api/users/likes/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

---

### 8️⃣ Test Like Back (CẦN token)
```bash
curl -X POST http://192.168.1.111:8000/api/users/likes/like_back/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 2
  }'
```

---

### 9️⃣ Test Get Matches (CẦN token)
```bash
curl -X GET http://192.168.1.111:8000/api/users/matches/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

---

## 🐛 Nếu vẫn gặp lỗi 403:

### Check 1: CORS Headers
Thêm vào settings.py:
```python
INSTALLED_APPS = [
    ...
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Thêm dòng này ở đầu
    'django.middleware.security.SecurityMiddleware',
    ...
]

CORS_ALLOW_ALL_ORIGINS = True  # Cho development
```

### Check 2: CSRF Exemption
Nếu cần, thêm vào settings.py:
```python
CSRF_TRUSTED_ORIGINS = ['http://192.168.1.111:8000']
```

### Check 3: Xem logs
```bash
# Trong terminal chạy server, xem output để biết lỗi cụ thể
```

---

## ✅ Checklist Test

- [ ] Register user mới → Status 201
- [ ] Login với user vừa tạo → Nhận được access token
- [ ] Get profile với token → Status 200
- [ ] Update profile với token → Status 200
- [ ] Discover users → Status 200, có danh sách users
- [ ] Swipe like → Status 200
- [ ] Get likes → Status 200
- [ ] Get matches → Status 200

---

## 🎯 Next Steps sau khi fix 403:

1. ✅ Test tất cả APIs với Postman hoặc curl
2. ✅ Tạo dummy data: `python manage.py shell < create_dummy_data.py`
3. ✅ Integrate với Flutter app
4. ✅ Test end-to-end flow từ app

Server đang chạy tại: **http://192.168.1.111:8000** ✨
