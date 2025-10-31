import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class DiscoverScreen extends StatelessWidget {
  DiscoverScreen({super.key});

  // Danh sách sở thích với màu gradient
  final List<Map<String, dynamic>> interests = [
    {
      'title': 'Không ràng buộc',
      'icon': Icons.favorite_border,
      'gradient': [Colors.pink.shade300, Colors.pink.shade400],
    },
    {
      'title': 'Người yêu',
      'icon': Icons.favorite,
      'gradient': [Colors.red.shade300, Colors.red.shade500],
    },
    {
      'title': 'Hẹn hò nghiêm túc',
      'icon': Icons.handshake,
      'gradient': [Colors.purple.shade300, Colors.purple.shade500],
    },
    {
      'title': 'Rảnh tối nay',
      'icon': Icons.nightlight,
      'gradient': [Colors.blue.shade300, Colors.blue.shade500],
    },
    {
      'title': 'Bạn trò chuyện',
      'icon': Icons.chat_bubble_outline,
      'gradient': [Colors.green.shade300, Colors.green.shade500],
    },
    {
      'title': 'Tìm bạn cùng sở thích',
      'icon': Icons.group,
      'gradient': [Colors.orange.shade300, Colors.orange.shade500],
    },
    {
      'title': 'Kết bạn bốn phương',
      'icon': Icons.public,
      'gradient': [Colors.teal.shade300, Colors.teal.shade500],
    },
  ];

  Widget _tile(
    BuildContext context,
    Map<String, dynamic> interest, {
    double height = 120,
  }) {
    final List<Color> gradient = interest['gradient'] as List<Color>;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Đã chọn: ${interest['title']}')),
              ],
            ),
            backgroundColor: gradient[0],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient[0].withOpacity(0.15),
              gradient[1].withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gradient[0].withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(interest['icon'], color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                interest['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: gradient[1],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: gradient[0], size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khám phá',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tìm người phù hợp theo sở thích của bạn',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Grid của interests
            Expanded(
              child: ListView.builder(
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _tile(context, interests[index], height: 100),
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
