# 🚀 QUICK START GUIDE - Testing App HenHo

## Bước 1️⃣: Start Backend Server

Mở terminal và chạy:
```powershell
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver 0.0.0.0:8000
```

✅ Đợi cho đến khi thấy:
```
Starting development server at http://0.0.0.0:8000/
```

---

## Bước 2️⃣: Start Flutter App

Mở terminal mới và chạy:
```powershell
cd D:\flutter\App_HenHo\app_henho
flutter run
```

✅ Chọn device (Android emulator hoặc real device)
✅ Đợi app build và launch

---

## Bước 3️⃣: Quick Flow Test

### A. Register → Login → Profile
1. **Register Account**
   - Tap "Đăng ký ngay"
   - Fill: username, email, password, confirm password
   - Check "Tôi đồng ý..."
   - Tap "Đăng ký"
   - ✅ Should see success snackbar và navigate to Login

2. **Login**
   - Enter email và password
   - Tap "Đăng nhập"
   - ✅ Should navigate to Home (Swipe screen)

3. **Complete Profile**
   - Tap tab "Hồ sơ" (bottom right)
   - Tap "Chỉnh sửa hồ sơ"
   - Add photos (tap + icon)
   - Fill bio, birthday, gender, city, hobbies
   - Tap "Lưu"
   - ✅ Should see success và return to Profile
   - ✅ Profile completion % should increase

### B. Test Main Features
1. **Swipe Screen (Tab 1)**
   - ✅ See candidate cards
   - ✅ Tap action buttons (undo, dislike, superlike, like)
   - ✅ Swipe cards manually

2. **Discover Screen (Tab 2)**
   - ✅ See 7 interest cards với gradient
   - ✅ Tap any card → snackbar appears

3. **Like Screen (Tab 3)**
   - ✅ See header với count
   - ✅ Pull to refresh works
   - ✅ Swipe left to dismiss card

4. **Chat Screen (Tab 4)**
   - ✅ See search bar
   - ✅ See empty state hoặc match list

5. **Profile Screen (Tab 5)**
   - ✅ See avatar, name, completion card
   - ✅ Tap "Chỉnh sửa hồ sơ"
   - ✅ Tap "Đăng xuất" → confirm dialog

---

## 🐛 Common Issues & Fixes

### Issue 1: Cannot connect to server
**Error:** `SocketException: Failed to connect`

**Fix:**
```dart
// Check baseUrl in auth_service.dart:
final baseUrl = 'http://10.0.2.2:8000/api/users/'; // For Android Emulator
// OR
final baseUrl = 'http://localhost:8000/api/users/'; // For iOS Simulator
// OR
final baseUrl = 'http://YOUR_IP:8000/api/users/'; // For Real Device
```

### Issue 2: Images not loading
**Error:** Avatar không hiển thị

**Check:**
1. Backend MEDIA_URL và MEDIA_ROOT configured?
2. Django urls.py includes static files serving?
3. Avatar URL có protocol (http://) không?

**Fix in backend settings.py:**
```python
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# In urls.py
from django.conf import settings
from django.conf.urls.static import static

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

### Issue 3: Overflow errors
**Error:** `RenderFlex overflowed by X pixels`

**Already Fixed!** All screens now have:
- SafeArea wrapping
- SingleChildScrollView
- Proper Flexible/Expanded usage
- Text maxLines với ellipsis

### Issue 4: Gradle build fails
**Error:** Gradle dependency issues

**Fix:**
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 5: White screen after login
**Possible causes:**
1. Token không được save
2. Navigation route không đúng
3. HomeScreen crash

**Debug:**
- Check console logs
- Check SharedPreferences có token?
- Check backend returns valid token?

---

## 📊 Expected Behavior

### ✅ Login Screen
- Gradient pink/purple background
- White card container
- Smooth animations on load
- Validation errors show inline

### ✅ Register Screen
- Gradient background với back button header
- White card container
- Gradient button khi valid
- Grey button khi invalid

### ✅ Home Navigation
- Modern bottom nav với rounded top
- Gradient icons khi selected
- Smooth tab transitions

### ✅ Swipe Screen
- Cards smooth khi swipe
- Action buttons với proper colors:
  - Amber (undo)
  - Red (dislike)
  - Blue (superlike)
  - Pink (like)
- Match dialog animated

### ✅ Discover Screen
- 7 gradient cards
- Each với gradient icon container
- Snackbar với gradient background

### ✅ Like Screen
- Header với gradient và count
- Cards swipeable left to dismiss
- Match dialog khi "Thích lại"

### ✅ Chat Screen
- Modern search bar grey background
- Separators giữa items
- Empty state centered

### ✅ Profile Screen
- Avatar với gradient ring
- Progress card với percentage
- Info sections với icons
- Gradient action buttons

---

## 🎯 Quick Checks

**Visual Checks:**
- [ ] No white/black jarring backgrounds
- [ ] Consistent pink/purple gradient theme
- [ ] All icons có proper colors
- [ ] Shadows visible và subtle
- [ ] Rounded corners consistent

**Functional Checks:**
- [ ] All buttons tappable
- [ ] All navigation works
- [ ] All forms validate
- [ ] All API calls work
- [ ] All images load

**Performance Checks:**
- [ ] No lag khi scroll
- [ ] Smooth animations (60fps)
- [ ] Quick load times
- [ ] No memory leaks

---

## 📱 Device-Specific Testing

### Android Emulator
```
baseUrl = 'http://10.0.2.2:8000/api/users/'
```

### iOS Simulator
```
baseUrl = 'http://localhost:8000/api/users/'
```

### Real Device (Same WiFi)
1. Get computer IP: `ipconfig` (Windows) hoặc `ifconfig` (Mac/Linux)
2. Use: `http://YOUR_IP:8000/api/users/`
3. Backend must run on: `python manage.py runserver 0.0.0.0:8000`

---

## 🔍 Debug Commands

### Check logs:
```powershell
# Flutter logs
flutter logs

# Filter for errors
flutter logs | Select-String "ERROR"
flutter logs | Select-String "Exception"
```

### Check network:
```powershell
# Test backend API
curl http://10.0.2.2:8000/api/users/cities/

# Or in browser
http://localhost:8000/api/users/cities/
```

### Reset app data:
```powershell
# Uninstall and reinstall
flutter clean
flutter run
```

---

## ✅ Success Indicators

**You're good to go if you see:**
1. ✅ Login screen loads với gradient
2. ✅ Can register new account
3. ✅ Can login successfully
4. ✅ Home screen shows với bottom nav
5. ✅ All 5 tabs accessible
6. ✅ Profile shows user data
7. ✅ EditProfile loads và saves
8. ✅ No overflow errors in console
9. ✅ Smooth animations
10. ✅ Modern UI throughout

---

## 🎉 Ready to Test!

**Current Status:**
- ✅ 7/8 screens modernized
- ✅ No overflow errors
- ✅ API integration ready
- ✅ Consistent design system
- ⏳ EditProfile needs testing (đã có full logic)

**Start testing ngay:**
```powershell
# Terminal 1: Backend
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver 0.0.0.0:8000

# Terminal 2: Flutter
cd D:\flutter\App_HenHo\app_henho
flutter run
```

**Good luck! 🚀**
