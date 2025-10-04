import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Import màn hình profile

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeContent(),
    DiscoverContent(),
    ChatContent(),
    ProfileScreen(), // Điều hướng tới màn hình profile thật
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('App Hẹn Hò'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: Colors.pink.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.pink),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: Colors.pink),
            label: 'Khám phá',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Colors.pink),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.pink),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: Colors.pink, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Chào mừng bạn đến với App Hẹn Hò!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bắt đầu kết nối và tìm kiếm người phù hợp ngay!',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.explore),
            label: const Text('Khám phá ngay'),
            onPressed: () {
              // Chuyển sang tab Khám phá
              // Nếu muốn chuyển tab, có thể dùng callback hoặc Provider
            },
          ),
        ],
      ),
    );
  }
}

class DiscoverContent extends StatelessWidget {
  const DiscoverContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.explore, color: Colors.pink, size: 64),
          SizedBox(height: 24),
          Text(
            'Khám phá người mới!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Tính năng swipe sẽ được phát triển ở đây.'),
        ],
      ),
    );
  }
}

class ChatContent extends StatelessWidget {
  const ChatContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.chat_bubble, color: Colors.pink, size: 64),
          SizedBox(height: 24),
          Text(
            'Tin nhắn',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Danh sách chat sẽ hiển thị ở đây.'),
        ],
      ),
    );
  }
}
