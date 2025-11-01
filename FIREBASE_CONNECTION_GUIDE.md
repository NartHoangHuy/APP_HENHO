# 🔥 HƯỚNG DẪN KẾT NỐI FIREBASE REALTIME DATABASE

## 📋 CHECKLIST SETUP

### ✅ BƯỚC 1: FIREBASE CONSOLE SETUP

1. **Truy cập Firebase Console**:
   ```
   https://console.firebase.google.com/
   ```

2. **Chọn project**: 
   - Project ID: `app-henho-119c8`
   - Database URL: `https://app-henho-119c8-default-rtdb.firebaseio.com`

3. **Tạo Realtime Database** (nếu chưa có):
   - Sidebar → Build → **Realtime Database**
   - Click **"Create Database"**
   - Chọn location: **US (us-central1)** hoặc gần bạn nhất
   - Start in **test mode** (cho development)

4. **Cấu hình Security Rules**:
   - Click tab **"Rules"**
   - Paste code sau:

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

   - Click **"Publish"** để lưu

⚠️ **LƯU Ý**: Rules trên cho phép tất cả mọi người read/write (test mode). Production nên thêm authentication!

---

## 📊 CẤU TRÚC DỮ LIỆU FIREBASE

### Firebase Realtime Database Structure:

```
chats/
  chat_123_456/                    ← Room ID (userId nhỏ trước)
    info/
      last_message: "Xin chào"
      last_message_time: "2025-11-01T10:30:00.000Z"
      last_sender_id: 123
    
    messages/
      -Nxxxxx1: {                  ← Auto-generated key
        sender_id: 123
        receiver_id: 456
        text: "Xin chào"
        timestamp: "2025-11-01T10:30:00.000Z"
        is_read: false
      }
      -Nxxxxx2: {
        sender_id: 456
        receiver_id: 123
        text: "Chào bạn"
        timestamp: "2025-11-01T10:31:00.000Z"
        is_read: false
      }
```

### Giải thích:
- **Room ID**: `chat_{userId1}_{userId2}` (ID nhỏ hơn đứng trước)
  - VD: User 123 chat với User 456 → Room ID: `chat_123_456`
  - VD: User 789 chat với User 456 → Room ID: `chat_456_789`
- **Messages**: Auto-generated keys bởi Firebase (`.push()`)
- **Info**: Metadata của phòng chat (last message, timestamp)

---

## 🧪 TEST KẾT NỐI

### Test 1: Kiểm tra Firebase init

1. **Hot reload** app hoặc restart
2. **Check logs** khi app start:
   ```
   [firebase_core] Firebase initialized successfully
   [firebase_database] Firebase Database initialized
   ```

### Test 2: Gửi tin nhắn

1. **Login 2 accounts**:
   - Account A: User ID = X
   - Account B: User ID = Y

2. **Match với nhau** (nếu chưa match)

3. **Account A vào Chat Detail** với Account B

4. **Gửi tin nhắn**: "Hello test"

5. **Check logs** trong terminal:
   ```
   🔥 [CHAT_DETAIL] Initializing...
   🔥 [CHAT_DETAIL] Current user ID: 123
   🔥 [CHAT_DETAIL] Match user ID: 456
   🔥 [CHAT_DETAIL] Messages stream initialized
   🔥 [CHAT_SERVICE] Room ID: chat_123_456
   📤 [CHAT_DETAIL] Sending message: "Hello test"
   🔥 [CHAT_SERVICE] Message data: {sender_id: 123, receiver_id: 456, text: Hello test, ...}
   ✅ [CHAT_SERVICE] Message pushed to Firebase: -Nxxxxx
   ✅ [CHAT_SERVICE] Chat info updated
   ✅ [CHAT_DETAIL] Message sent successfully
   📥 [CHAT_SERVICE] Messages stream event received
   📥 [CHAT_SERVICE] Messages count: 1
   ```

6. **Check Firebase Console**:
   - Vào tab **"Data"**
   - Expand `chats/chat_123_456/messages`
   - Thấy tin nhắn vừa gửi ✅

### Test 3: Realtime sync

1. **Account B vào Chat Detail** với Account A
2. **Account A gửi tin nhắn**
3. **Account B thấy tin nhắn ngay lập tức** (không cần reload)

---

## ❌ TROUBLESHOOTING

### Lỗi 1: "Permission denied"

**Logs:**
```
❌ [CHAT_SERVICE] Error: Permission denied
```

