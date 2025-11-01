import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/message.dart';
import '../../model/match.dart';
import '../../service/chat_service.dart';
import '../../widgets/chat_bubble.dart';

// Màn hình chat chi tiết giữa 2 người
class ChatDetailScreen extends StatefulWidget {
  final Match match;

  const ChatDetailScreen({super.key, required this.match});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _currentUserId;
  Stream<List<Message>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    print('🔥🔥🔥 [CHAT_DETAIL] ===== INITIALIZING CHAT DETAIL =====');
    print('🔥🔥🔥 [CHAT_DETAIL] Match object details:');
    print('🔥🔥🔥 [CHAT_DETAIL]   - match.id: ${widget.match.id}');
    print('🔥🔥🔥 [CHAT_DETAIL]   - match.userId: ${widget.match.userId}');
    print('🔥🔥🔥 [CHAT_DETAIL]   - match.name: ${widget.match.name}');
    print('🔥🔥🔥 [CHAT_DETAIL]   - match.age: ${widget.match.age}');

    final prefs = await SharedPreferences.getInstance();

    // Try to get user_id from SharedPreferences first
    int? userId = prefs.getInt('user_id');

    // If not found, get from profile API
    if (userId == null) {
      print(
        '⚠️ [CHAT_DETAIL] user_id not in SharedPreferences, fetching from API...',
      );
      final token = prefs.getString('token');
      if (token != null) {
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
            userId = data['id'];
            // Save for next time
            await prefs.setInt('user_id', userId!);
            print('✅ [CHAT_DETAIL] Got user_id from API: $userId');
            print('✅ [CHAT_DETAIL] Profile data: $data');
          }
        } catch (e) {
          print('❌ [CHAT_DETAIL] Error fetching profile: $e');
        }
      }
    } else {
      print('✅ [CHAT_DETAIL] Got user_id from SharedPreferences: $userId');
    }

    print('🔥🔥🔥 [CHAT_DETAIL] ===== USER VERIFICATION =====');
    print('🔥🔥🔥 [CHAT_DETAIL] THIS USER ID: $userId (ME)');
    print(
      '🔥🔥🔥 [CHAT_DETAIL] OTHER USER ID: ${widget.match.userId} (${widget.match.name})',
    );

    // CRITICAL VALIDATION: Ensure we're not chatting with ourselves
    if (userId == widget.match.userId) {
      print('❌❌❌ [CHAT_DETAIL] ERROR: Trying to chat with MYSELF!');
      print('❌ [CHAT_DETAIL] userId == match.userId == $userId');
      print('❌ [CHAT_DETAIL] This is a BUG in Match data!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi: Không thể chat với chính mình!')),
      );
      return;
    }

    if (userId != null) {
      final uid = userId; // Make it non-nullable

      // ⚠️ CRITICAL: Verify user IDs before creating room
      print('\n╔═══════════════════════════════════════════════════════╗');
      print('║         🔍 USER ID VERIFICATION                        ║');
      print('╚═══════════════════════════════════════════════════════╝');
      print('📱 CURRENT USER (ME):');
      print('   - user_id from SharedPreferences: $uid');
      print('   - This is MY account ID');
      print('');
      print('👤 OTHER USER (match object):');
      print('   - match.userId: ${widget.match.userId}');
      print('   - match.name: ${widget.match.name}');
      print('   - This should be the OTHER person\'s ID');
      print('');

      // Calculate expected room ID
      final ids = [uid, widget.match.userId]..sort();
      final expectedRoomId = 'chat_${ids[0]}_${ids[1]}';
      print('� ROOM CALCULATION:');
      print(
        '   - Input IDs: [$uid (ME), ${widget.match.userId} (${widget.match.name})]',
      );
      print('   - After sort: $ids');
      print('   - FINAL ROOM ID: $expectedRoomId');
      print('═══════════════════════════════════════════════════════\n');

      setState(() {
        _currentUserId = uid;
        _messagesStream = _chatService.getMessages(uid, widget.match.userId);
      });
      print('✅✅✅ [CHAT_DETAIL] Messages stream initialized successfully');
      print(
        '🔥 [CHAT_DETAIL] Stream listening to Firebase for room: $expectedRoomId',
      );

      // Đánh dấu tất cả tin nhắn là đã đọc
      await _chatService.markMessagesAsRead(uid, widget.match.userId);
      print('✅ [CHAT_DETAIL] Marked messages as read');
    } else {
      print('❌❌❌ [CHAT_DETAIL] User ID is null! Cannot initialize chat!');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Gửi tin nhắn
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) {
      print('⚠️ [CHAT_DETAIL] Cannot send: empty text or null user ID');
      return;
    }

    // CRITICAL VALIDATION: Double check we're not sending to ourselves
    if (_currentUserId == widget.match.userId) {
      print('❌❌❌ [CHAT_DETAIL] BLOCKED: Trying to send message to MYSELF!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Không thể gửi tin nhắn cho chính mình!'),
        ),
      );
      return;
    }

    final text = _messageController.text.trim();
    print('📤📤📤 [CHAT_DETAIL] ===== SENDING MESSAGE =====');
    print('📤 [CHAT_DETAIL] Text: "$text"');
    print('📤 [CHAT_DETAIL] From User ID: $_currentUserId (ME)');
    print(
      '📤 [CHAT_DETAIL] To User ID: ${widget.match.userId} (${widget.match.name})',
    );

    // Calculate room ID to verify
    final ids = [_currentUserId!, widget.match.userId]..sort();
    final roomId = 'chat_${ids[0]}_${ids[1]}';
    print('📤 [CHAT_DETAIL] Will save to room: $roomId');
    print('📤 [CHAT_DETAIL] Expected path: chats/$roomId/messages');

    _messageController.clear();

    try {
      await _chatService.sendMessage(
        _currentUserId!,
        widget.match.userId,
        text,
      );
      print('✅✅✅ [CHAT_DETAIL] Message sent successfully to Firebase!');
      print(
        '✅ [CHAT_DETAIL] User ${widget.match.userId} (${widget.match.name}) should receive this...',
      );

      // Scroll xuống cuối
      _scrollToBottom();
    } catch (e) {
      print('❌❌❌ [CHAT_DETAIL] Error sending message: $e');
      print('❌ [CHAT_DETAIL] Stack: ${StackTrace.current}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể gửi tin nhắn')));
    }
  }

  // Scroll xuống tin nhắn cuối cùng
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Build date divider
  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String label;
    if (messageDate == today) {
      label = 'Hôm nay';
    } else if (messageDate == yesterday) {
      label = 'Hôm qua';
    } else {
      label = '${date.day} Tháng ${date.month}';
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: widget.match.avatar.isNotEmpty
                  ? NetworkImage(widget.match.avatar)
                  : null,
              child: widget.match.avatar.isEmpty
                  ? const Icon(Icons.person, size: 20, color: Colors.pink)
                  : null,
            ),
            const SizedBox(width: 12),

            // Tên
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.match.name}, ${widget.match.age}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
        ],
      ),
      body: _currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Danh sách tin nhắn
                Expanded(
                  child: StreamBuilder<List<Message>>(
                    stream: _messagesStream,
                    builder: (context, snapshot) {
                      print('🖼️ [CHAT_DETAIL] StreamBuilder rebuilding...');
                      print(
                        '🖼️ [CHAT_DETAIL] Connection state: ${snapshot.connectionState}',
                      );
                      print('🖼️ [CHAT_DETAIL] Has data: ${snapshot.hasData}');
                      print(
                        '🖼️ [CHAT_DETAIL] Has error: ${snapshot.hasError}',
                      );

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print('⏳ [CHAT_DETAIL] Waiting for initial data...');
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        print(
                          '❌ [CHAT_DETAIL] Stream error: ${snapshot.error}',
                        );
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      }

                      final messages = snapshot.data ?? [];
                      print(
                        '🖼️🖼️🖼️ [CHAT_DETAIL] UI received ${messages.length} messages',
                      );

                      if (messages.isNotEmpty) {
                        print('🖼️ [CHAT_DETAIL] Messages:');
                        for (var msg in messages) {
                          print(
                            '   - From ${msg.senderId} to ${msg.receiverId}: "${msg.text}"',
                          );
                        }
                      }

                      if (messages.isEmpty) {
                        print('📭 [CHAT_DETAIL] No messages to display');
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Chưa có tin nhắn nào',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hãy bắt đầu cuộc trò chuyện!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Scroll xuống cuối khi có tin nhắn mới
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == _currentUserId;

                          // EXTRA VALIDATION: Đảm bảo message thuộc conversation này
                          final isValidMessage =
                              (message.senderId == _currentUserId &&
                                  message.receiverId == widget.match.userId) ||
                              (message.senderId == widget.match.userId &&
                                  message.receiverId == _currentUserId);

                          if (!isValidMessage) {
                            print(
                              '⚠️⚠️⚠️ [CHAT_DETAIL UI] INVALID MESSAGE IN UI!',
                            );
                            print(
                              '⚠️ Expected: between $_currentUserId and ${widget.match.userId}',
                            );
                            print(
                              '⚠️ Got: from ${message.senderId} to ${message.receiverId}',
                            );
                            // Skip rendering this message
                            return const SizedBox.shrink();
                          }

                          // Kiểm tra xem có cần hiển thị date divider không
                          bool showDateDivider = false;
                          if (index == 0) {
                            showDateDivider = true;
                          } else {
                            final previousMessage = messages[index - 1];
                            final currentDate = DateTime(
                              message.timestamp.year,
                              message.timestamp.month,
                              message.timestamp.day,
                            );
                            final previousDate = DateTime(
                              previousMessage.timestamp.year,
                              previousMessage.timestamp.month,
                              previousMessage.timestamp.day,
                            );
                            showDateDivider = currentDate != previousDate;
                          }

                          return Column(
                            children: [
                              if (showDateDivider)
                                _buildDateDivider(message.timestamp),
                              ChatBubble(message: message, isMe: isMe),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                // Ô nhập tin nhắn
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Nút đính kèm
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.pinkAccent,
                          onPressed: () {
                            // TODO: Implement attach image
                          },
                        ),

                        // TextField nhập tin nhắn
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Nhập tin nhắn...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Nút gửi
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.pinkAccent,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            color: Colors.white,
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
