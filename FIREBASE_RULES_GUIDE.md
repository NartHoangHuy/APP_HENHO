# Firebase Realtime Database - Security Rules Guide

## 🔥 Rules Hiện Tại của Bạn

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

### ✅ Ưu điểm:
- Cho phép read/write (tốt cho development)
- Có index cho `timestamp` và `receiver_id` (quan trọng cho query)

### ⚠️ Vấn đề nhỏ:
- Index nên đặt ở level `messages`, không phải ở `$roomId`
- Index `sender_id` không cần thiết (chúng ta không query theo sender)

---

## 🎯 Rules Được Đề Xuất (Development Mode)

### Version 1: Test Mode (Đơn giản nhất - Dùng ngay)

```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"]
        }
      }
    }
  }
}
```

**Giải thích:**
- `.read: true` - Ai cũng đọc được (OK cho test)
- `.write: true` - Ai cũng ghi được (OK cho test)
- Index đặt đúng vị trí (`messages` level)
- Chỉ index những field thực sự dùng để query

---

### Version 2: Có Validation (Tốt hơn)

```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        "info": {
          ".validate": "newData.hasChildren(['last_message', 'last_message_time', 'last_sender_id'])"
        },
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"],
          "$messageId": {
            ".validate": "newData.hasChildren(['sender_id', 'receiver_id', 'text', 'timestamp', 'is_read'])"
          }
        }
      }
    }
  }
}
```

**Giải thích:**
- Thêm validation để đảm bảo data có đủ fields
- Vẫn cho phép read/write thoải mái (development)

---

### Version 3: Production Mode (An toàn nhất - Dùng sau)

```json
{
  "rules": {
    "chats": {
      "$roomId": {
        ".read": "auth != null",
        ".write": "auth != null",
        
        "info": {
          ".validate": "newData.hasChildren(['last_message', 'last_message_time', 'last_sender_id'])"
        },
        
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"],
          
          "$messageId": {
            ".write": "auth != null && (!data.exists() || data.child('sender_id').val() == auth.uid)",
            ".validate": "newData.hasChildren(['sender_id', 'receiver_id', 'text', 'timestamp', 'is_read']) && newData.child('sender_id').val() == auth.uid"
          }
        }
      }
    }
  }
}
```

**Giải thích:**
- Yêu cầu authentication (Firebase Auth)
- Chỉ người gửi mới có thể edit tin nhắn của mình
- Data validation chặt chẽ

**⚠️ LƯU Ý:** Version 3 yêu cầu Firebase Authentication. App hiện tại chưa có Firebase Auth nên chưa dùng được.

---

## 📋 So Sánh Index Position

### ❌ SAI (Index ở $roomId level):
```json
{
  "$roomId": {
    ".indexOn": ["timestamp", "receiver_id"],  // ← SAI vị trí
    "messages": {
      // ...
    }
  }
}
```

### ✅ ĐÚNG (Index ở messages level):
```json
{
  "$roomId": {
    "messages": {
      ".indexOn": ["timestamp", "receiver_id"]  // ← ĐÚNG vị trí
    }
  }
}
```

**Tại sao?**
- Index phải đặt ở level mà bạn query
- Chúng ta query: `chats/$roomId/messages` → Index phải ở `messages`
- Query theo `timestamp` để sort tin nhắn
- Query theo `receiver_id` để đếm unread messages

---

## 🚀 Khuyến Nghị Cho Bạn

### Hiện tại (Development):
**Sử dụng Version 1** - Đơn giản và đủ dùng:

```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"]
        }
      }
    }
  }
}
```

### Copy & Paste vào Firebase Console:

1. Vào Firebase Console → Realtime Database
2. Click tab **Rules**
3. Xóa hết rules cũ
4. Paste rules mới ở trên
5. Click **Publish**

---

## 🔍 Test Rules

### Sau khi publish rules mới:

1. **Restart app** (hot restart)
2. **Login** vào app
3. **Vào Chat** → Chọn một match
4. **Gửi tin nhắn**
5. **Kiểm tra logs**:
   ```
   ✅ [CHAT_SERVICE] Message pushed to Firebase
   ✅ [CHAT_SERVICE] Chat info updated
   📥 [CHAT_SERVICE] Messages count: 1
   ```

### Verify trên Firebase Console:

1. Vào **Data** tab
2. Mở `chats` → `chat_X_Y` → `messages`
3. Xem tin nhắn có hiển thị không
4. Kiểm tra structure:
   ```
   chats/
     chat_27_33/
       info/
         last_message: "..."
         last_message_time: "..."
         last_sender_id: 27
       messages/
         -O1abc123xyz/
           sender_id: 27
           receiver_id: 33
           text: "Hello"
           timestamp: "..."
           is_read: false
   ```

---

## 🎯 Index Explanation

### Tại sao cần index "timestamp"?
```dart
// Trong chat_service.dart
messagesRef.orderByChild('timestamp').onValue
```
→ Sort tin nhắn theo thời gian → Cần index `timestamp`

### Tại sao cần index "receiver_id"?
```dart
// Trong chat_service.dart (getUnreadCount)
messagesRef.orderByChild('receiver_id').equalTo(currentUserId)
```
→ Query tin nhắn chưa đọc → Cần index `receiver_id`

### Tại sao KHÔNG cần index "sender_id"?
- Không có query nào dùng `orderByChild('sender_id')`
- Không cần thiết cho logic hiện tại

---

## 📊 Performance Impact

### Với index đúng:
- ✅ Query nhanh
- ✅ Real-time update smooth
- ✅ Không có warning trong console

### Không có index:
- ❌ Query chậm (scan toàn bộ data)
- ⚠️ Warning: "Consider adding '.indexOn'"
- 🐌 Performance kém với nhiều messages

---

## 🔒 Security Notes

### Test Mode (Hiện tại):
```json
".read": true,
".write": true
```
- ✅ Dễ test
- ⚠️ Không an toàn cho production
- 🚫 Ai cũng có thể đọc/ghi data

### Production Mode (Sau này):
```json
".read": "auth != null",
".write": "auth != null"
```
- ✅ Chỉ user đã login mới truy cập được
- ✅ An toàn hơn
- ⚠️ Cần implement Firebase Authentication

**KẾT LUẬN:**
- Hiện tại dùng Test Mode là OK
- Sau khi launch app, cần upgrade lên Production Mode
- Kết hợp với Firebase Authentication để bảo mật

---

## 💡 Quick Fix Cho Bạn

### Rules cần thay đổi từ:
```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        ".indexOn": ["timestamp", "receiver_id", "sender_id"],  // ← Sai vị trí
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"]
        }
      }
    }
  }
}
```

### Thành:
```json
{
  "rules": {
    "chats": {
      ".read": true,
      ".write": true,
      "$roomId": {
        "messages": {
          ".indexOn": ["timestamp", "receiver_id"]  // ← Chỉ cần cái này
        }
      }
    }
  }
}
```

**Thay đổi:**
- ❌ Xóa `.indexOn` ở `$roomId` level
- ❌ Xóa `sender_id` khỏi index (không dùng)
- ✅ Giữ nguyên index ở `messages` level

Publish rules mới và test lại! 🚀
