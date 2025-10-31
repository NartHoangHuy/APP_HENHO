# 🚀 QUICK START GUIDE

## Khởi Động App Nhanh - 3 Bước

---

## ✅ Bước 1: Start Backend Server

```bash
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver 192.168.1.111:8000
```

**Đợi thông báo:**
```
Starting development server at http://192.168.1.111:8000/
```

✅ Server đã sẵn sàng!

---

## ✅ Bước 2: Run Flutter App

**Mở terminal mới:**
```bash
cd D:\flutter\App_HenHo\app_henho
flutter run
```

**Chọn device:**
- `1` - Chrome
- `2` - Windows
- `3` - Android emulator
- `4` - iOS simulator

⏳ Đợi app build và chạy...

---

## ✅ Bước 3: Login & Test

### 📱 Trong App:

1. **Mở màn hình Login**

2. **Nhập thông tin test account:**
   ```
   Email: mailan@test.com
   Password: password123
   ```

3. **Click Login**

4. **Bắt đầu test các tính năng:**
   - 🔍 Discover: Swipe left/right
   - ❤️ Likes: Xem người đã like
   - 💑 Matches: Xem các cặp đôi
   - 👤 Profile: Edit thông tin

---

## 🧪 TEST ACCOUNTS

Tất cả đều dùng password: `password123`

| Email | Username | Gender | Age | Location |
|-------|----------|--------|-----|----------|
| mailan@test.com | Mai Lan | Female | 23 | Hà Nội |
| minhtuan@test.com | Minh Tuấn | Male | 27 | TP.HCM |
| lananh@test.com | Lan Anh | Female | 24 | Đà Nẵng |
| hoangnam@test.com | Hoàng Nam | Male | 28 | Hà Nội |
| thuha@test.com | Thu Hà | Female | 22 | Hải Phòng |
| quanghuy@test.com | Quang Huy | Male | 26 | Đà Nẵng |
| phuonganh@test.com | Phương Anh | Female | 25 | TP.HCM |
| ducanh@test.com | Đức Anh | Male | 29 | Hà Nội |
| ngocmai@test.com | Ngọc Mai | Female | 23 | Cần Thơ |
| baolong@test.com | Bảo Long | Male | 30 | TP.HCM |
| khanhlinh@test.com | Khánh Linh | Female | 24 | Hà Nội |
| anhtuan@test.com | Anh Tuấn | Male | 28 | Đà Nẵng |

---

## 🎯 TEST CHECKLIST

### ✅ Authentication
- [ ] Login với test account
- [ ] View profile
- [ ] Edit profile
- [ ] Logout và login lại

### ✅ Discover
- [ ] Load danh sách candidates
- [ ] Swipe right (like)
- [ ] Swipe left (pass)
- [ ] Check match notification

### ✅ Likes
- [ ] Xem danh sách người đã like
- [ ] Like back
- [ ] Verify match được tạo
- [ ] Ignore/Remove like

### ✅ Matches
- [ ] Xem danh sách matches
- [ ] View match details
- [ ] Unmatch (nếu có)

---

## 🐛 TROUBLESHOOTING

### Server không chạy?
```bash
# Check port có bị chiếm không
netstat -ano | findstr :8000

# Kill process nếu cần
taskkill /PID <PID> /F

# Restart server
python manage.py runserver 192.168.1.111:8000
```

### Flutter app không connect?
1. Check server đang chạy: http://192.168.1.111:8000
2. Check IP address trong `lib/service/*.dart`
3. Verify network connection

### Login fail?
1. Check email đúng format `@test.com`
2. Password phải là `password123`
3. Check server logs để xem error

### Không có candidates để swipe?
1. Login bằng account khác
2. Hoặc reset database:
   ```bash
   python create_test_users.py
   ```

---

## 📊 VERIFY SETUP

### Check Backend
```bash
# Test login API
curl -X POST http://192.168.1.111:8000/api/users/login/ \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"mailan@test.com\",\"password\":\"password123\"}"

# Nếu thành công, sẽ trả về:
# {"access":"eyJ...", "refresh":"eyJ..."}
```

### Check Database
```bash
cd D:\flutter\App_HenHo\backend_project
python verify_database.py
```

**Expected output:**
```
✅ ✅ ✅ DATABASE VERIFICATION PASSED! ✅ ✅ ✅
```

---

## 🎉 SUCCESS!

Khi bạn thấy:
- ✅ Server running at http://192.168.1.111:8000
- ✅ Flutter app launched successfully
- ✅ Login thành công
- ✅ Candidates hiển thị trong Discover

→ **APP ĐÃ HOẠT ĐỘNG 100%!** 🚀

---

## 📚 MORE DOCS

- **COMPLETE_SUMMARY.md** - Full documentation
- **API_INTEGRATION_CHECK.md** - API endpoints
- **DATABASE_VERIFICATION.md** - Database queries
- **API_COMPLETE.md** - API details
- **FIX_403_GUIDE.md** - Curl commands

---

## ❓ NEED HELP?

1. Check server logs trong terminal
2. Check Flutter logs trong console
3. Run `python verify_database.py`
4. Xem file **COMPLETE_SUMMARY.md** section "COMMON ISSUES"

---

**Happy Testing! 🎉**
