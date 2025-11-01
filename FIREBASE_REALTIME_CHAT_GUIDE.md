# 🔥 FIREBASE REALTIME CHAT - HƯỚNG DẪN CHI TIẾT

## 📋 MỤC LỤC
- [Phase 0: Kiểm tra Firebase Setup](#phase-0)
- [Phase 1: Cải thiện Chat hiện tại](#phase-1)
- [Phase 2: Typing Indicator](#phase-2)
- [Phase 3: Online Status](#phase-3)
- [Phase 4: Advanced Features](#phase-4)

---

## 🎯 PHASE 0: KIỂM TRA FIREBASE SETUP

### ✅ ĐÃ CÓ SẴN:

1. **Firebase Project**: `app-henho-119c8`
2. **Database URL**: `https://app-henho-119c8-default-rtdb.firebaseio.com`
3. **Flutter Packages**:
   - ✅ `firebase_core: ^3.15.2`
   - ✅ `firebase_database: ^11.3.10`
4. **Firebase Init** trong `main.dart`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

### 🔍 KIỂM TRA FIREBASE CONSOLE

1. **Truy cập Firebase Console**:
   - URL: https://console.firebase.google.com/
   - Chọn project: `app-henho-119c8`

2. **Kiểm tra Realtime Database**:
   - Sidebar → Build → Realtime Database
   - Xem có database chưa? (nếu chưa, tạo mới)
   - Region: `us-central1` (default)

3. **Cấu hình Security Rules** (QUAN TRỌNG!):
   ```json
   {
     "rules": {
       "chats": {
         "$roomId": {
           ".read": "auth != null",
           ".write": "auth != null",
           "messages": {
             ".indexOn": ["timestamp", "receiver_id"]
           }
         }
       },
       "users": {
         "$userId": {
           ".read": true,
           ".write": "$userId === auth.uid"
         }
       },
       "typing": {
         "$roomId": {
           ".read": true,
           ".write": true
         }
       }
     }
   }
   ```

   **⚠️ LƯU Ý**: Hiện tại rules cho phép tất cả read/write (development mode). Production nên thêm authentication.

### 🧪 TEST FIREBASE CONNECTION

Chạy app và xem logs:
```bash
flutter run
```

Logs success:
```
[firebase_database] Firebase Database initialized
[firebase_core] Firebase initialized successfully
```

---

## 🎯 PHASE 1: CẢI THIỆN CHAT HIỆN TẠI

### ✅ MỤC TIÊU:
1. Sync last message từ Firebase → Match model
2. Real-time unread count
3. Auto-scroll khi có tin nhắn mới
4. Loading states tốt hơn

### 📁 CẤU TRÚC FIREBASE:

```
chats/
  chat_{userId1}_{userId2}/
    info/
      last_message: "Xin chào"
      last_message_time: "2025-11-01T10:30:00Z"
      last_sender_id: 123
      unread_count_user1: 0
      unread_count_user2: 2
    messages/
      -Nxxx: {
        sender_id: 123
        receiver_id: 456
        text: "Hello"
        timestamp: "2025-11-01T10:30:00Z"
        is_read: true
      }
```

### 🔧 IMPLEMENTATION:

#### 1. Update `chat_service.dart`:
- ✅ Add `getChatInfo()` - lấy thông tin phòng chat
- ✅ Add `getUnreadCount()` - lấy số tin nhắn chưa đọc
- ✅ Update `markMessagesAsRead()` - reset unread count

#### 2. Update `ChatScreen`:
- ✅ Sync last message từ Firebase
- ✅ Show unread badge với số lượng
- ✅ Real-time update khi có tin nhắn mới

#### 3. Update `ChatDetailScreen`:
- ✅ Auto-scroll khi có tin nhắn mới
- ✅ Mark as read khi vào màn hình
- ✅ Show "Đã gửi" / "Đã nhận" status

---

## 🎯 PHASE 2: TYPING INDICATOR

### ✅ MỤC TIÊU:
Show "Đang nhập..." khi người kia đang gõ tin nhắn

### 📁 FIREBASE STRUCTURE:

```
typing/
  chat_{userId1}_{userId2}/
    user_123: {
      is_typing: true
      timestamp: 1698765432000
    }
```

### 🔧 IMPLEMENTATION:

#### 1. Update `chat_service.dart`:
```dart
// Set typing status
Future<void> setTyping(int userId, int otherUserId, bool isTyping)

// Listen typing status
Stream<bool> getTypingStatus(int userId, int otherUserId)
```

#### 2. Update `ChatDetailScreen`:
```dart
// Trong TextField onChange:
onChanged: (text) {
  if (text.isNotEmpty) {
    _chatService.setTyping(_currentUserId!, widget.match.userId, true);
  }
  // Auto hide sau 3s
}

// Listen và hiển thị:
StreamBuilder(
  stream: _chatService.getTypingStatus(widget.match.userId, _currentUserId!),
  builder: (context, snapshot) {
    if (snapshot.data == true) {
      return Text('đang nhập...', style: TextStyle(color: Colors.grey));
    }
    return SizedBox.shrink();
  }
)
```

### 🎨 UI DESIGN:
```
┌─────────────────────────┐
│  Avatar  Nguyễn Văn A  │
│          đang nhập...   │ ← Animated dots
├─────────────────────────┤
│  Tin nhắn...            │
└─────────────────────────┘
```

---

## 🎯 PHASE 3: ONLINE STATUS

### ✅ MỤC TIÊU:
1. Track user online/offline
2. Show "Đang hoạt động" / "Hoạt động X phút trước"
3. Green dot indicator

### 📁 FIREBASE STRUCTURE:

```
users/
  user_123/
    status: "online" | "offline"
    last_seen: 1698765432000
```

### 🔧 IMPLEMENTATION:

#### 1. Create `presence_service.dart`:
```dart
class PresenceService {
  // Set user online when app opens
  Future<void> goOnline(int userId)
  
  // Set user offline when app closes
  Future<void> goOffline(int userId)
  
  // Listen user status
  Stream<UserStatus> getUserStatus(int userId)
  
  // Auto disconnect when network drops
  void setupPresence(int userId)
}
```

#### 2. Firebase Presence với `.onDisconnect()`:
```dart
final statusRef = _database.child('users/$userId/status');

// Set online
await statusRef.set('online');

// Auto set offline khi disconnect
await statusRef.onDisconnect().set('offline');
await _database.child('users/$userId/last_seen').onDisconnect().set(ServerValue.timestamp);
```

#### 3. Update UI:
```dart
// Chat list
StreamBuilder<UserStatus>(
  stream: _presenceService.getUserStatus(match.userId),
  builder: (context, snapshot) {
    if (snapshot.data?.isOnline == true) {
      return Icon(Icons.circle, color: Colors.green, size: 12);
    }
    return Text('Hoạt động ${_formatLastSeen(snapshot.data?.lastSeen)}');
  }
)
```

### 🎨 UI DESIGN:
```
┌─────────────────────────┐
│ 🟢 Avatar  Nguyễn Văn A │ ← Green dot
│            Đang hoạt động│
├─────────────────────────┤
│ ⚪ Avatar  Trần Thị B   │
│            5 phút trước  │
└─────────────────────────┘
```

---

## 🎯 PHASE 4: ADVANCED FEATURES

### 1. 📸 IMAGE MESSAGES

#### Implementation:
```dart
// chat_service.dart
Future<void> sendImageMessage(int senderId, int receiverId, File image) async {
  // 1. Upload ảnh lên Firebase Storage
  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  await imageRef.putFile(image);
  
  // 2. Lấy download URL
  final imageUrl = await imageRef.getDownloadURL();
  
  // 3. Gửi message với imageUrl
  await sendMessage(senderId, receiverId, '', imageUrl: imageUrl);
}
```

#### UI:
```dart
// Show image message
if (message.imageUrl != null) {
  CachedNetworkImage(imageUrl: message.imageUrl!)
}
```

### 2. ❤️ MESSAGE REACTIONS

#### Firebase Structure:
```
chats/chat_123_456/messages/-Nxxx/reactions/
  user_123: "❤️"
  user_456: "😂"
```

#### Implementation:
```dart
Future<void> addReaction(String messageId, int userId, String emoji) async {
  final reactionRef = _database.child('chats/$roomId/messages/$messageId/reactions/$userId');
  await reactionRef.set(emoji);
}
```

### 3. 🗑️ DELETE MESSAGES

#### Options:
- **Delete for me**: Chỉ xóa local (add deleted_by array)
- **Delete for everyone**: Xóa hoàn toàn message

#### Implementation:
```dart
Future<void> deleteMessage(String messageId, int userId, {bool forEveryone = false}) async {
  if (forEveryone) {
    await _database.child('chats/$roomId/messages/$messageId').remove();
  } else {
    await _database.child('chats/$roomId/messages/$messageId/deleted_by/$userId').set(true);
  }
}
```

### 4. 🎤 VOICE MESSAGES

#### Implementation:
1. Record audio với `flutter_sound`
2. Upload lên Firebase Storage
3. Send message với audioUrl
4. Play audio với custom player widget

---

## 🚀 DEPLOYMENT CHECKLIST

### 1. Security Rules (Production)
```json
{
  "rules": {
    "chats": {
      "$roomId": {
        ".read": "auth != null && ($roomId.contains(auth.uid))",
        ".write": "auth != null && ($roomId.contains(auth.uid))"
      }
    }
  }
}
```

### 2. Indexes (Performance)
```json
{
  "rules": {
    "chats": {
      "$roomId": {
        "messages": {
          ".indexOn": ["timestamp", "receiver_id", "sender_id"]
        }
      }
    }
  }
}
```

### 3. Data Validation
```json
{
  "rules": {
    "chats": {
      "$roomId": {
        "messages": {
          "$messageId": {
            ".validate": "newData.hasChildren(['sender_id', 'receiver_id', 'text', 'timestamp'])"
          }
        }
      }
    }
  }
}
```

---

## 📚 TÀI LIỆU THAM KHẢO

1. **Firebase Realtime Database**:
   - Docs: https://firebase.google.com/docs/database
   - Flutter: https://firebase.flutter.dev/docs/database/overview

2. **Firebase Presence**:
   - Guide: https://firebase.google.com/docs/database/web/offline-capabilities

3. **Best Practices**:
   - Structure Data: https://firebase.google.com/docs/database/web/structure-data
   - Security Rules: https://firebase.google.com/docs/database/security

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Permission denied"
```
Solution: Kiểm tra Firebase Security Rules
```

### Lỗi: Messages không sync realtime
```
Solution: 
1. Check internet connection
2. Verify Firebase init in main.dart
3. Check database URL in firebase_options.dart
```

### Lỗi: Typing indicator không tắt
```
Solution: Add auto-clear sau 3 seconds timeout
```

---

## ✅ TODO LIST

- [x] Phase 0: Setup Firebase
- [ ] Phase 1: Improve base chat
  - [ ] Sync last message
  - [ ] Unread count
  - [ ] Auto-scroll
- [ ] Phase 2: Typing indicator
  - [ ] Set typing status
  - [ ] Listen typing status
  - [ ] UI animation
- [ ] Phase 3: Online status
  - [ ] Presence service
  - [ ] Online/offline tracking
  - [ ] Last seen
- [ ] Phase 4: Advanced features
  - [ ] Image messages
  - [ ] Reactions
  - [ ] Delete messages
  - [ ] Voice messages

---

**🎉 Chúc bạn code vui vẻ!**
