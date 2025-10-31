# 🧪 TESTING CHECKLIST - APP HENHO

## ⚙️ SETUP TRƯỚC KHI TEST

### 1. Backend Server
```bash
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver 0.0.0.0:8000
```
✅ Server chạy thành công trên port 8000

### 2. Flutter App
```bash
cd D:\flutter\App_HenHo\app_henho
flutter run
```
✅ App build và chạy trên emulator/device

---

## 📱 TEST TỪNG SCREEN

### ✅ 1. LOGIN SCREEN
**Features to test:**
- [ ] Gradient background hiển thị đẹp
- [ ] Logo và title animation
- [ ] Email field validation (email không hợp lệ)
- [ ] Password field validation (< 6 ký tự)
- [ ] Toggle password visibility
- [ ] Tap "Quên mật khẩu" → Navigate đến ForgotPassword
- [ ] Tap "Đăng ký ngay" → Navigate đến Register
- [ ] Login thành công → Navigate đến Home
- [ ] Login thất bại → Show error message
- [ ] Loading spinner khi đang login

**Overflow Check:**
- [ ] Rotate device → No overflow
- [ ] Small screen → No overflow
- [ ] Keyboard open → Content scrollable

---

### ✅ 2. REGISTER SCREEN
**Features to test:**
- [ ] Gradient background hiển thị đẹp
- [ ] Back button works
- [ ] Username validation (< 3 ký tự)
- [ ] Email validation
- [ ] Password validation (< 8 ký tự)
- [ ] Confirm password match validation
- [ ] Terms checkbox works
- [ ] Cannot submit if terms not accepted
- [ ] Register thành công → Show success snackbar → Navigate to Login
- [ ] Gradient button animation

**Overflow Check:**
- [ ] Keyboard open → Form scrollable
- [ ] All fields visible và accessible

---

### ✅ 3. FORGOT PASSWORD SCREEN
**Features to test:**
- [ ] Gradient background hiển thị đẹp
- [ ] Back button works
- [ ] Icon container với gradient
- [ ] Email validation
- [ ] Submit button → Show loading spinner
- [ ] Success snackbar → Navigate back to Login
- [ ] "Quay lại đăng nhập" button works

**Overflow Check:**
- [ ] Keyboard open → Content scrollable

---

### ✅ 4. HOME SCREEN (Navigation)
**Features to test:**
- [ ] Bottom navigation bar với rounded corners
- [ ] Gradient icons khi selected
- [ ] 5 tabs: Trang chủ, Khám phá, Lượt thích, Chat, Hồ sơ
- [ ] Smooth transition giữa các tabs
- [ ] App bar ẩn cho tab "Trang chủ"
- [ ] App bar hiển thị với gradient cho các tabs khác

**Overflow Check:**
- [ ] All tabs display correctly
- [ ] No bottom overflow

---

### ✅ 5. HOME CONTENT (Swipe Screen)
**Features to test:**
- [ ] Loading state hiển thị khi đang tải candidates
- [ ] Cards display correctly
- [ ] Swipe left (dislike) works
- [ ] Swipe right (like) works
- [ ] Swipe up (super like) works
- [ ] Modern action buttons:
  - [ ] Undo button (amber)
  - [ ] Dislike button (red)
  - [ ] Super like button (blue)
  - [ ] Like button (pink)
- [ ] Buttons có shadow và hover effect
- [ ] Match dialog xuất hiện khi match:
  - [ ] Animated heart với scale animation
  - [ ] Gradient background
  - [ ] "Tiếp tục" button
  - [ ] "Nhắn tin" button
- [ ] Empty state khi hết cards:
  - [ ] Icon container với gradient
  - [ ] "Tải lại" button với gradient
- [ ] Auto-load more cards khi còn 2 cards

**Overflow Check:**
- [ ] Cards không overflow màn hình
- [ ] Action buttons không bị cut off

---

### ✅ 6. DISCOVER SCREEN
**Features to test:**
- [ ] Header với title và description
- [ ] 7 interest cards với gradient:
  - [ ] Không ràng buộc (Pink)
  - [ ] Người yêu (Red)
  - [ ] Hẹn hò nghiêm túc (Purple)
  - [ ] Rảnh tối nay (Blue)
  - [ ] Bạn trò chuyện (Green)
  - [ ] Tìm bạn cùng sở thích (Orange)
  - [ ] Kết bạn bốn phương (Teal)
