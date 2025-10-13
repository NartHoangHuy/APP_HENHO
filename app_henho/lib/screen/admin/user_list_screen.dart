import 'package:flutter/material.dart';
import 'user_edit_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, String>> users = [
    {'name': 'Nguyễn Văn A', 'email': 'a@gmail.com', 'status': 'Hoạt động'},
    {'name': 'Mai Lan', 'email': 'lan@gmail.com', 'status': 'Bị khóa'},
    {'name': 'Hoàng Nam', 'email': 'nam@gmail.com', 'status': 'Hoạt động'},
    {'name': 'Trẩn Hoàng Huy', 'email': 'huy@gmail.com', 'status': 'Hoạt động'},
    //them du lieu Tran Hoang Huydasdasdasdasdas
  ];

  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  void _editUser(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserEditScreen(user: users[index]),
      ),
    );
    if (result != null) {
      setState(() {
        users[index] = result;
      });
    }
  }

  void _addUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserEditScreen()),
    );
    if (result != null) {
      setState(() {
        users.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: Colors.pinkAccent,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addUser)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách người dùng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          child: const Icon(Icons.person, color: Colors.pink),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            user['email']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user['status'] == 'Hoạt động'
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['status']!,
                            style: TextStyle(
                              color: user['status'] == 'Hoạt động'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.pink),
                          onPressed: () => _editUser(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(index),
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
