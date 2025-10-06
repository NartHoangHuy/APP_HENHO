import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bạn bè...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.pink.shade50,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.pink.shade100,
                    child: const Icon(Icons.person, color: Colors.pink),
                    radius: 26,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 52,
                    alignment: Alignment.center,
                    child: Text(
                      'User ${index + 1}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink.shade100,
                    child: const Icon(Icons.person, color: Colors.pink),
                    radius: 28,
                  ),
                  title: Text(
                    'Tên người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Tin nhắn gần nhất...'),
                  trailing: const Text(
                    '09:30',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // Điều hướng tới màn hình chat chi tiết nếu cần
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
