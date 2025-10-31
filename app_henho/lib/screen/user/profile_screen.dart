import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/auth_service.dart';
import '../../model/user_profile.dart';
import '../../config/app_theme.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔍 Loading profile with token: $token');

    if (token != null) {
      final profile = await AuthService().getProfile(token);
      print('👤 Profile loaded: ${profile?.username}');
      print('🖼️ Avatar URL: ${profile?.avatarUrl}');
      print('📷 Avatar field: ${profile?.avatar}');

      if (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty) {
        print('✅ Will display avatar from: ${profile.avatarUrl}');
      } else {
        print('⚠️ No avatar URL available');
      }

      setState(() {
        _profile = profile;
      });
    } else {
      print('❌ No token found in SharedPreferences');
    }
  }

  int _calculateProfileCompletion() {
    if (_profile == null) return 0;

    int completedFields = 0;
    int totalFields = 8;

    if (_profile!.username.isNotEmpty) completedFields++;
    if (_profile!.email.isNotEmpty) completedFields++;
    if (_profile!.bio != null && _profile!.bio!.isNotEmpty) completedFields++;
    if (_profile!.birthday != null) completedFields++;
    if (_profile!.gender != null && _profile!.gender!.isNotEmpty)
      completedFields++;
    if (_profile!.location != null && _profile!.location!.isNotEmpty)
      completedFields++;
    if (_profile!.hobbies != null && _profile!.hobbies!.isNotEmpty)
      completedFields++;
    if (_profile!.avatar != null && _profile!.avatar!.isNotEmpty)
      completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  String _formatUpdatedTime() {
    if (_profile?.updatedAt == null) return 'Chưa cập nhật';

    final updatedAt = _profile!.updatedAt!;
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(updatedAt);
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final name = _profile!.username;
    final gender = _profile!.gender == 'male'
        ? 'Nam'
        : _profile!.gender == 'female'
        ? 'Nữ'
        : _profile!.gender == 'other'
        ? 'Khác'
        : '';
    final info = '${_profile!.birthday ?? ''}, $gender';
    final email = _profile!.email;
    final bio = _profile!.displayBio;
    final location = _profile!.displayLocation;
    final age = _profile!.age?.toString() ?? '0';
    final hobbies = _profile!.hobbies ?? 'Chưa có sở thích';
    final profileCompletion = _calculateProfileCompletion();
    final lastUpdated = _formatUpdatedTime();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          // Profile Header với gradient
          SliverToBoxAdapter(
            child: _buildProfileHeader(name, info, location, age),
          ),

          // Profile Info Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildProfileCompletionCard(profileCompletion, lastUpdated),
                  const SizedBox(height: 16),
                  _buildInfoCard(email, bio, hobbies),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                  const SizedBox(height: 24), // Extra bottom padding for scroll
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    String name,
    String info,
    String location,
    String age,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          // Avatar với gradient ring
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: AppShadows.large,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.surface,
              backgroundImage:
                  (_profile?.avatarUrl != null &&
                      _profile!.avatarUrl!.isNotEmpty)
                  ? NetworkImage(_profile!.avatarUrl!) as ImageProvider
                  : null,
              onBackgroundImageError:
                  (_profile?.avatarUrl != null &&
                      _profile!.avatarUrl!.isNotEmpty)
                  ? (exception, stackTrace) {
                      print('❌ Error loading avatar: $exception');
                    }
                  : null,
              child:
                  (_profile?.avatarUrl == null || _profile!.avatarUrl!.isEmpty)
                  ? Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tên
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              name,
              style: AppTextStyles.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (info.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              info,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Location và Age tags
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(Icons.location_on_rounded, location),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(Icons.cake_rounded, '$age tuổi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.round),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.sm, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(int completion, String lastUpdated) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hoàn thiện hồ sơ',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                  boxShadow: AppShadows.small,
                ),
                child: Text(
                  '$completion%',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.round),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Cập nhật: $lastUpdated',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (completion < 100) ...[
                const SizedBox(width: 8),
                Text(
                  'Thiếu ${100 - completion}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String email, String bio, String hobbies) {
    final gender = _profile!.gender == 'male'
        ? 'Nam 👨'
        : _profile!.gender == 'female'
        ? 'Nữ 👩'
        : _profile!.gender == 'other'
        ? 'Khác 🧑'
        : 'Chưa cập nhật';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(Icons.email_rounded, 'Email', email),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.wc_rounded, 'Giới tính', gender),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.info_rounded, 'Giới thiệu', bio),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.favorite_rounded, 'Sở thích', hobbies),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.15),
                AppColors.accent.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: AppIconSize.md, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Edit Profile Button
        Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.medium,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                // Chỉ reload nếu edit thành công
                if (result == true) {
                  print('🔄 Reloading profile after successful edit...');
                  _loadProfile();
                }
              },
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Chỉnh sửa hồ sơ',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Logout Button
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLogoutDialog(context),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Đăng xuất',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.logout_rounded, color: AppColors.error),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Đăng xuất',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: Text(
                'Đăng xuất',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
