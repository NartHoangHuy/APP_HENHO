# Debug: Tin nhắn hiển thị sai

## 🔍 Vấn đề phát hiện

Từ ảnh screenshot, tin nhắn đang hiển thị:
- "BpL7xQ2Y38V1E2lZZcOPkqm..." (trông giống user ID hoặc token)
- Thay vì nội dung thực tế như "Xin chao", "HUTECH", "IT"

## 🎯 Nguyên nhân có thể

### 1. Text bị ghi đè khi gửi
```dart
// Có thể đang gửi userId thay vì text
await _chatService.sendMessage(
  _currentUserId!,
  widget.match.userId,
  _messageController.text.trim(),  // ← Kiểm tra xem có đúng text không
);
```

### 2. Firebase đang lưu sai field
```json
{
  "messages": {
    "-O1abc": {
      "sender_id": 27,
      "receiver_id": 33,
      "text": "BpL7x...",  // ← Text đang là gì?
      "timestamp": "...",
      "is_read": false
    }
  }
}
```

### 3. UI hiển thị sai field
```dart
Text(
  message.text,  // ← Đang lấy đúng field text?
)
```

---

## 🛠️ Cách Debug

### Bước 1: Kiểm tra logs khi gửi tin nhắn

Trong terminal Flutter, tìm logs:
```
📤 [CHAT_DETAIL] Sending message: "..."
🔥 [CHAT_SERVICE] Message data: {...}
✅ [CHAT_SERVICE] Message pushed to Firebase
```

**Kiểm tra:**
- `Sending message:` có đúng text không?
- `Message data:` field `text` có giá trị gì?

### Bước 2: Kiểm tra Firebase Console

1. Vào **Firebase Console** → **Realtime Database** → **Data** tab
2. Mở `chats` → `chat_X_Y` → `messages`
3. Click vào một tin nhắn
4. Xem field `text` có giá trị gì

**Ví dụ đúng:**
```json
{
  "sender_id": 27,
  "receiver_id": 33,
  "text": "Xin chao",  // ← Đúng
  "timestamp": "2025-11-01T14:03:00.000Z",
  "is_read": false
}
```

**Ví dụ sai:**
```json
{
  "sender_id": 27,
  "receiver_id": 33,
  "text": "BpL7xQ2Y38V1E2lZZcOPkqm...",  // ← Text bị ghi đè!
  "timestamp": "2025-11-01T14:03:00.000Z",
  "is_read": false
}
```

### Bước 3: Kiểm tra logs khi nhận tin nhắn

```
📥 [CHAT_SERVICE] Message data: {...}
📥 [CHAT_SERVICE] Parsed message: senderId=27, text="..."
```

**Kiểm tra:** Field `text` có đúng không?

---

## 🔧 Khắc phục

### Nếu text đúng trong Firebase nhưng UI hiển thị sai:

Kiểm tra `chat_bubble.dart`:
```dart
// Nội dung text
if (message.text.isNotEmpty)
  Text(
    message.text,  // ← Đảm bảo đang dùng message.text
    style: AppTextStyles.bodyMedium.copyWith(
      color: isMe ? Colors.white : AppColors.textPrimary,
    ),
  ),
```

### Nếu Firebase đang lưu sai text:

Kiểm tra `chat_detail_screen.dart`:
```dart
Future<void> _sendMessage() async {
  if (_messageController.text.trim().isEmpty || _currentUserId == null) {
    return;
  }

  final text = _messageController.text.trim();
  print('📤 [CHAT_DETAIL] Sending message: "$text"');  // ← Kiểm tra log
  
  _messageController.clear();

  try {
    await _chatService.sendMessage(
      _currentUserId!,
      widget.match.userId,
      text,  // ← Đảm bảo gửi đúng text
    );
```

### Nếu vẫn không fix được:

**Xóa dữ liệu cũ trong Firebase:**
1. Vào Firebase Console → Data
2. Xóa toàn bộ `chats` node
3. Gửi tin nhắn mới
4. Kiểm tra lại

---

## 🎨 Cải tiến UI đã thêm

### 1. Hiển thị tên người gửi

Đã thêm label "ID: {senderId}" ở trên bubble của người khác:

```
      ID: 33
┌─────────────┐
│ Hello!      │
│   10:30     │
└─────────────┘
```

Code:
```dart
// Tên người gửi (chỉ hiển thị cho tin nhắn của người khác)
if (!isMe)
  Padding(
    padding: const EdgeInsets.only(left: 12, bottom: 4),
    child: Text(
      'ID: ${message.senderId}',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
```

### 2. Cải thiện debug logs

Thêm logs chi tiết để theo dõi data flow:
```dart
print('📥 [CHAT_SERVICE] Message data: $messageData');
print('📥 [CHAT_SERVICE] Parsed message: senderId=${message.senderId}, text="${message.text}"');
```

---

## 📝 Test Case

### Test 1: Gửi tin nhắn mới
1. Login vào app
2. Vào Chat → Chọn một match
3. Gửi tin nhắn: "Hello from debug"
4. Kiểm tra logs:
   ```
   📤 Sending message: "Hello from debug"
   🔥 Message data: {text: Hello from debug, ...}
   ✅ Message pushed to Firebase
   ```
5. Kiểm tra UI: Tin nhắn hiển thị "Hello from debug" chứ không phải ID

### Test 2: Xem Firebase Console
1. Vào Firebase Console → Data
2. Mở message vừa gửi
3. Verify field `text` = "Hello from debug"

### Test 3: Nhận tin nhắn
1. Người khác gửi tin nhắn
2. Tin nhắn xuất hiện bên trái với label "ID: X"
3. Nội dung đúng, không phải ID

---

## 🚨 Cảnh báo

### Nếu text vẫn hiển thị ID:

**Có thể do đâu đó trong code đang:**
1. Ghi đè `text` bằng `userId`
2. Hoặc truyền sai tham số vào `sendMessage()`
3. Hoặc parse JSON sai

**Solution:**
- Xem toàn bộ logs từ lúc gửi đến lúc nhận
- So sánh data trong Firebase vs data hiển thị trên UI
- Tìm điểm data bị thay đổi

---

## ✅ Expected Result

Sau khi fix:

### Tin nhắn của mình (bên phải):
```
                    ┌─────────────────┐
                    │ Xin chao        │
                    │        14:03 ✓✓ │
                    └─────────────────┘
                    (gradient hồng)
```

### Tin nhắn người khác (bên trái):
```
      ID: 33
┌─────────────────┐
│ HUTECH          │
│ 14:34           │
└─────────────────┘
(màu xám)
```

### NOT like this:
```
❌ BpL7xQ2Y38V1E2lZZcOPkqm...
❌ BxJj62nE1XQa2bu3UE8XEv97...
```

---

## 🎯 Action Items

- [ ] Kiểm tra logs khi gửi tin nhắn
- [ ] Verify data trong Firebase Console
- [ ] Kiểm tra logs khi nhận tin nhắn
- [ ] So sánh data với UI hiển thị
- [ ] Xóa data cũ nếu cần
- [ ] Test lại với tin nhắn mới
- [ ] Verify UI hiển thị đúng content

---

**Hot restart app và test lại!** 🔥
