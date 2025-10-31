import 'package:flutter/material.dart';
import '../model/match.dart';
import '../config/app_theme.dart';

// Widget hiển thị card của một match trong danh sách chat với thiết kế hiện đại
class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap; // Callback khi nhấn vào để mở chat

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: match.hasUnreadMessages
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: match.hasUnreadMessages
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.divider,
          width: 1,
        ),
        boxShadow: match.hasUnreadMessages ? AppShadows.small : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar với online status và unread badge
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: match.hasUnreadMessages
                            ? AppColors.primaryGradient
                            : null,
                        border: !match.hasUnreadMessages
                            ? Border.all(color: AppColors.divider, width: 2)
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.surface,
                        backgroundImage: match.avatar.isNotEmpty
                            ? NetworkImage(match.avatar)
                            : null,
                        child: match.avatar.isEmpty
                            ? Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                                size: AppIconSize.md,
                              )
                            : null,
                      ),
                    ),

                    // Badge hiển thị số tin nhắn chưa đọc
                    if (match.hasUnreadMessages)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cardBackground,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                    // Online status indicator (optional - có thể thêm logic online/offline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBackground,
                            width: 2,
                          ),
                        ),
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
                        '${match.name}, ${match.age}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: match.hasUnreadMessages
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.lastMessage ?? 'Bắt đầu trò chuyện...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: match.hasUnreadMessages
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: match.hasUnreadMessages
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

                // Thời gian tin nhắn cuối
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
                        color: match.hasUnreadMessages
                            ? AppColors.primary.withOpacity(0.1)
                            : null,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        _formatTime(match.lastMessageTime),
                        style: AppTextStyles.caption.copyWith(
                          color: match.hasUnreadMessages
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: match.hasUnreadMessages
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (match.hasUnreadMessages) ...[
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
  }

  // Format thời gian hiển thị
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
