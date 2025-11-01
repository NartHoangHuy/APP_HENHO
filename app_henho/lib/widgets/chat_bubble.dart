import 'package:flutter/material.dart';
import '../model/message.dart';
import '../config/app_theme.dart';

// Widget hiển thị một tin nhắn chat (bubble) với thiết kế hiện đại
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe; // Tin nhắn của mình hay người khác

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
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

            // Bubble với gradient và shadow
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                // Tin nhắn của mình: gradient hồng
                // Tin nhắn người khác: màu xám nhạt
                gradient: isMe ? AppColors.primaryGradient : null,
                color: isMe ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.sm),
                  topRight: Radius.circular(isMe ? AppRadius.sm : AppRadius.lg),
                  bottomLeft: Radius.circular(
                    isMe ? AppRadius.lg : AppRadius.sm,
                  ),
                  bottomRight: Radius.circular(
                    isMe ? AppRadius.sm : AppRadius.lg,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh đính kèm (nếu có)
                  if (message.imageUrl != null &&
                      message.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(
                        message.imageUrl!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 150,
                            color: AppColors.surface,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.textSecondary,
                              size: AppIconSize.lg,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  // Nội dung text
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isMe ? Colors.white : AppColors.textPrimary,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xs / 2),

                  // Thời gian và trạng thái đã đọc
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: isMe
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message.isRead
                              ? AppColors.success
                              : Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format thời gian hiển thị (HH:mm)

  // Format thời gian hiển thị (HH:mm)
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
