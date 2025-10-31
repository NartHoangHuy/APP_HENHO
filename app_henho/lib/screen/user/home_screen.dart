import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'discover_screen.dart';
import 'like_screen.dart';
import 'home_content.dart';

// Màn hình chính với BottomNavigationBar
class HomeScreen extends StatefulWidget {
  final bool showLoginSuccess;
  const HomeScreen({super.key, this.showLoginSuccess = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình con
  static final List<Widget> _pages = [
    const HomeContent(), // Màn hình swipe card
    DiscoverScreen(), // Màn hình khám phá theo sở thích
    const LikeScreen(), // Màn hình danh sách người thích bạn
    const ChatScreen(), // Màn hình chat
    const ProfileScreen(), // Màn hình profile
  ];

  // Tiêu đề tương ứng với mỗi tab
  final List<String> _titles = [
    'Trang chủ',
    'Khám phá',
    'Lượt thích',
    'Tin nhắn',
    'Hồ sơ',
  ];

  @override
  void initState() {
    super.initState();
    // Hiển thị thông báo đăng nhập thành công
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showLoginSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _selectedIndex == 0
          ? null // No app bar for home content (swipe screen)
          : AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.white,
            indicatorColor: Colors.pink.shade50,
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.grey.shade600),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ).createShader(bounds),
                  child: const Icon(Icons.home, color: Colors.white),
                ),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, color: Colors.grey.shade600),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ).createShader(bounds),
                  child: const Icon(Icons.explore, color: Colors.white),
                ),
                label: 'Khám phá',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border, color: Colors.grey.shade600),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ).createShader(bounds),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
                label: 'Lượt thích',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey.shade600,
                ),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ).createShader(bounds),
                  child: const Icon(Icons.chat_bubble, color: Colors.white),
                ),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ).createShader(bounds),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
