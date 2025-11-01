# 🔥 FIX: User ID Confusion - Tin nhắn bị nhầm giữa các accounts

## ❌ VẤN ĐỀ PHÁT HIỆN

### Screenshots từ user:
```
Terminal 1 (User A): From 24 to 27  ✅
Terminal 2 (User B): From 23 to 33  ❌ SAI!
```

**Mô tả:**
- User A (ID: 24) match với User B (ID: 27)
- User A chat với 27: **ĐÚNG**
- User B chat nhưng logs show "From 23 to 33": **SAI!**
- Lẽ ra User B phải "From 27 to 24"

## 🔍 NGUYÊN NHÂN GỐC RỄ

### 1. **Login không lưu user_id**

**Code cũ (login_screen.dart):**
```dart
if (token != null) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('token', token);  // ❌ CHỈ LƯU TOKEN!
  // ❌ KHÔNG LƯU user_id!
  
  Navigator.pushReplacement(...);
}
```

**Hậu quả:**
- App chỉ lưu token, không lưu user_id
- Mỗi lần mở chat phải fetch Profile API để lấy user_id
- **VẤN ĐỀ**: SharedPreferences vẫn giữ user_id CŨ từ account trước!

### 2. **Logout không xóa user_id**

**Code cũ (profile_screen.dart):**
```dart
void _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.remove('token');  // ❌ CHỈ XÓA TOKEN!
  // ❌ KHÔNG XÓA user_id!
  
  Navigator.pushAndRemoveUntil(...);
}
```

**Hậu quả:**
- Logout chỉ xóa token
- **user_id của account cũ VẪN CÒN trong SharedPreferences!**

### 3. **Kịch bản gây lỗi**

```
Step 1: User A (ID: 24) login trên thiết bị
  → Login thành công
  → Lưu token nhưng KHÔNG lưu user_id

Step 2: User A mở chat với User B (ID: 27)
  → Fetch Profile API → Lấy được user_id = 24
  → SharedPreferences.setInt('user_id', 24)  ✅
  → Chat hoạt động đúng: "From 24 to 27"

Step 3: User A logout
  → Xóa token
  → ❌ KHÔNG XÓA user_id!
  → SharedPreferences vẫn còn: user_id = 24

Step 4: User B (ID: 27) login trên CÙNG thiết bị
  → Login thành công với token mới
  → ❌ KHÔNG fetch profile ngay!
  → ❌ KHÔNG lưu user_id của User B!

Step 5: User B mở chat với User A
  → SharedPreferences.getInt('user_id') = 24  ❌ ĐÂY LÀ ID CỦA USER A!
  → App nghĩ User B có ID = 24
  → Chat hiển thị sai: "From 24 to 27" (thay vì "From 27 to 24")
  → Messages bị lẫn lộn!
```

### 4. **Tại sao logs show "From 23 to 33"?**

Có thể trước đó có User C (ID: 23) và User D (ID: 33) đã login trên thiết bị:
```
1. User C (23) login → chat → user_id = 23 lưu vào SharedPreferences
2. User C logout → ❌ KHÔNG XÓA user_id = 23
3. User D (33) login (hoặc nhiều users khác)
4. Khi User B (27) login và mở chat:
   → Đọc nhầm user_id = 23 (của User C cũ)
   → Chat với user_id = 33 (có thể là Match.userId bị cache)
   → Logs show: "From 23 to 33" ❌
```

## ✅ GIẢI PHÁP ĐÃ IMPLEMENT

### Fix 1: Login phải fetch và lưu user_id NGAY

**File: `lib/screen/login_screen.dart`**

```dart
if (token != null) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('token', token);

  // 🔥 FIX: Clear old user_id from previous account!
  print('🔥 [LOGIN] Clearing old user_id from SharedPreferences...');
  await prefs.remove('user_id');
  
  // 🔥 FIX: Fetch current user's profile immediately
  print('🔥 [LOGIN] Fetching profile to get user_id...');
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.61:8000/api/users/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userId = data['id'];
      await prefs.setInt('user_id', userId);  // ✅ LƯU user_id NGAY!
      print('✅ [LOGIN] Saved user_id: $userId');
      print('✅ [LOGIN] Profile: ${data['name']} (${data['email']})');
    } else {
      print('⚠️ [LOGIN] Failed to fetch profile: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ [LOGIN] Error fetching profile: $e');
  }

  Navigator.pushReplacement(...);
}
```

**Imports cần thêm:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

### Fix 2: Logout phải xóa user_id

**File: `lib/screen/user/profile_screen.dart`**

```dart
void _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.remove('token');
  
  // 🔥 FIX: Clear user_id to prevent confusion!
  print('🔥 [LOGOUT] Clearing user_id from SharedPreferences...');
  await prefs.remove('user_id');  // ✅ XÓA user_id!
  print('✅ [LOGOUT] Cleared all user data');
  
  Navigator.pushAndRemoveUntil(...);
}
```

**File: `lib/screen/user/modern_profile_screen.dart`**

```dart
if (confirmed == true && mounted) {
  final prefs = await SharedPreferences.getInstance();
  
  // 🔥 FIX: Clear all data including user_id!
  print('🔥 [LOGOUT] Clearing all SharedPreferences data...');
  await prefs.clear();  // ✅ XÓA TẤT CẢ!
  print('✅ [LOGOUT] Cleared all user data including user_id');
  
  Navigator.pushAndRemoveUntil(...);
}
```

