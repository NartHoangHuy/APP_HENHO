import 'package:flutter/material.dart';
import '../model/like.dart';
import '../config/app_theme.dart';

// Widget hiển thị card của một người đã thích bạn với thiết kế hiện đại
class LikeCard extends StatelessWidget {
  final Like like;
  final VoidCallback onLikeBack; // Callback khi nhấn "Thích lại"
  final VoidCallback onIgnore; // Callback khi nhấn "Bỏ qua"
  final VoidCallback onTap; // Callback khi nhấn vào card

  const LikeCard({
    super.key,
    required this.like,
    required this.onLikeBack,
    required this.onIgnore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        boxShadow: AppShadows.small,
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
                // Avatar với gradient border và heart icon
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.surface,
                        backgroundImage: like.avatar.isNotEmpty
                            ? NetworkImage(like.avatar)
                            : null,
                        child: like.avatar.isEmpty
                            ? Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                                size: AppIconSize.lg,
                              )
                            : null,
                      ),
                    ),
                    // Heart badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBackground,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên và tuổi
                      Text(
                        '${like.name}, ${like.age}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Khoảng cách
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: AppIconSize.sm,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cách bạn ${like.distanceKm.toStringAsFixed(1)} km',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Các nút hành động
                      Row(
                        children: [
                          // Nút Thích lại
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                boxShadow: AppShadows.small,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onLikeBack,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.favorite_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Thích lại',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),

                          // Nút Bỏ qua
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onIgnore,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
