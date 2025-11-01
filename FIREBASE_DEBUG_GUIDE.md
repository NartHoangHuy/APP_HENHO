# Firebase Realtime Chat - Debug Guide

## Vấn đề: Không lưu được lịch sử trò chuyện

### Nguyên nhân có thể:

1. **Backend đang lỗi 500** ❌
   - Login API bị lỗi AttributeError
   - Cần restart backend server

2. **Firebase Realtime Database chưa được tạo** ❌
   - Chưa vào Firebase Console tạo database
   - Chưa publish Security Rules

3. **Quyền truy cập Firebase bị chặn** ❌
   - Security Rules chặn write
   - Cần set rules thành test mode

---

## Giải pháp:

### Bước 1: Restart Backend Server

```powershell
cd D:\flutter\App_HenHo\backend_project
python manage.py runserver 192.168.1.61:8000
```

Đảm bảo không có lỗi 500 khi login.

---

### Bước 2: Setup Firebase Realtime Database

#### 2.1. Tạo Database
1. Vào [Firebase Console](https://console.firebase.google.com)
2. Chọn project **"App HenHo"**
3. Click **Build** → **Realtime Database**
4. Click **Create Database**
5. Chọn location: **us-central1**
6. Chọn **Start in test mode**
7. Click **Enable**

#### 2.2. Publish Security Rules
Vào tab **Rules** và paste:

```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        ".indexOn": ["timestamp", "receiver_id", "sender_id"]
      }
    }
  }
}
```

Click **Publish**.

---

### Bước 3: Test Trên App

1. **Login thành công** (không còn lỗi 500)
2. **Vào trang Chat** → Chọn một match
3. **Gửi tin nhắn**: "Hello test"
4. **Kiểm tra logs** trong terminal Flutter:
   ```
   🔥 [CHAT_SERVICE] Room ID: chat_27_33
   🔥 [CHAT_SERVICE] Sender: 27 → Receiver: 33
   🔥 [CHAT_SERVICE] Message data: {...}
   ✅ [CHAT_SERVICE] Message pushed to Firebase: ...
   ✅ [CHAT_SERVICE] Chat info updated
   ```

---

### Bước 4: Verify Trên Firebase Console

1. Vào Firebase Console → Realtime Database → **Data** tab
2. Kiểm tra cấu trúc:
   ```
   chats/
     chat_27_33/
       info/
         last_message: "Hello test"
         last_message_time: "2025-11-01T..."
         last_sender_id: 27
       messages/
         -O1abc123xyz/
           sender_id: 27
           receiver_id: 33
           text: "Hello test"
           timestamp: "2025-11-01T..."
           is_read: false
   ```

---

## Debug Logs Chính

### ✅ Thành công:
```
🔥 [CHAT_DETAIL] Current user ID: 27
🔥 [CHAT_SERVICE] Room ID: chat_27_33
✅ [CHAT_SERVICE] Message pushed to Firebase
📥 [CHAT_SERVICE] Messages count: 1
```

### ❌ Lỗi:
```
❌ [CHAT_DETAIL] User ID is null!
❌ [CHAT_SERVICE] Error sending message: ...
📡 Login response status: 500
```

---

## Checklist

- [ ] Backend đang chạy không lỗi (192.168.1.61:8000)
- [ ] Login thành công không có lỗi 500
- [ ] Firebase Realtime Database đã được tạo
- [ ] Security Rules đã publish
- [ ] App có thể fetch user_id từ Profile API
- [ ] Logs hiện "Message pushed to Firebase"
- [ ] Tin nhắn xuất hiện trong Firebase Console Data tab
- [ ] Tin nhắn hiển thị trong app

---

## Lưu ý

**Test Mode Security Rules** chỉ dùng để development. 
Sau khi test xong, cần thay bằng rules an toàn hơn:

```json
{
  "rules": {
    "chats": {
      "$roomId": {
        ".read": "auth != null",
        ".write": "auth != null",
        ".indexOn": ["timestamp", "receiver_id", "sender_id"]
      }
    }
  }
}
```

Tuy nhiên hiện tại chưa implement Firebase Auth, nên tạm dùng test mode.
