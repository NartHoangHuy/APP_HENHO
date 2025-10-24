import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/auth_service.dart';
import '../../model/user_profile.dart';

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
    if (token != null) {
      final profile = await AuthService().getProfile(token);
      setState(() {
        _profile = profile;
      });
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
    // Nếu không có dữ liệu thì hiển thị thông tin rỗng
    final name = _profile?.username ?? '';
    final info = _profile != null
        ? '${_profile!.birthday ?? ''}, ${_profile!.gender ?? ''}'
        : '';
    final email = _profile?.email ?? '';
    final bio = _profile?.bio ?? '';
    final location = _profile?.location ?? '';
    final age = _profile?.age?.toString() ?? '';
    final hobbies = _profile?.hobbies ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(info, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            location,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            age.isNotEmpty ? '$age tuổi' : '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.pink),
                    title: const Text('Email'),
                    subtitle: Text(email),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.pink),
                    title: const Text('Giới thiệu'),
                    subtitle: Text(bio),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.pink),
                    title: const Text('Sở thích'),
                    subtitle: Text(hobbies),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              // Danh sách ảnh profile
              final List<String> images = [
                'assets/images/12.jpg',
                'assets/images/profile1.jpg',
                'assets/images/13.jpg',
                'assets/images/12.jpg',
                'assets/images/profile1.jpg',
                'assets/images/14.jpg',
              ];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Chỉnh sửa hồ sơ'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                _loadProfile(); // Reload dữ liệu sau khi chỉnh sửa
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
