import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../service/auth_service.dart';
import '../../model/user_profile.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_profile_card.dart';
import '../../widgets/modern_widgets.dart';
import 'edit_profile_screen.dart';
import '../login_screen.dart';

class ModernProfileScreen extends StatefulWidget {
  const ModernProfileScreen({super.key});

  @override
  State<ModernProfileScreen> createState() => _ModernProfileScreenState();
}

class _ModernProfileScreenState extends State<ModernProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final profile = await AuthService().getProfile(token);
        print('👤 Profile loaded: ${profile?.username}');
        print('🖼️ Avatar URL: ${profile?.avatarUrl}');

        if (mounted) {
          setState(() {
            _profile = profile;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calculateProfileCompletion() {
    if (_profile == null) return 0;

    int completedFields = 0;
    const int totalFields = 8;

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
    if (_profile!.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty)
      completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  String _getGenderDisplay() {
    if (_profile?.gender == 'male') return 'Nam 👨';
    if (_profile?.gender == 'female') return 'Nữ 👩';
    if (_profile?.gender == 'other') return 'Khác 🧑';
    return '';
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();

      // 🔥 CRITICAL FIX: Clear all data including user_id to prevent confusion!
      print('🔥 [LOGOUT] Clearing all SharedPreferences data...');
      await prefs.clear();
      print('✅ [LOGOUT] Cleared all user data including user_id');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.background,
              ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Không thể tải profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final completion = _calculateProfileCompletion();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Profile Card
                ModernProfileCard(
                  imageUrl: _profile!.avatarUrl,
                  name: '${_profile!.username}, ${_profile!.age ?? '?'}',
                  subtitle:
                      '${_getGenderDisplay()} • ${_profile!.location ?? 'Chưa cập nhật'}',
                  actions: [
                    ActionButton(
                      icon: Icons.edit_rounded,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadProfile();
                        }
                      },
                    ),
                    ActionButton(
                      icon: Icons.logout_rounded,
                      onPressed: _logout,
                      color: AppColors.error,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Profile Completion
                _buildCompletionCard(completion),

                const SizedBox(height: 16),

                // About Section
                if (_profile!.bio != null && _profile!.bio!.isNotEmpty)
                  _buildAboutSection(),

                const SizedBox(height: 16),

                // Interests Section
                if (_profile!.hobbies != null && _profile!.hobbies!.isNotEmpty)
                  _buildInterestsSection(),

                const SizedBox(height: 16),

                // Details Section
                _buildDetailsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCard(int completion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hoàn thiện hồ sơ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completion%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (completion < 100) ...[
            const SizedBox(height: 12),
            Text(
              'Hoàn thiện thêm ${100 - completion}% để tăng cơ hội match!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(icon: Icons.info_rounded, title: 'Giới thiệu'),
          const SizedBox(height: 12),
          Text(
            _profile!.bio!,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    final hobbies = _profile!.hobbiesList;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(icon: Icons.favorite_rounded, title: 'Sở thích'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hobbies.map((hobby) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  hobby,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.details_rounded,
            title: 'Thông tin chi tiết',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.email_rounded, 'Email', _profile!.email),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.cake_rounded,
            'Ngày sinh',
            _profile!.birthday != null
                ? DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(_profile!.birthday!))
                : 'Chưa cập nhật',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.location_on_rounded,
            'Vị trí',
            _profile!.location ?? 'Chưa cập nhật',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
