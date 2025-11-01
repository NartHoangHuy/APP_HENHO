import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/match.dart';
import '../config/app_theme.dart';
import '../service/chat_service.dart';
import 'unread_badge.dart';

/// Widget hiển thị card của một match với realtime unread count
class RealtimeMatchCard extends StatefulWidget {
  final Match match;
  final VoidCallback onTap;

  const RealtimeMatchCard({
    super.key,
    required this.match,
    required this.onTap,
  });

  @override
  State<RealtimeMatchCard> createState() => _RealtimeMatchCardState();
}

class _RealtimeMatchCardState extends State<RealtimeMatchCard> {
  final ChatService _chatService = ChatService();
  int? _currentUserId;
  Stream<int>? _unreadCountStream;
  Stream<Map<String, dynamic>?>? _chatInfoStream;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    // If not found, get from profile API
    if (userId == null) {
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
            final fetchedUserId = data['id'] as int;

            print('\n╔═══════════════════════════════════════════════╗');
            print('║   💾 SAVING USER ID (MATCH CARD)             ║');
            print('╚═══════════════════════════════════════════════╝');
            print('📱 Profile API Response:');
            print('   - user_id: $fetchedUserId');
            print('   - username: ${data['username']}');
            print('✅ SAVED: user_id = $fetchedUserId');
            print('═══════════════════════════════════════════════\n');

            userId = fetchedUserId;
            await prefs.setInt('user_id', fetchedUserId);
          }
        } catch (e) {
          print('❌ Error fetching profile for match card: $e');
        }
      }
    }

    if (userId != null && mounted) {
      final uid = userId; // Create non-nullable local variable
      setState(() {
        _currentUserId = uid;
        _unreadCountStream = _chatService.getUnreadCountStream(
          uid,
          widget.match.userId,
        );
        _chatInfoStream = _chatService.getChatInfo(uid, widget.match.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unreadCountStream,
      initialData: 0,
      builder: (context, unreadSnapshot) {
        final unreadCount = unreadSnapshot.data ?? 0;
        final hasUnread = unreadCount > 0;

        return StreamBuilder<Map<String, dynamic>?>(
          stream: _chatInfoStream,
          builder: (context, chatInfoSnapshot) {
            // Update last message from Firebase if available
            String? lastMessage = widget.match.lastMessage;
            DateTime? lastMessageTime = widget.match.lastMessageTime;

            if (chatInfoSnapshot.hasData && chatInfoSnapshot.data != null) {
              final chatInfo = chatInfoSnapshot.data!;
              lastMessage = chatInfo['last_message'] ?? lastMessage;
              if (chatInfo['last_message_time'] != null) {
                lastMessageTime = DateTime.parse(chatInfo['last_message_time']);
              }
            }

            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: hasUnread
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: hasUnread
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.divider,
                  width: 1,
                ),
                boxShadow: hasUnread ? AppShadows.small : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: hasUnread
                                    ? AppColors.primaryGradient
                                    : null,
                                border: !hasUnread
                                    ? Border.all(
                                        color: AppColors.divider,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.surface,
                                backgroundImage: widget.match.avatar.isNotEmpty
                                    ? NetworkImage(widget.match.avatar)
                                    : null,
                                child: widget.match.avatar.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color: AppColors.textSecondary,
                                        size: AppIconSize.md,
                                      )
                                    : null,
                              ),
                            ),

                            // Unread badge
                            if (unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: UnreadBadge(
                                  count: unreadCount,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Tên và tin nhắn cuối
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.match.name}, ${widget.match.age}',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: hasUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lastMessage ?? 'Bắt đầu trò chuyện...',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: hasUnread
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Thời gian
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: hasUnread
                                    ? AppColors.primary.withOpacity(0.1)
                                    : null,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                _formatTime(lastMessageTime),
                                style: AppTextStyles.caption.copyWith(
                                  color: hasUnread
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: hasUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(height: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Vừa xong';
    }
  }
}
