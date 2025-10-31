import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../model/candidate.dart';
import '../config/app_theme.dart';

// Widget hiển thị thẻ profile của một ứng viên trong tính năng swipe
// Thiết kế hiện đại với gradient, shadow đẹp, và layout hấp dẫn
class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final CardSwiperController controller;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: AppColors.primaryGradient,
        boxShadow: AppShadows.card,
      ),
      child: Container(
        margin: const EdgeInsets.all(2), // Border gradient effect
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: AppColors.cardBackground,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              // Background pattern (optional decorative element)
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.accent.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Avatar với gradient border
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: AppShadows.medium,
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: AppColors.surface,
                      backgroundImage: candidate.avatar.isNotEmpty
                          ? NetworkImage(candidate.avatar)
                          : null,
                      child: candidate.avatar.isEmpty
                          ? Icon(
                              Icons.person,
                              size: AppIconSize.xl * 1.5,
                              color: AppColors.textSecondary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Tên và tuổi với gradient text effect
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        '${candidate.name}, ${candidate.age}',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Địa điểm và khoảng cách với icon đẹp hơn
                  if (candidate.location != null ||
                      candidate.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.round),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (candidate.location != null) ...[
                              Icon(
                                Icons.location_on_rounded,
                                size: AppIconSize.sm,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  candidate.location!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (candidate.distanceKm != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${candidate.distanceKm!.toStringAsFixed(1)} km',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Bio với style đẹp hơn
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      candidate.bio,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Sở thích với gradient chips
                  if (candidate.hobbies != null &&
                      candidate.hobbies!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: candidate.hobbies!.take(4).map((hobby) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.accent.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.round,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              hobby,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Nút hành động với thiết kế hiện đại
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        // Nút Bỏ qua (Dislike)
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.close_rounded,
                            label: 'Bỏ qua',
                            gradient: LinearGradient(
                              colors: [AppColors.surface, AppColors.surface],
                            ),
                            textColor: AppColors.error,
                            onPressed: () {
                              controller.swipe(CardSwiperDirection.left);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nút Thích (Like)
                        Expanded(
                          flex: 2,
                          child: _ActionButton(
                            icon: Icons.favorite_rounded,
                            label: 'Kết nối',
                            gradient: AppColors.primaryGradient,
                            textColor: Colors.white,
                            onPressed: () {
                              controller.swipe(CardSwiperDirection.right);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget nút hành động với hiệu ứng gradient và animation
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.textColor,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.medium,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTextStyles.button.copyWith(color: widget.textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