- [ ] Each card có:
  - [ ] Gradient background
  - [ ] Icon container với gradient và shadow
  - [ ] Arrow indicator
- [ ] Tap card → Show snackbar với gradient
- [ ] Scrollable list

**Overflow Check:**
- [ ] Cards không overflow
- [ ] Text không bị cut off

---

### ✅ 7. LIKE SCREEN
**Features to test:**
- [ ] Loading state với text "Đang tải..."
- [ ] Modern header với:
  - [ ] Gradient background
  - [ ] Heart icon trong gradient container
  - [ ] Count hiển thị "X người"
- [ ] Pull to refresh works
- [ ] Empty state khi chưa có likes:
  - [ ] Icon container với gradient
  - [ ] Descriptive message
- [ ] Like cards display:
  - [ ] Avatar
  - [ ] Name, age
  - [ ] Distance
  - [ ] Bio preview
- [ ] Swipe left to dismiss:
  - [ ] Gradient red background xuất hiện
  - [ ] Delete icon
  - [ ] Card bị remove
- [ ] Tap card → Show bottom sheet với details
- [ ] "Thích lại" button → Show match dialog
- [ ] Match dialog:
  - [ ] Animated heart
  - [ ] Gradient background
  - [ ] Two buttons: "Tiếp tục" và "Nhắn tin"

**Overflow Check:**
- [ ] Header không overflow
- [ ] Cards display correctly
- [ ] Bottom sheet không overflow

---

### ✅ 8. CHAT SCREEN
**Features to test:**
- [ ] Loading state với text "Đang tải cuộc trò chuyện..."
- [ ] Modern search bar:
  - [ ] Rounded corners
  - [ ] Grey background
  - [ ] Search icon
  - [ ] Placeholder text
- [ ] Pull to refresh works
- [ ] Empty state khi chưa có matches:
  - [ ] Icon container với gradient
  - [ ] Multi-line descriptive message
- [ ] Match list display:
  - [ ] Avatar
  - [ ] Name
  - [ ] Last message preview
  - [ ] Unread badge (nếu có)
  - [ ] Time/date
- [ ] Separators giữa items
- [ ] Tap match → Navigate to ChatDetailScreen
- [ ] List scrollable

**Overflow Check:**
- [ ] Search bar không overflow
- [ ] Match cards không overflow
- [ ] Text không bị cut off

---

### ✅ 9. PROFILE SCREEN
**Features to test:**
- [ ] Loading state (CircularProgressIndicator)
- [ ] Avatar hiển thị:
  - [ ] Network image nếu có
  - [ ] Gradient ring around avatar
  - [ ] Placeholder icon nếu không có avatar
- [ ] Name với gradient text (ShaderMask)
- [ ] Info chips:
  - [ ] Location với icon
  - [ ] Age với icon
- [ ] Profile completion card:
  - [ ] Gradient background
  - [ ] Icon trong gradient container
  - [ ] Percentage badge với gradient
  - [ ] Progress bar
  - [ ] Last updated time
- [ ] Info card với sections:
  - [ ] Email
  - [ ] Giới tính
  - [ ] Giới thiệu (bio)
  - [ ] Sở thích
- [ ] Each section có icon trong gradient container
- [ ] Action buttons:
  - [ ] "Chỉnh sửa hồ sơ" với gradient
  - [ ] "Đăng xuất" với border
- [ ] Tap "Chỉnh sửa hồ sơ" → Navigate to EditProfile
- [ ] Tap "Đăng xuất" → Show confirmation dialog
- [ ] Logout dialog:
  - [ ] Modern design với icon
  - [ ] Two buttons: "Hủy" và "Đăng xuất"
- [ ] Logout → Clear token → Navigate to Login

**Overflow Check:**
- [ ] Scrollable content
- [ ] All sections visible
- [ ] No text overflow

---

### ⏳ 10. EDIT PROFILE SCREEN
**Features to test:**
- [ ] Loading current profile data
- [ ] Photo grid (6 slots):
  - [ ] First slot = main avatar
  - [ ] Existing photos từ server hiển thị
  - [ ] Tap empty slot → Image picker
  - [ ] Local preview after selection
  - [ ] X button to remove
