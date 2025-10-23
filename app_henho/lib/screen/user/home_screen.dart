import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'discover_screen.dart';
import 'like_screen.dart';

class Candidate {
  final String name;
  final String age;
  final String bio;
  final String avatar;

  Candidate({
    required this.name,
    required this.age,
    required this.bio,
    required this.avatar,
  });
}

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final CardSwiperController controller;
  const CandidateCard(this.candidate, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.pink.shade100,
            backgroundImage: AssetImage(candidate.avatar),
          ),
          const SizedBox(height: 16),
          Text(
            '${candidate.name}, ${candidate.age}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            candidate.bio,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.close),
                label: const Text('Bỏ qua'),
                onPressed: () {
                  controller.swipe(CardSwiperDirection.left);
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.favorite),
                label: const Text('Kết nối'),
                onPressed: () {
                  controller.swipe(CardSwiperDirection.right);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

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
    LikeScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

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
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: Colors.pink),
            label: 'Lượt thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Colors.pink),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.pink),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final CardSwiperController controller = CardSwiperController();

  final List<Candidate> candidates = [
    Candidate(
      name: 'Mai Lan',
      age: '23',
      bio: 'Thích nghệ thuật, du lịch',
      avatar: 'assets/images/avatar1.png',
    ),
    Candidate(
      name: 'Hoàng Nam',
      age: '25',
      bio: 'Yêu thể thao, công nghệ',
      avatar: 'assets/images/avatar2.png',
    ),
    Candidate(
      name: 'Minh Anh',
      age: '22',
      bio: 'Đọc sách, xem phim',
      avatar: 'assets/images/avatar3.png',
    ),
  ];

  late final List<Widget> cards;

  @override
  void initState() {
    super.initState();
    cards = candidates.map((c) => CandidateCard(c, controller)).toList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint('The card $currentIndex was undod from the ${direction.name}');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Flexible(
            child: CardSwiper(
              controller: controller,
              cardsCount: cards.length,
              onSwipe: _onSwipe,
              onUndo: _onUndo,
              numberOfCardsDisplayed: 3,
              backCardOffset: const Offset(40, 40),
              padding: const EdgeInsets.all(24.0),
              cardBuilder:
                  (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                  ) => cards[index],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: controller.undo,
                  child: const Icon(Icons.rotate_left),
                  backgroundColor: Colors.grey.shade300,
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.left),
                  child: const Icon(Icons.keyboard_arrow_left),
                  backgroundColor: Colors.grey.shade300,
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.right),
                  child: const Icon(Icons.keyboard_arrow_right),
                  backgroundColor: Colors.pinkAccent,
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.top),
                  child: const Icon(Icons.keyboard_arrow_up),
                  backgroundColor: Colors.grey.shade300,
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.bottom),
                  child: const Icon(Icons.keyboard_arrow_down),
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
