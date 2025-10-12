import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

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

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
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
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.left),
                  child: const Icon(Icons.keyboard_arrow_left),
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.right),
                  child: const Icon(Icons.keyboard_arrow_right),
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.top),
                  child: const Icon(Icons.keyboard_arrow_up),
                ),
                FloatingActionButton(
                  onPressed: () => controller.swipe(CardSwiperDirection.bottom),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}
