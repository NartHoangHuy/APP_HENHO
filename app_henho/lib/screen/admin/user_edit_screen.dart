import 'package:flutter/material.dart';

class UserEditScreen extends StatefulWidget {
  final Map<String, String>? user;
  const UserEditScreen({super.key, this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _status = 'Hoạt động';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
    _status = widget.user?['status'] ?? 'Hoạt động';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Thêm người dùng' : 'Sửa người dùng'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items: const [
                DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')),
                DropdownMenuItem(value: 'Bị khóa', child: Text('Bị khóa')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'status': _status,
                  });
                },
                child: Text(widget.user == null ? 'Thêm mới' : 'Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
