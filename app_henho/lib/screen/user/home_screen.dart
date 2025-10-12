import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showLoginSuccess;
  const HomeScreen({super.key, this.showLoginSuccess = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomeContent(),
    DiscoverScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    'Trang chủ',
    'Khám phá',
    'Tin nhắn',
    'Trang cá nhân',
  ];

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Chào mừng bạn đến với App Hẹn Hò!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kết nối, trò chuyện và tìm kiếm người phù hợp ngay hôm nay!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.explore),
                    label: const Text('Khám phá ngay'),
                    onPressed: () {
                      // Chuyển sang tab Khám phá
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.pink.shade100,
                      child: const Icon(
                        Icons.person,
                        color: Colors.pink,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bạn đã hoàn thiện hồ sơ cá nhân chưa?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hãy cập nhật thông tin để tăng cơ hội kết nối!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.pinkAccent),
                      onPressed: () {
                        // Chuyển sang màn hình chỉnh sửa hồ sơ
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Gợi ý kết nối',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.pink.shade100,
                          child: const Icon(Icons.person, color: Colors.pink),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'User',
                          style: TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
