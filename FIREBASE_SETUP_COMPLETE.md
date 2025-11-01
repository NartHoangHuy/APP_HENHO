# 🔥 HƯỚNG DẪN SETUP FIREBASE REALTIME DATABASE - ĐẦY ĐỦ

## ⚠️ FIX VẤN ĐỀ USER_ID TRƯỚC

### Vấn đề phát hiện:
```
❌ [CHAT_DETAIL] User ID is null!
```

### ✅ ĐÃ SỬA:

1. **Backend** (`users/views.py`):
   - Login API giờ trả về `user_id`, `username`, `role`
   
2. **Frontend** (`auth_service.dart`):
   - `login()` giờ trả về `Map<String, dynamic>` thay vì chỉ `String`
   
3. **Frontend** (`login_screen.dart`):
   - Lưu `user_id` vào SharedPreferences khi login

### 🧪 TEST FIX:

1. **Restart backend**:
   ```bash
   cd backend_project
   python manage.py runserver 192.168.1.61:8000
   ```

2. **Hot restart Flutter app** (phím R + R):
   ```bash
   # Trong terminal Flutter, nhấn:
   R R  (capital R hai lần)
   ```

3. **Logout và Login lại**:
   - Logout trong app
   - Login lại với email/password
   - Check logs:
   ```
   ✅ Login data saved to SharedPreferences
   👤 User ID: 123
   👤 Username: john_doe
   ```

4. **Vào Chat Detail**:
   - Check logs:
   ```
   🔥 [CHAT_DETAIL] Current user ID: 123  ← Phải có số, không phải null!
   🔥 [CHAT_DETAIL] Match user ID: 456
   ```

---

## 🔥 SETUP FIREBASE REALTIME DATABASE

### BƯỚC 1: TẠO FIREBASE PROJECT (nếu chưa có)

1. **Truy cập**: https://console.firebase.google.com/

2. **Đăng nhập** với Google account

3. **Tìm project** `app-henho-119c8` (đã có sẵn theo firebase_options.dart)

---

### BƯỚC 2: TẠO REALTIME DATABASE

1. **Sidebar** → **Build** → **Realtime Database**

2. **Click "Create Database"**

3. **Chọn location**:
   - Recommended: **United States (us-central1)**
   - Hoặc gần bạn nhất

4. **Security rules**:
   - Chọn **"Start in test mode"** (cho development)
   - Click **"Enable"**

5. **Database created!** ✅
   - URL: `https://app-henho-119c8-default-rtdb.firebaseio.com`

---

### BƯỚC 3: CẤU HÌNH SECURITY RULES

⚠️ **QUAN TRỌNG**: Phải setup rules để app có thể read/write!

1. **Tab "Rules"** trong Realtime Database

2. **Paste code này**:

```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        ".indexOn": ["timestamp", "receiver_id", "sender_id"],
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"]
        }
      }
    }
  }
}
```

3. **Click "Publish"** ✅

**Giải thích rules:**
- `.read: true` - Cho phép tất cả đọc (test mode)
- `.write: true` - Cho phép tất cả ghi (test mode)
- `.indexOn` - Tối ưu query performance

⚠️ **Production**: Cần thay bằng rules an toàn hơn (xem phần cuối)

---

### BƯỚC 4: VERIFY FIREBASE CONFIG

1. **Check `firebase_options.dart`**:
   ```dart
   databaseURL: 'https://app-henho-119c8-default-rtdb.firebaseio.com'
   ```
   ✅ Đã có sẵn!

2. **Check `main.dart`**:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
   ✅ Đã có sẵn!

3. **Check `pubspec.yaml`**:
   ```yaml
   firebase_core: ^3.15.2
   firebase_database: ^11.3.10
   ```
   ✅ Đã có sẵn!

---

## 🧪 TEST FIREBASE CONNECTION

### Test 1: App Start

1. **Hot restart** app (R R)

2. **Check logs**:
   ```
   [firebase_core] Firebase initialized successfully
   [firebase_database] Firebase Database initialized
   ```

### Test 2: Send Message

1. **Login** vào app

2. **Vào tab Chat** (tab 4)

3. **Click vào một match**

4. **Check logs khi mở chat**:
   ```
   🔥 [CHAT_DETAIL] Initializing...
   🔥 [CHAT_DETAIL] Current user ID: 123
   🔥 [CHAT_DETAIL] Match user ID: 456
   🔥 [CHAT_SERVICE] Listening to messages in room: chat_123_456
   📥 [CHAT_SERVICE] No messages yet
   ```

5. **Gửi tin nhắn**: "Hello Firebase"

6. **Check logs**:
   ```
   📤 [CHAT_DETAIL] Sending message: "Hello Firebase"
   🔥 [CHAT_SERVICE] Room ID: chat_123_456
   🔥 [CHAT_SERVICE] Sender: 123 → Receiver: 456
   🔥 [CHAT_SERVICE] Message data: {sender_id: 123, receiver_id: 456, text: Hello Firebase, ...}
   ✅ [CHAT_SERVICE] Message pushed to Firebase: -Nxxxxx
   ✅ [CHAT_SERVICE] Chat info updated
   ✅ [CHAT_DETAIL] Message sent successfully
   📥 [CHAT_SERVICE] Messages stream event received
   📥 [CHAT_SERVICE] Messages count: 1
   ```

7. **Tin nhắn hiển thị** trong chat! ✅

### Test 3: Check Firebase Console

1. **Vào tab "Data"** trong Realtime Database

2. **Expand tree**:
   ```
   chats/
     chat_123_456/
       info/
         last_message: "Hello Firebase"
         last_message_time: "2025-11-01T..."
       messages/
         -Nxxxxx: {
           sender_id: 123
           receiver_id: 456
           text: "Hello Firebase"
           ...
         }
   ```

