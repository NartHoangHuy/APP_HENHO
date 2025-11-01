import 'package:firebase_database/firebase_database.dart';
import '../model/message.dart';

// Service xử lý chat realtime bằng Firebase Realtime Database
class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Lấy reference đến phòng chat giữa 2 người
  // Room ID được tạo theo pattern: "chat_{userId1}_{userId2}" (userId nhỏ hơn đứng trước)
  // CRITICAL: IDs are ALWAYS sorted so BOTH users get SAME room ID
  String _getChatRoomId(int userId1, int userId2) {
    // VALIDATION: Ensure not chatting with self
    if (userId1 == userId2) {
      throw Exception('Cannot create chat room with same user ID: $userId1');
    }

    final ids = [userId1, userId2]..sort();
    final roomId = 'chat_${ids[0]}_${ids[1]}';

    print('🔑 [CHAT_SERVICE] Room ID calculation:');
    print('   Input: userId1=$userId1, userId2=$userId2');
    print('   Sorted: [${ids[0]}, ${ids[1]}]');
    print('   Result: $roomId');

    return roomId;
  }

  // Gửi tin nhắn
  Future<void> sendMessage(
    int senderId,
    int receiverId,
    String text, {
    String? imageUrl,
  }) async {
    print('');
    print('╔═══════════════════════════════════════════════════╗');
    print('║         SENDING MESSAGE TO FIREBASE               ║');
    print('╚═══════════════════════════════════════════════════╝');
    print('📤 FROM: User $senderId');
    print('📤 TO: User $receiverId');
    print('📤 TEXT: "$text"');

    // CRITICAL VALIDATION
    if (senderId == receiverId) {
      throw Exception('Cannot send message to self! User ID: $senderId');
    }

    if (text.trim().isEmpty) {
      throw Exception('Cannot send empty message');
    }

    try {
      final roomId = _getChatRoomId(senderId, receiverId);
      print('� ROOM: $roomId');
      print('� PATH: chats/$roomId/messages');

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

      final messageJson = message.toJson();
      print('📤 DATA: $messageJson');

      // Push message vào Firebase (auto-generate key)
      final newMessageRef = await messagesRef.push();
      final messageId = newMessageRef.key!;

      await newMessageRef.set(messageJson);

      print('✅ Message saved to Firebase!');
      print('   Message ID: $messageId');
      print('   Full path: chats/$roomId/messages/$messageId');

      // Cập nhật thông tin phòng chat (last message, timestamp)
      await _database.child('chats/$roomId/info').update({
        'last_message': text,
        'last_message_time': message.timestamp.toIso8601String(),
        'last_sender_id': senderId,
      });

      print('✅ Chat info updated');
      print('╚═══════════════════════════════════════════════════╝');
      print('');
    } catch (e) {
      print('❌❌❌ ERROR SENDING MESSAGE: $e');
      print('❌ Stack: ${StackTrace.current}');
      rethrow;
    }
  }

  // Lắng nghe tin nhắn realtime
  Stream<List<Message>> getMessages(int userId1, int userId2) {
    final roomId = _getChatRoomId(userId1, userId2);
    print('');
    print('═══════════════════════════════════════════════════');
    print('🔥🔥🔥 [CHAT_SERVICE] CREATING NEW STREAM LISTENER');
    print('🔥 USER: $userId1');
    print('🔥 CHAT WITH: $userId2');
    print('🔥 ROOM ID: $roomId');
    print('🔥 FIREBASE PATH: chats/$roomId/messages');
    print('═══════════════════════════════════════════════════');
    print('');

    final messagesRef = _database.child('chats/$roomId/messages');

    // Use onValue for real-time updates without ordering constraint
    // We'll sort in memory instead
    return messagesRef.onValue
        .map((event) {
          final now = DateTime.now();
          print('');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('📥📥📥 [CHAT_SERVICE] ⚡ STREAM TRIGGERED ⚡');
          print('📥 For User: $userId1');
          print('📥 Room: $roomId');
          print('📥 Time: $now');
          print('📥 Event type: ${event.type}');
          print('📥 Snapshot exists: ${event.snapshot.exists}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          final messages = <Message>[];
          if (event.snapshot.value != null) {
            try {
              final data = event.snapshot.value as Map<dynamic, dynamic>;
              print('📥 Found ${data.length} raw messages in Firebase');
              print(
                '📥 Will validate messages for conversation: $userId1 ↔ $userId2',
              );
              print('');

              int validCount = 0;
              int invalidCount = 0;

              data.forEach((key, value) {
                try {
                  final messageData = Map<String, dynamic>.from(value as Map);
                  final senderId = messageData['sender_id'] as int;
                  final receiverId = messageData['receiver_id'] as int;
                  final text = messageData['text'] ?? '';

                  // STRICT VALIDATION: Chỉ chấp nhận messages giữa 2 users này
                  final isValidMessage =
                      (senderId == userId1 && receiverId == userId2) ||
                      (senderId == userId2 && receiverId == userId1);

                  if (!isValidMessage) {
                    invalidCount++;
                    print(
                      '⚠️ SKIP message $key: $senderId→$receiverId "$text" (not part of $userId1↔$userId2)',
                    );
                    return; // Skip this message
                  }

                  validCount++;
                  final message = Message.fromJson(key.toString(), messageData);
                  messages.add(message);
                  print('✅ VALID message $key: $senderId→$receiverId "$text"');
                } catch (e) {
                  print('❌ ERROR parsing message $key: $e');
                }
              });

              print('');
              print(
                '📊 Summary: $validCount valid, $invalidCount invalid (skipped)',
              );
            } catch (e) {
              print('❌ ERROR processing snapshot: $e');
            }
          } else {
            print('� No messages yet in room $roomId');
          }

          // Sắp xếp theo thời gian tăng dần
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          print('');
          print('� Returning ${messages.length} messages to User $userId1');
          if (messages.isNotEmpty) {
            print(
              '   First: ${messages.first.senderId}→${messages.first.receiverId}: "${messages.first.text}"',
            );
            print(
              '   Last: ${messages.last.senderId}→${messages.last.receiverId}: "${messages.last.text}"',
            );
          }
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('');

          return messages;
        })
        .handleError((error) {
          print('❌❌❌ [CHAT_SERVICE] Stream error for User $userId1: $error');
          return <Message>[];
        });
  }

  // Đánh dấu tất cả tin nhắn là đã đọc
  Future<void> markMessagesAsRead(int currentUserId, int otherUserId) async {
    try {
      final roomId = _getChatRoomId(currentUserId, otherUserId);
      print('✅ [CHAT_SERVICE] Marking messages as read in room: $roomId');
      print(
        '✅ [CHAT_SERVICE] Current user: $currentUserId, Other user: $otherUserId',
      );

      final messagesRef = _database.child('chats/$roomId/messages');

      // Lấy tất cả tin nhắn chưa đọc từ người kia gửi
      final snapshot = await messagesRef
          .orderByChild('receiver_id')
          .equalTo(currentUserId)
          .get();

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final updates = <String, dynamic>{};
        int validatedCount = 0;
        int skippedCount = 0;

        data.forEach((key, value) {
          final msg = Map<String, dynamic>.from(value as Map);
          final senderId = msg['sender_id'] as int;
          final receiverId = msg['receiver_id'] as int;

          // VALIDATION: Chỉ mark read messages từ otherUserId gửi cho currentUserId
          if (senderId == otherUserId && receiverId == currentUserId) {
            if (msg['is_read'] == false) {
              updates['$key/is_read'] = true;
              validatedCount++;
            }
          } else {
            print(
              '⚠️ [CHAT_SERVICE] Skipping message $key: from $senderId to $receiverId (not from $otherUserId to $currentUserId)',
            );
            skippedCount++;
          }
        });

        if (updates.isNotEmpty) {
          await messagesRef.update(updates);
          print(
            '✅ [CHAT_SERVICE] Marked $validatedCount messages as read (skipped $skippedCount)',
          );
        } else {
          print('✅ [CHAT_SERVICE] No unread messages to mark');
        }
      }
    } catch (e) {
      print('❌ [CHAT_SERVICE] Error marking messages as read: $e');
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

  // Lấy số lượng tin nhắn chưa đọc (realtime stream)
  Stream<int> getUnreadCountStream(int currentUserId, int otherUserId) {
    final roomId = _getChatRoomId(currentUserId, otherUserId);
    final messagesRef = _database.child('chats/$roomId/messages');

    return messagesRef
        .orderByChild('receiver_id')
        .equalTo(currentUserId)
        .onValue
        .map((event) {
          if (event.snapshot.value != null) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            int count = 0;
            data.forEach((key, value) {
              final msg = Map<String, dynamic>.from(value as Map);
              final senderId = msg['sender_id'] as int;
              final receiverId = msg['receiver_id'] as int;

              // VALIDATION: Chỉ đếm messages từ otherUserId gửi cho currentUserId
              if (senderId == otherUserId &&
                  receiverId == currentUserId &&
                  msg['is_read'] == false) {
                count++;
              }
            });
            return count;
          }
          return 0;
        });
  }

  // Lấy số lượng tin nhắn chưa đọc (one-time)
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
          final senderId = msg['sender_id'] as int;
          final receiverId = msg['receiver_id'] as int;

          // VALIDATION: Chỉ đếm messages từ otherUserId gửi cho currentUserId
          if (senderId == otherUserId &&
              receiverId == currentUserId &&
              msg['is_read'] == false) {
            count++;
          }
        });
        return count;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Lấy thông tin phòng chat (last message, timestamp)
  Stream<Map<String, dynamic>?> getChatInfo(int userId1, int userId2) {
    final roomId = _getChatRoomId(userId1, userId2);
    final infoRef = _database.child('chats/$roomId/info');

    return infoRef.onValue.map((event) {
      if (event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }
}
