# Firebase Realtime Chat - UI & Logic Summary

## ✅ Logic Chat Hoàn Chỉnh

### 1. **Phân biệt người gửi/người nhận**

#### Tin nhắn của mình (isMe = true):
- **Vị trí**: Bên phải màn hình
- **Màu sắc**: Gradient hồng (primary gradient)
- **Bo góc**: Góc trên phải nhọn, các góc khác bo tròn
- **Text**: Màu trắng
- **Icon trạng thái**: 
  - ✓ (done): Đã gửi
  - ✓✓ (done_all) màu xanh: Đã đọc

#### Tin nhắn người khác (isMe = false):
- **Vị trí**: Bên trái màn hình  
- **Màu sắc**: Xám nhạt (grey.shade200)
- **Bo góc**: Góc trên trái nhọn, các góc khác bo tròn
- **Text**: Màu đen
- **Không có icon trạng thái**

---

### 2. **Cấu trúc dữ liệu Firebase**

```
chats/
  chat_{userId1}_{userId2}/
    info/
      last_message: "Nội dung tin nhắn cuối"
      last_message_time: "2025-11-01T10:30:00.000Z"
      last_sender_id: 27
    
    messages/
      -O1Abc123xyz/
        sender_id: 27
        receiver_id: 33
        text: "Hello"
        timestamp: "2025-11-01T10:30:00.000Z"
        is_read: false
        image_url: null
      
      -O1Def456uvw/
        sender_id: 33
        receiver_id: 27
        text: "Hi there!"
        timestamp: "2025-11-01T10:31:00.000Z"
        is_read: true
        image_url: null
```

**Room ID Pattern**: 
- Luôn sort user IDs để đảm bảo consistency
- VD: user 27 và 33 → `chat_27_33`

---

### 3. **Lưu lịch sử trò chuyện**

#### Cơ chế lưu:
1. **Gửi tin nhắn** → `ChatService.sendMessage()`
   - Tạo Message object với timestamp hiện tại
   - Push vào Firebase: `chats/{roomId}/messages/`
   - Firebase auto-generate unique key
   - Update last_message trong `info/`

2. **Lắng nghe realtime** → `ChatService.getMessages()`
   - Stream lắng nghe thay đổi trên Firebase
   - Tự động cập nhật UI khi có tin nhắn mới
   - Sắp xếp theo timestamp tăng dần

3. **Đánh dấu đã đọc** → `ChatService.markMessagesAsRead()`
   - Khi vào màn hình chat
   - Tìm tất cả tin nhắn chưa đọc (is_read = false)
   - Update is_read = true cho tin nhắn của người khác

---

### 4. **Flow hoạt động**

#### Khi người dùng gửi tin nhắn:
```
User nhập text → Nhấn Send
    ↓
ChatDetailScreen._sendMessage()
    ↓
ChatService.sendMessage()
    ↓
Firebase Realtime Database
    ↓
Stream onValue trigger
    ↓
UI tự động update với tin nhắn mới
```

#### Khi người khác gửi tin nhắn:
```
User B gửi tin nhắn → Firebase
    ↓
Stream onValue trigger ở User A
    ↓
getMessages() nhận data mới
    ↓
UI của User A tự động hiển thị tin nhắn
    ↓
markMessagesAsRead() đánh dấu đã đọc
```

---

### 5. **Features đã implement**

✅ **Realtime messaging**: Tin nhắn xuất hiện ngay lập tức  
✅ **Message history**: Lưu toàn bộ lịch sử trên Firebase  
✅ **Read status**: Đánh dấu tin nhắn đã đọc (✓✓)  
✅ **Unread count**: Đếm số tin nhắn chưa đọc (badge)  
✅ **Last message sync**: Hiển thị tin nhắn cuối trong danh sách  
✅ **Sender/Receiver UI**: Phân biệt rõ ràng bằng màu sắc + vị trí  
✅ **Image support**: Hỗ trợ gửi ảnh (field imageUrl)  
✅ **Auto-scroll**: Tự động scroll xuống tin nhắn mới  
✅ **Timestamp**: Hiển thị thời gian gửi (HH:mm)  

---

### 6. **UI Components**

#### ChatBubble Widget:
```dart
ChatBubble(
  message: Message(...),
  isMe: message.senderId == currentUserId,
)
```

- **isMe = true**: Tin nhắn của mình
  - Align: right
  - Color: gradient pink
  - Text: white
  
- **isMe = false**: Tin nhắn người khác
  - Align: left
  - Color: grey
  - Text: black

#### RealtimeMatchCard Widget:
- Hiển thị unread badge
- Stream unread count từ Firebase
- Sync last message realtime

---

### 7. **Testing Checklist**

- [ ] Backend đã khởi động (192.168.1.61:8000)
- [ ] Firebase Realtime Database đã tạo
- [ ] Security Rules đã publish (test mode)
- [ ] Login thành công không lỗi
- [ ] User ID được fetch từ Profile API
- [ ] Gửi tin nhắn → hiển thị bên phải (gradient pink)
- [ ] Người khác gửi → hiển thị bên trái (grey)
- [ ] Tin nhắn lưu trong Firebase Console
- [ ] Refresh app → lịch sử vẫn còn
- [ ] Icon ✓✓ hiện khi đã đọc
- [ ] Unread badge cập nhật đúng
- [ ] Last message sync trong Match list

---

## Lưu ý quan trọng

### Firebase Realtime Database PHẢI được setup:
1. Vào Firebase Console
2. Create Realtime Database
3. Publish Security Rules (test mode)
4. Database URL: `https://app-henho-119c8-default-rtdb.firebaseio.com`

### Backend PHẢI chạy:
- Login API hoạt động bình thường
- Profile API trả về user_id

### Không cần backend cho chat:
- Chat hoàn toàn qua Firebase
- Backend chỉ cần cho authentication
- Tin nhắn lưu trực tiếp trên Firebase

---

## Debug Commands

### Check Firebase connection:
```dart
print('🔥 [CHAT_SERVICE] Room ID: $roomId');
print('🔥 [CHAT_SERVICE] Message data: ${message.toJson()}');
print('✅ [CHAT_SERVICE] Message pushed to Firebase');
```

### Check message stream:
```dart
print('📥 [CHAT_SERVICE] Messages count: ${data.length}');
print('📥 [CHAT_SERVICE] Returning ${messages.length} messages');
```

### Verify trong Firebase Console:
- Vào **Data** tab
- Xem cấu trúc `chats/{roomId}/messages/`
- Kiểm tra tin nhắn có hiển thị không