3. **Thấy data!** ✅

### Test 4: Realtime Sync

1. **Login 2 accounts**:
   - Device 1: User A (ID: 123)
   - Device 2 hoặc web: User B (ID: 456)

2. **Cả 2 đều vào Chat Detail** với nhau

3. **User A gửi tin nhắn**

4. **User B thấy tin nhắn ngay lập tức** (không cần reload) ✅

---

## ❌ TROUBLESHOOTING

### Lỗi 1: "User ID is null"

**Solution**: Đã fix ở trên! Cần:
1. Restart backend
2. Hot restart app (R R)
3. Logout và login lại

### Lỗi 2: "Permission denied"

**Logs:**
```
❌ [CHAT_SERVICE] Error: Permission denied
```

**Causes:**
- Firebase Rules chưa publish
- Rules không đúng

**Solution:**
1. Check Firebase Console → Rules
2. Verify rules có `.read: true` và `.write: true`
3. Click **"Publish"**
4. Restart app

### Lỗi 3: "Database not initialized"

**Logs:**
```
❌ Firebase Database not initialized
```

**Solution:**
1. Check đã tạo Realtime Database chưa
2. Verify `databaseURL` trong `firebase_options.dart`
3. Run: `flutter clean && flutter pub get`

### Lỗi 4: "Messages not syncing"

**Logs:**
```
📥 [CHAT_SERVICE] No messages yet
(tin nhắn gửi nhưng không hiển thị)
```

**Solution:**
1. Check internet connection
2. Check Firebase Console → Data → Có data không?
3. Restart app với full clean:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📊 CẤU TRÚC DỮ LIỆU FIREBASE

### Room ID Pattern:
```
chat_{userId1}_{userId2}
```
- User ID nhỏ hơn đứng trước
- VD: User 123 + User 456 = `chat_123_456`
- VD: User 789 + User 100 = `chat_100_789`

### Data Structure:
```
chats/
  chat_123_456/
    info/
      last_message: "Hello"
      last_message_time: "2025-11-01T10:30:00.000Z"
      last_sender_id: 123
    
    messages/
      -Nxxxxx1: {
        sender_id: 123
        receiver_id: 456
        text: "Hello"
        timestamp: "2025-11-01T10:30:00.000Z"
        is_read: false
      }
      -Nxxxxx2: {
        sender_id: 456
        receiver_id: 123
        text: "Hi there"
        timestamp: "2025-11-01T10:31:00.000Z"
        is_read: false
      }
```

---

## 🔒 PRODUCTION SECURITY RULES

⚠️ Test mode rules không an toàn cho production!

### Production Rules (với authentication):

```json
{
  "rules": {
    "chats": {
      "$roomId": {
        ".read": "auth != null && (
          $roomId.contains(auth.uid) || 
          $roomId.contains('' + auth.uid)
        )",
        ".write": "auth != null && (
          $roomId.contains(auth.uid) || 
          $roomId.contains('' + auth.uid)
        )",
        ".indexOn": ["timestamp", "receiver_id", "sender_id"],
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"],
          ".validate": "newData.hasChildren(['sender_id', 'receiver_id', 'text', 'timestamp'])"
        },
        "info": {
          ".validate": "newData.hasChildren(['last_message', 'last_message_time', 'last_sender_id'])"
        }
      }
    }
  }
}
```

**Requirements:**
- User phải authenticated (`auth != null`)
- User ID phải nằm trong Room ID (chỉ 2 người chat được access)
- Message phải có required fields
- Data validation

---

## ✅ FINAL CHECKLIST

### Setup:
- [ ] Firebase Console: Project tồn tại
- [ ] Firebase Console: Realtime Database created
- [ ] Firebase Console: Security Rules published
- [ ] Backend: Login API trả về user_id
- [ ] Frontend: Lưu user_id vào SharedPreferences
- [ ] App: firebase_options.dart có databaseURL

### Testing:
- [ ] App: Firebase initialized (check logs)
- [ ] App: User ID không null (check logs)
- [ ] App: Mở Chat Detail không crash
- [ ] App: Gửi tin nhắn thành công
- [ ] Firebase Console: Data xuất hiện
- [ ] App: Tin nhắn hiển thị trong chat
- [ ] App: Realtime sync hoạt động (2 users)

### Logs Pattern Success:

**Login:**
```
✅ Login data saved to SharedPreferences
👤 User ID: 123
```

**Open Chat:**
```
🔥 [CHAT_DETAIL] Current user ID: 123
🔥 [CHAT_SERVICE] Listening to messages in room: chat_123_456
```

**Send Message:**
```
📤 [CHAT_DETAIL] Sending message: "..."
✅ [CHAT_SERVICE] Message pushed to Firebase
📥 [CHAT_SERVICE] Messages count: 1
```

---

## 🚀 NEXT STEPS

Sau khi chat hoạt động:

1. **Phase 2**: Typing Indicator ("đang nhập...")
2. **Phase 3**: Online Status (green dot)
3. **Phase 4**: Image messages, reactions
4. **Phase 5**: Push notifications

---

## 📞 DEBUG COMMANDS

### View Firebase Data:
```bash
# Firebase Console → Data tab
# Expand: chats/chat_X_Y/messages
```

### Clear SharedPreferences (if needed):
```dart
// Add button in profile to clear cache:
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

### Monitor Firebase Usage:
```bash
# Firebase Console → Usage tab
# Check: Reads, Writes, Storage
```

---

**Status**: ✅ Setup hoàn tất - sẵn sàng test!

**Important**: PHẢI logout và login lại sau khi update backend để lưu user_id!