## 📊 SO SÁNH TRƯỚC VÀ SAU FIX

### ❌ TRƯỚC KHI FIX

| Event | Token | user_id trong SharedPreferences | Kết quả |
|-------|-------|--------------------------------|---------|
| User A (24) login | ✅ Lưu | ❌ Không lưu | - |
| User A mở chat | - | 24 (từ Profile API) | ✅ Đúng |
| User A logout | ❌ Xóa | ❌ KHÔNG XÓA → VẪN 24! | - |
| User B (27) login | ✅ Lưu | ❌ VẪN LÀ 24 (cũ) | ❌ SAI! |
| User B mở chat | - | 24 (SAI!) | ❌ Dùng nhầm ID của User A! |

### ✅ SAU KHI FIX

| Event | Token | user_id trong SharedPreferences | Kết quả |
|-------|-------|--------------------------------|---------|
| User A (24) login | ✅ Lưu | ✅ 24 (fetch ngay từ API) | ✅ Đúng |
| User A mở chat | - | 24 | ✅ Đúng |
| User A logout | ❌ Xóa | ✅ XÓA user_id | ✅ Clean! |
| User B (27) login | ✅ Lưu | ✅ 27 (fetch ngay từ API) | ✅ Đúng |
| User B mở chat | - | 27 | ✅ Đúng! |

## 🧪 TEST CASE ĐỂ VERIFY FIX

### Test 1: Fresh Login
```
1. Uninstall app (hoặc Clear app data)
2. Login User A (ID: 24)
3. Xem logs:
   ✅ [LOGIN] Clearing old user_id...
   ✅ [LOGIN] Fetching profile...
   ✅ [LOGIN] Saved user_id: 24
4. Mở chat với User B (ID: 27)
5. Logs phải show: "From 24 to 27" ✅
```

### Test 2: Switch Account (QUAN TRỌNG NHẤT!)
```
1. Login User A (ID: 24)
2. Mở chat → verify "From 24 to 27"
3. Logout
   → Logs: [LOGOUT] Clearing user_id...
4. Login User B (ID: 27) trên CÙNG thiết bị
   → Logs: 
     [LOGIN] Clearing old user_id...
     [LOGIN] Saved user_id: 27
5. Mở chat với User A
6. Logs phải show: "From 27 to 24" ✅ (KHÔNG PHẢI "From 24 to 27"!)
```

### Test 3: Multiple Accounts Sequential
```
1. Login User C (23) → chat → logout
2. Login User D (33) → chat → logout
3. Login User A (24) → chat → logout
4. Login User B (27) → mở chat
5. Logs phải show: "From 27 to 24" ✅
   KHÔNG PHẢI "From 23 to 33" hay "From 24 to 27"!
```

## 📝 CHECKLIST VERIFY

- [ ] **Login flow:**
  - [ ] Login User A
  - [ ] Check logs có "Clearing old user_id"
  - [ ] Check logs có "Saved user_id: [correct ID]"
  - [ ] Mở chat → Verify logs show correct sender/receiver IDs

- [ ] **Logout flow:**
  - [ ] Logout
  - [ ] Check logs có "Clearing user_id"
  - [ ] Verify user_id đã bị xóa khỏi SharedPreferences

- [ ] **Switch account flow:**
  - [ ] Login User A → Chat → Logout
  - [ ] Login User B trên cùng device
  - [ ] Mở chat → Verify User B dùng đúng ID của mình, KHÔNG PHẢI ID của User A

- [ ] **Message sending/receiving:**
  - [ ] User A gửi tin → User B nhận được
  - [ ] User B reply → User A nhận được
  - [ ] Không có messages bị lẫn với conversations khác

## 🎯 KẾT LUẬN

**Root Cause:**
- SharedPreferences cache user_id cũ từ account trước
- Login/Logout không clear cache đúng cách
- App dùng nhầm user_id của account khác

**Fix Applied:**
1. ✅ Login: Clear old user_id + Fetch và lưu user_id mới NGAY
2. ✅ Logout: Clear user_id để không để lại cache
3. ✅ Logging: Thêm logs để dễ debug

**Expected Result:**
- Mỗi account có user_id riêng, không bị nhầm
- Switch account hoạt động đúng
- Chat messages không bị lẫn lộn

## 🚀 NEXT STEPS

1. **Hot Restart cả 2 apps** (press `R` in terminal)
2. **Logout tất cả accounts** để clear cache cũ
3. **Login lại từng account** và verify logs
4. **Test chat giữa 2 accounts** và paste logs mới!

**Expected logs sau khi fix:**
```
User A terminal:
[LOGIN] Clearing old user_id...
[LOGIN] Saved user_id: 24
[CHAT_DETAIL] THIS USER ID: 24 (ME)
[CHAT_DETAIL] OTHER USER ID: 27 (User B)
[CHAT_SERVICE] From 24 to 27  ✅

User B terminal:
[LOGIN] Clearing old user_id...
[LOGIN] Saved user_id: 27
[CHAT_DETAIL] THIS USER ID: 27 (ME)
[CHAT_DETAIL] OTHER USER ID: 24 (User A)
[CHAT_SERVICE] From 27 to 24  ✅
```

**PHẢI MATCH NHAU!** Nếu logs vẫn khác → còn vấn đề khác cần trace!