**Nguyên nhân**: Firebase Rules không cho phép read/write

**Giải pháp**:
1. Check Firebase Console → Realtime Database → Rules
2. Verify rules cho phép read/write (test mode):
   ```json
   {
     "rules": {
       "chats": {
         ".read": true,
         ".write": true
       }
     }
   }
   ```
3. Click **Publish**
4. Restart app

---

### Lỗi 2: "Messages stream not updating"

**Logs:**
```
🔥 [CHAT_SERVICE] Listening to messages in room: chat_123_456
📥 [CHAT_SERVICE] No messages yet
(không có update sau khi gửi tin nhắn)
```

**Nguyên nhân**: Database URL không đúng hoặc stream chưa connect

**Giải pháp**:
1. Verify Database URL trong `firebase_options.dart`:
   ```dart
   databaseURL: 'https://app-henho-119c8-default-rtdb.firebaseio.com'
   ```
2. Check internet connection
3. Restart app với full clean:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### Lỗi 3: "User ID is null"

**Logs:**
```
❌ [CHAT_DETAIL] User ID is null!
```

**Nguyên nhân**: `user_id` không được lưu trong SharedPreferences

**Giải pháp**:
1. Check login API response có trả về `user_id`
2. Verify trong `auth_service.dart` có lưu `user_id`:
   ```dart
   await prefs.setInt('user_id', userId);
   ```
3. Re-login để lưu lại user_id

---

### Lỗi 4: "Cannot send: empty text or null user ID"

**Logs:**
```
⚠️ [CHAT_DETAIL] Cannot send: empty text or null user ID
```

**Nguyên nhân**: 
- TextField trống HOẶC
- Current user ID chưa được set

**Giải pháp**:
1. Đảm bảo đã nhập tin nhắn
2. Check `_currentUserId` đã được set trong `_initialize()`

---

## 🔍 DEBUG COMMANDS

### Check Firebase Console:
1. Data tab: Xem cấu trúc dữ liệu realtime
2. Rules tab: Verify security rules
3. Usage tab: Monitor reads/writes

### Check Logs Pattern:

**Khởi tạo thành công:**
```
🔥 [CHAT_DETAIL] Initializing...
🔥 [CHAT_DETAIL] Current user ID: 123
🔥 [CHAT_DETAIL] Messages stream initialized
```

**Gửi tin nhắn thành công:**
```
📤 [CHAT_DETAIL] Sending message: "..."
🔥 [CHAT_SERVICE] Room ID: chat_X_Y
✅ [CHAT_SERVICE] Message pushed to Firebase
✅ [CHAT_DETAIL] Message sent successfully
```

**Nhận tin nhắn realtime:**
```
📥 [CHAT_SERVICE] Messages stream event received
📥 [CHAT_SERVICE] Messages count: X
```

---

## 🚀 PRODUCTION SECURITY RULES

Khi deploy production, thay rules bằng:

```json
{
  "rules": {
    "chats": {
      "$roomId": {
        ".read": "auth != null && ($roomId.contains(auth.uid))",
        ".write": "auth != null && ($roomId.contains(auth.uid))",
        ".indexOn": ["timestamp", "receiver_id", "sender_id"],
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"],
          ".validate": "newData.hasChildren(['sender_id', 'receiver_id', 'text', 'timestamp'])"
        }
      }
    }
  }
}
```

**Yêu cầu**:
- User phải authenticated (`auth != null`)
- User ID phải nằm trong Room ID (chỉ 2 người trong chat được access)
- Message phải có đầy đủ required fields

---

## ✅ TEST CHECKLIST

- [ ] Firebase Console: Database created
- [ ] Firebase Console: Rules published
- [ ] App: Firebase initialized (check logs)
- [ ] App: User ID saved in SharedPreferences
- [ ] App: Can open Chat Detail screen
- [ ] App: Can send message
- [ ] Firebase Console: Message appears in Data tab
- [ ] App: Message appears in chat (realtime)
- [ ] App: Second user sees message (realtime sync)
- [ ] App: Unread count updates correctly

---

## 📞 NEXT STEPS

Sau khi Chat hoạt động, bạn có thể:

1. **Phase 2**: Typing Indicator ("đang nhập...")
2. **Phase 3**: Online Status (green dot)
3. **Phase 4**: Image messages, reactions, voice messages

---

**Status**: ✅ Code đã sẵn sàng - chỉ cần setup Firebase Console!
