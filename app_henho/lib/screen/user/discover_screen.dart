import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../providers/filter_provider.dart';
import '../../service/interest_service.dart';

class DiscoverScreen extends StatelessWidget {
  DiscoverScreen({super.key});

  // Danh sách sở thích với màu gradient và filter mapping
  final List<Map<String, dynamic>> interests = [
    {
      'title': 'Không ràng buộc',
      'icon': Icons.favorite_border,
      'gradient': [Colors.pink.shade300, Colors.pink.shade400],
      'hobby': 'Không ràng buộc',
    },
    {
      'title': 'Người yêu',
      'icon': Icons.favorite,
      'gradient': [Colors.red.shade300, Colors.red.shade500],
      'hobby': 'Người yêu',
    },
    {
      'title': 'Hẹn hò nghiêm túc',
      'icon': Icons.handshake,
      'gradient': [Colors.purple.shade300, Colors.purple.shade500],
      'hobby': 'Hẹn hò nghiêm túc',
    },
    {
      'title': 'Rảnh tối nay',
      'icon': Icons.nightlight,
      'gradient': [Colors.blue.shade300, Colors.blue.shade500],
      'hobby': 'Rảnh tối nay',
    },
    {
      'title': 'Bạn trò chuyện',
      'icon': Icons.chat_bubble_outline,
      'gradient': [Colors.green.shade300, Colors.green.shade500],
      'hobby': 'Bạn trò chuyện',
    },
    {
      'title': 'Tìm bạn cùng sở thích',
      'icon': Icons.group,
      'gradient': [Colors.orange.shade300, Colors.orange.shade500],
      'hobby': 'Tìm bạn cùng sở thích',
    },
    {
      'title': 'Kết bạn bốn phương',
      'icon': Icons.public,
      'gradient': [Colors.teal.shade300, Colors.teal.shade500],
      'mode': 'all', // Đặc biệt: trộn tất cả
    },
  ];

  Widget _tile(
    BuildContext context,
    Map<String, dynamic> interest, {
    double height = 120,
  }) {
    final List<Color> gradient = interest['gradient'] as List<Color>;
    return GestureDetector(
      onTap: () async {
        // 🎯 Set filter vào Provider
        final filterProvider = context.read<FilterProvider>();

        // 📝 Add interest to user's profile automatically
        if (interest.containsKey('hobby')) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            final interestService = InterestService();
            await interestService.addInterest(token, interest['hobby']);
          }
        }

        if (interest.containsKey('mode')) {
          // "Kết bạn bốn phương" - trộn tất cả
          filterProvider.setFilter(mode: interest['mode']);
        } else if (interest.containsKey('hobby')) {
          // Filter theo sở thích cụ thể
          filterProvider.setFilter(hobby: interest['hobby']);
        }

        // Navigate back to Home tab (index 0)
        // Home sẽ tự động watch FilterProvider và reload
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Đang tìm: ${interest['title']}')),
              ],
            ),
            backgroundColor: gradient[0],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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