- [ ] Name field với current value
- [ ] Birthday picker:
  - [ ] Calendar dialog
  - [ ] Date format hiển thị đúng
- [ ] Gender selector:
  - [ ] 3 buttons: Nam, Nữ, Khác
  - [ ] Icons hiển thị
  - [ ] Selected state
- [ ] City dropdown:
  - [ ] 63 Vietnamese cities load từ API
  - [ ] Current city selected
  - [ ] Searchable
- [ ] Bio field:
  - [ ] Multiline
  - [ ] Character counter
  - [ ] 500 char limit
- [ ] Location section:
  - [ ] "Tự động phát hiện" button
  - [ ] Loading state khi detecting
  - [ ] City tự động chọn sau detect
- [ ] Interests section:
  - [ ] 10 hobbies load từ API
  - [ ] Emoji icons
  - [ ] Tap to toggle
  - [ ] Selected hobbies highlighted
- [ ] Save button:
  - [ ] Gradient background
  - [ ] Disabled nếu không valid
  - [ ] Loading spinner khi saving
  - [ ] Success snackbar
  - [ ] Navigate back với result = true
- [ ] Profile screen reload sau successful save

**API Integration:**
- [ ] GET /api/users/profile/ → Load current data
- [ ] GET /api/users/cities/ → Load cities
- [ ] GET /api/users/hobbies/ → Load hobbies
- [ ] PUT /api/users/profile/ → Save profile
- [ ] Multipart upload cho avatar

**Overflow Check:**
- [ ] Form scrollable
- [ ] Photo grid không overflow
- [ ] All fields accessible
- [ ] Keyboard không che fields

---

## 🔧 TECHNICAL CHECKS

### API Integration
- [ ] Backend server running on port 8000
- [ ] baseUrl = 'http://10.0.2.2:8000/api/users/' (emulator)
- [ ] Token stored in SharedPreferences
- [ ] Token included in Authorization header
- [ ] API errors handled gracefully

### Network Images
- [ ] Avatar URLs từ backend load correctly
- [ ] Placeholder hiển thị khi loading
- [ ] Error icon khi fail to load
- [ ] NetworkImage với proper error handling

### Performance
- [ ] No lag khi scroll
- [ ] Animations smooth (60fps)
- [ ] Image loading không block UI
- [ ] API calls không block UI

### Error Handling
- [ ] Network errors → Show error message
- [ ] Validation errors → Show inline errors
- [ ] 400/401/500 errors → Proper error messages
- [ ] Retry mechanisms where appropriate

---

## 🐛 COMMON ISSUES TO CHECK

### Overflow Errors
- [ ] "RenderFlex overflowed by X pixels"
- [ ] Text overflow trong cards
- [ ] Images overflow containers

### Network Issues
- [ ] Cannot connect to server
- [ ] Timeout errors
- [ ] CORS errors (nếu có)

### State Management
- [ ] Reload data after edit
- [ ] State persists after navigation
- [ ] Token expires → Logout

### UI/UX Issues
- [ ] Buttons too small to tap
- [ ] Text too small to read
- [ ] Colors không đủ contrast
- [ ] Loading states missing

---

## ✅ SUCCESS CRITERIA

### Must Have ✅
- [x] Không có overflow errors
- [x] Tất cả navigation works
- [x] Login/Register/Logout works
- [x] API integration works
- [x] Images display correctly
- [x] Animations smooth
- [x] Consistent design across screens

### Nice to Have ⭐
- [ ] Haptic feedback
- [ ] Sound effects
- [ ] Push notifications
- [ ] Deep linking
- [ ] Analytics tracking

---

## 📝 TEST NOTES

**Device/Emulator:**
- Model: _______________
- OS Version: _______________
- Screen Size: _______________

**Issues Found:**
1. 
2. 
3. 

**Performance:**
- App size: _______________
- Cold start time: _______________
- Average FPS: _______________

---

## 🚀 DEPLOYMENT READY?

- [ ] All tests passed
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] UI/UX polished
- [ ] Backend stable
- [ ] Ready for beta testing

---

**Tested by:** _______________
**Date:** October 30, 2025
**Version:** 1.0.0
