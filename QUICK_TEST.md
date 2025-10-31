# 🚀 Quick Test Guide

## Start Backend Server

```powershell
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver
```

## Test APIs

### 1. Test Cities API
```powershell
curl http://localhost:8000/api/users/cities/ | ConvertFrom-Json | Select-Object -First 5
```

**Expected Output:**
```
id name              display_order
-- ----              -------------
1  Hà Nội            1
2  TP. Hồ Chí Minh   2
3  Đà Nẵng           3
4  Hải Phòng         4
5  Cần Thơ           5
```

### 2. Test Hobbies API
```powershell
curl http://localhost:8000/api/users/hobbies/ | ConvertFrom-Json
```

**Expected Output:**
```
id name        icon display_order
-- ----        ---- -------------
1  Nghệ thuật  🎨   1
2  Bơi lội     🏊   2
3  Xem phim    🎬   3
...
```

## Run Flutter App

```powershell
cd D:\flutter\App_HenHo\app_henho
flutter run
```

## Test Flow

1. **Open EditProfileScreen**
2. **Check City dropdown** - Should show 63 cities from API
3. **Check Hobbies section** - Should show 10 hobbies with emojis
4. **Click "📍 Tự động phát hiện vị trí"** - Should auto-detect your location
5. **Select some hobbies** - Should show count "X đã chọn"
6. **Save profile** - Should save successfully

## Common Issues

### Server won't start
```powershell
# Check if port 8000 is in use
netstat -ano | findstr :8000

# Kill process if needed
taskkill /PID <PID> /F
```

### Empty data
```powershell
cd D:\flutter\App_HenHo\backend_project
python populate_master_data.py
```

### Can't connect from emulator
- Use `http://10.0.2.2:8000` instead of `http://localhost:8000`
- Already configured in `master_data_service.dart`

## Debug Tips

### Check backend logs
Watch the terminal running `manage.py runserver` for:
```
[29/Oct/2025 18:08:45] "GET /api/users/cities/ HTTP/1.1" 200 xxxx
[29/Oct/2025 18:08:46] "GET /api/users/hobbies/ HTTP/1.1" 200 xxxx
```

### Check Flutter logs
```dart
print('🏙️  Fetching cities from API...');
print('📡 Cities response status: 200');
print('✅ Loaded 63 cities');
```

---

**Ready to test? Let's go! 🎯**
