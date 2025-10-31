# ✅ API Integration Status - Dating App

## 📊 Tổng Quan
Tất cả frontend services đã được cấu hình để sử dụng API thay vì dữ liệu ảo.

---

## 🔧 Frontend Services - Đã Cấu Hình API

### 1. ✅ AuthService (`lib/service/auth_service.dart`)
**Base URL:** `http://192.168.1.111:8000/api/users/`

| Method | Endpoint | Status | Description |
|--------|----------|--------|-------------|
| POST | `/register/` | ✅ | Đăng ký tài khoản mới |
| POST | `/login/` | ✅ | Đăng nhập, trả về JWT token |
| POST | `/google-signin/` | ✅ | Đăng nhập Google |
| GET | `/profile/` | ✅ | Lấy thông tin profile (cần token) |
| PUT | `/profile/` | ✅ | Cập nhật profile (cần token) |

**Debug Logs:** Service đã có debug prints để trace token flow

---

### 2. ✅ DiscoverService (`lib/service/discover_service.dart`)
**Base URL:** `http://192.168.1.111:8000/api/users/`

| Method | Endpoint | Status | Description |
|--------|----------|--------|-------------|
| GET | `/discover/` | ✅ | Lấy danh sách users để swipe |
| POST | `/discover/swipe/` | ✅ FIXED | Swipe like/dislike (đã sửa từ `/swipe/`) |

**Query Parameters:**
- `page`: Pagination
- `gender`: Lọc theo giới tính
- `min_age`, `max_age`: Lọc theo độ tuổi

**Response:**
```json
{
  "results": [
    {
      "id": 1,
      "username": "Mai Lan",
      "age": 23,
      "gender": "female",
      "location": "Hà Nội",
      "bio": "...",
      "hobbies": "...",
      "avatar_url": "http://..."
    }
  ],
  "count": 20,
  "next": "...",
  "previous": null
}
```

---

### 3. ✅ LikeService (`lib/service/like_service.dart`)
**Base URL:** `http://192.168.1.111:8000/api/users/`

| Method | Endpoint | Status | Description |
|--------|----------|--------|-------------|
| GET | `/likes/` | ✅ | Danh sách người đã like bạn |
| POST | `/likes/like_back/` | ✅ FIXED | Like lại người đã like bạn (đã sửa từ `/like-back/`) |
| DELETE | `/likes/{id}/` | ✅ | Xóa/bỏ qua một like |

---

### 4. ✅ MatchService (`lib/service/match_service.dart`)
**Base URL:** `http://192.168.1.111:8000/api/users/`

| Method | Endpoint | Status | Description |
|--------|----------|--------|-------------|
| GET | `/matches/` | ✅ | Danh sách matches |
| GET | `/matches/{id}/` | ✅ | Chi tiết một match |
| DELETE | `/matches/{id}/` | ✅ | Unmatch |

---

## 🗄️ Backend Database Schema

### Bảng: `users_userprofile`
```sql
CREATE TABLE users_userprofile (
    id INT PRIMARY KEY AUTO_INCREMENT,
    password VARCHAR(128) NOT NULL,
    last_login DATETIME(6),
    is_superuser TINYINT(1) NOT NULL,
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    first_name VARCHAR(150),
    last_name VARCHAR(150),
    is_staff TINYINT(1) NOT NULL,
    is_active TINYINT(1) NOT NULL,
    date_joined DATETIME(6) NOT NULL,
    avatar VARCHAR(100),
    bio TEXT,
    birthday DATE,
    gender VARCHAR(10),
    location VARCHAR(100),
    age INT,
    hobbies TEXT
);
```

### Bảng: `users_like`
```sql
CREATE TABLE users_like (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at DATETIME(6) NOT NULL,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    UNIQUE KEY users_like_from_user_id_to_user_id (from_user_id, to_user_id),
    KEY users_like_from_user_id (from_user_id),
    KEY users_like_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users_userprofile(id),
    FOREIGN KEY (to_user_id) REFERENCES users_userprofile(id)
);
```

### Bảng: `users_match`
```sql
CREATE TABLE users_match (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at DATETIME(6) NOT NULL,
    user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    UNIQUE KEY users_match_user1_id_user2_id (user1_id, user2_id),
    FOREIGN KEY (user1_id) REFERENCES users_userprofile(id),
    FOREIGN KEY (user2_id) REFERENCES users_userprofile(id)
);
```

---

## 📦 Test Data đã Tạo

### ✅ 12 Test Users
- Email pattern: `{name}@test.com`
- Password: `password123`
- Đầy đủ thông tin: tên, tuổi, giới tính, địa điểm, bio, sở thích

