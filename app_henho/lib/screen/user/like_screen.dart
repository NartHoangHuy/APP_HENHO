// ...existing code...
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class Like {
  final String name;
  final String age;
  final String avatar;
  final double distanceKm;

  Like({
    required this.name,
    required this.age,
    required this.avatar,
    required this.distanceKm,
  });
}

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  // Dữ liệu ảo cho danh sách người đã thích
  List<Like> likes = [
    Like(
      name: 'Lan Anh',
      age: '24',
      avatar: 'assets/images/13.jpg',
      distanceKm: 2.5,
    ),
    Like(
      name: 'Minh Tuấn',
      age: '27',
      avatar: 'assets/images/profile1.jpg',
      distanceKm: 12.3,
    ),
    Like(
      name: 'Hương Giang',
      age: '22',
      avatar: 'assets/images/12.jpg',
      distanceKm: 0.8,
    ),
    Like(
      name: 'Quốc Hùng',
      age: '26',
      avatar: 'assets/images/14.jpg',
      distanceKm: 45.0,
    ),
  ];

  void _likeBack(int index) {
    final person = likes[index];
    setState(() {
      likes.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã thích lại ${person.name}!')));
  }

  void _ignore(int index) {
    final person = likes[index];
    setState(() {
      likes.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã bỏ qua ${person.name}.')));
  }

  void _showDetails(int index) {
    final person = likes[index];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.pink.shade50,
                backgroundImage: AssetImage(person.avatar),
              ),
              const SizedBox(height: 12),
              Text(
                '${person.name}, ${person.age}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cách bạn ${person.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // Thông tin giả lập thêm
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.pinkAccent),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Đang hoạt động • Muốn kết bạn')),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.favorite),
                  label: const Text('Thích lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Lấy lại index hiện tại (nếu vẫn tồn tại trong list)
                    final currentIndex = likes.indexWhere(
                      (l) => l.name == person.name && l.age == person.age,
                    );
                    if (currentIndex != -1) _likeBack(currentIndex);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Những người đã thích bạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: likes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.pink,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chưa có ai thích bạn',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: likes.length,
                      itemBuilder: (context, index) {
                        final like = likes[index];
                        return Dismissible(
                          key: ValueKey(like.name + like.age),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _ignore(index),
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _showDetails(index),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.pink.shade100,
                                      backgroundImage: AssetImage(like.avatar),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${like.name}, ${like.age}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Dòng dưới: nút Thích lại bên trái, dấu X bên phải
                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.pinkAccent,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.favorite,
                                                  size: 18,
                                                ),
                                                label: const Text('Thích lại'),
                                                onPressed: () =>
                                                    _likeBack(index),
                                              ),
                                              // khoảng cách giữa nút và dấu x
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () => _ignore(index),
                                                tooltip: 'Bỏ qua',
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
