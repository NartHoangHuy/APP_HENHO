import 'package:firebase_database/firebase_database.dart';
import '../model/message.dart';

// Service xử lý chat realtime bằng Firebase Realtime Database
class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Lấy reference đến phòng chat giữa 2 người
  // Room ID được tạo theo pattern: "chat_{userId1}_{userId2}" (userId nhỏ hơn đứng trước)
  String _getChatRoomId(int userId1, int userId2) {
    final ids = [userId1, userId2]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  // Gửi tin nhắn
  Future<void> sendMessage(
    int senderId,
    int receiverId,
    String text, {
    String? imageUrl,
  }) async {
    try {
      final roomId = _getChatRoomId(senderId, receiverId);
      final messagesRef = _database.child('chats/$roomId/messages');

      final message = Message(
        id: '', // Firebase sẽ tự động tạo key
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
      );

      // Push message vào Firebase (auto-generate key)
      await messagesRef.push().set(message.toJson());

      // Cập nhật thông tin phòng chat (last message, timestamp)
      await _database.child('chats/$roomId/info').update({
        'last_message': text,
        'last_message_time': message.timestamp.toIso8601String(),
        'last_sender_id': senderId,
      });
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  // Lắng nghe tin nhắn realtime
  Stream<List<Message>> getMessages(int userId1, int userId2) {
    final roomId = _getChatRoomId(userId1, userId2);
    final messagesRef = _database.child('chats/$roomId/messages');

    return messagesRef.orderByChild('timestamp').onValue.map((event) {
      final messages = <Message>[];
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value as Map);
          messages.add(Message.fromJson(key, messageData));
        });
      }
      // Sắp xếp theo thời gian tăng dần
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Đánh dấu tất cả tin nhắn là đã đọc
  Future<void> markMessagesAsRead(int currentUserId, int otherUserId) async {
    try {
      final roomId = _getChatRoomId(currentUserId, otherUserId);
      final messagesRef = _database.child('chats/$roomId/messages');

      // Lấy tất cả tin nhắn chưa đọc từ người kia gửi
      final snapshot = await messagesRef
          .orderByChild('receiver_id')
          .equalTo(currentUserId)
          .get();

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final updates = <String, dynamic>{};

        data.forEach((key, value) {
          final msg = Map<String, dynamic>.from(value as Map);
          if (msg['is_read'] == false) {
            updates['$key/is_read'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await messagesRef.update(updates);
        }
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Xóa tin nhắn
  Future<void> deleteMessage(int userId1, int userId2, String messageId) async {
    try {
      final roomId = _getChatRoomId(userId1, userId2);
      await _database.child('chats/$roomId/messages/$messageId').remove();
    } catch (e) {
      print('Error deleting message: $e');
      throw e;
    }
  }

  // Lấy số lượng tin nhắn chưa đọc
  Future<int> getUnreadCount(int currentUserId, int otherUserId) async {
    try {
      final roomId = _getChatRoomId(currentUserId, otherUserId);
      final messagesRef = _database.child('chats/$roomId/messages');

      final snapshot = await messagesRef
          .orderByChild('receiver_id')
          .equalTo(currentUserId)
          .get();

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int count = 0;
        data.forEach((key, value) {
          final msg = Map<String, dynamic>.from(value as Map);
          if (msg['is_read'] == false) count++;
        });
        return count;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