### ✅ 34 Likes
- Mỗi user like 2-4 người khác ngẫu nhiên

### ✅ 5 Matches
- Tự động tạo từ các cặp like có đi có lại

---

## 🔍 Các Thay Đổi Đã Thực Hiện

### 1. ✅ Xóa Assets Dummy
- Đã xóa tất cả file trong `assets/images/`
- Đã comment `assets` section trong `pubspec.yaml`

### 2. ✅ Sửa Endpoints Frontend
**DiscoverService:**
```dart
// Before: Uri.parse('${baseUrl}swipe/')
// After:  Uri.parse('${baseUrl}discover/swipe/')
```

**LikeService:**
```dart
// Before: Uri.parse('${baseUrl}like-back/')
// After:  Uri.parse('${baseUrl}likes/like_back/')
```

### 3. ✅ Backend ViewSets URLs
```python
# Router URLs:
/api/users/discover/          - GET: List users
/api/users/discover/swipe/    - POST: Swipe action
/api/users/likes/             - GET: List likes
/api/users/likes/like_back/   - POST: Like back
/api/users/matches/           - GET: List matches
```

---

## 🚀 Cách Test

### 1. Khởi động Server
```bash
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver 192.168.1.111:8000
```

### 2. Chạy Flutter App
```bash
cd D:\flutter\App_HenHo\app_henho
flutter run
```

### 3. Login với Test Account
- Email: `mailan@test.com`
- Password: `password123`

### 4. Test Flow
1. ✅ Login → Nhận JWT token
2. ✅ Discover → Load users từ API
3. ✅ Swipe → Like/Pass qua API
4. ✅ Matches → Tự động tạo khi có reverse like
5. ✅ Likes → Xem người đã like
6. ✅ Profile → View/Edit qua API

---

## 🐛 Debug Tips

### Check Token Flow
```dart
// AuthService đã có debug logs:
print('🔐 Logging in with email: $email');
print('📡 Login response status: ${response.statusCode}');
print('✅ Token received: $token');
```

### Common Issues

1. **404 Not Found**
   - Check endpoint URL (phải dùng ViewSet action URLs)
   - Verify router registration trong `urls.py`

2. **401 Unauthorized**
   - Token không được gửi hoặc hết hạn
   - Check Authorization header: `Bearer {token}`
   - Token lifetime: 5 hours (access), 7 days (refresh)

3. **415 Unsupported Media Type**
   - Thiếu `Content-Type: application/json` header
   - Body không phải JSON format

---

## 📝 Database Migrations Status

```bash
✅ users/migrations/0001_initial.py
✅ users/migrations/0002_alter_userprofile_avatar.py
✅ users/migrations/0003_alter_userprofile_age_alter_userprofile_gender_and_more.py
✅ users/migrations/0004_alter_userprofile_birthday.py
✅ users/migrations/0005_like_match.py
```

Tất cả migrations đã apply thành công vào MySQL database.

---

## ✅ Checklist Hoàn Thành

- [x] Backend models (UserProfile, Like, Match) đã tạo
- [x] Backend serializers đã implement
- [x] Backend views/viewsets đã implement
- [x] Backend URLs đã config đúng
- [x] Frontend services đã sử dụng API
- [x] Frontend endpoints đã sửa đúng format
- [x] Dummy assets đã xóa
- [x] Test data đã tạo (12 users, 34 likes, 5 matches)
- [x] Server đang chạy tại http://192.168.1.111:8000
- [x] Database migrations đã apply

---

## 🎯 Next Steps (Optional)

1. **Upload Avatar Feature**
   - Frontend: ImagePicker đã có
   - Backend: ProfileAPIView hỗ trợ MultiPartParser
   - Cần test upload ảnh qua API

2. **Match Screen**
   - Service đã có (`match_service.dart`)
   - Cần tạo UI screen để hiển thị matches

3. **Chat Integration**
   - Đang dùng Firebase Realtime Database
   - Cần link với Match data từ Django

4. **Pagination**
   - Backend đã config PAGE_SIZE = 20
   - Frontend cần handle load more

---

## 📞 Server Info

**Backend Server:** http://192.168.1.111:8000
**Admin Panel:** http://192.168.1.111:8000/admin/
**API Root:** http://192.168.1.111:8000/api/users/

**Admin Credentials:** (Tạo bằng `python manage.py createsuperuser`)

---

🎉 **API Integration Complete!** App đã sẵn sàng cho testing với real API data.
