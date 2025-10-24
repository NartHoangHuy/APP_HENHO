import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  DiscoverScreen({super.key});

  // Danh sách sở thích
  final List<Map<String, dynamic>> interests = [
    {
      'title': 'Không ràng buộc',
      'icon': Icons.favorite_border,
      'color': Colors.pink[50],
    },
    {
      'title': 'Người yêu',
      'icon': Icons.favorite,
      'color': Colors.red.shade100,
    },
    {
      'title': 'Hẹn hò nghiêm túc',
      'icon': Icons.handshake,
      'color': Colors.purple.shade100,
    },
    {
      'title': 'Rảnh tối nay',
      'icon': Icons.nightlight,
      'color': Colors.blue.shade100,
    },
    {
      'title': 'Bạn trò chuyện',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.green.shade100,
    },
    {
      'title': 'Tìm bạn cùng sở thích',
      'icon': Icons.group,
      'color': Colors.orange.shade100,
    },
    {
      'title': 'Kết bạn bốn phương',
      'icon': Icons.public,
      'color': Colors.teal.shade100,
    },
  ];

  Widget _tile(
    BuildContext context,
    Map<String, dynamic> interest, {
    double height = 120,
  }) {
    final Color bg = (interest['color'] as Color?) ?? Colors.white;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chọn: ${interest['title']}')),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pinkAccent, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(interest['icon'], color: Colors.pinkAccent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                interest['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách widget theo pattern: ô 1 full-width, ô 2+3 trên 1 hàng (dài + ngắn),
    // ô 4 full-width, ô 5+6 trên 1 hàng, ...
    final List<Widget> tiles = [];
    int i = 0;
    while (i < interests.length) {
      if (i % 3 == 0) {
        // full-width single
        tiles.add(_tile(context, interests[i], height: 120));
        i += 1;
      } else {
        // pair on one row: left long (flex 2), right short (flex 1)
        final left = interests[i];
        final right = (i + 1 < interests.length) ? interests[i + 1] : null;
        tiles.add(
          Row(
            children: [
              Expanded(flex: 2, child: _tile(context, left, height: 120)),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: right != null
                    ? _tile(context, right, height: 120)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
        i += 2;
      }
      // khoảng cách giữa các hàng
      tiles.add(const SizedBox(height: 12));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Khám phá theo sở thích',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: ListView(children: tiles)),
          ],
        ),
      ),
    );
  }
}
