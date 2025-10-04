import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Nguyễn Văn A');
  int _age = 25; // Sử dụng biến int thay cho TextEditingController
  final _locationController = TextEditingController(text: 'Hà Nội');
  final _bioController = TextEditingController(
    text: 'Tôi thích du lịch, đọc sách và gặp gỡ bạn mới.',
  );

  XFile? _avatar;
  final ImagePicker _picker = ImagePicker();

  // Danh sách sở thích mẫu
  final List<String> _allHobbies = [
    'Du lịch',
    'Đọc sách',
    'Âm nhạc',
    'Thể thao',
    'Nấu ăn',
    'Chụp ảnh',
    'Xem phim',
    'Công nghệ',
  ];
  final List<String> _selectedHobbies = ['Du lịch', 'Đọc sách'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatar != null
                        ? Image.file(File(_avatar!.path)).image
                        : const AssetImage('assets/images/avatar.png'),
                    backgroundColor: Colors.pink.shade100,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tuổi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_age > 1) _age--;
                              });
                            },
                          ),
                          Text(
                            '$_age',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_age < 100) _age++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Giới thiệu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sở thích',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: _allHobbies.map((hobby) {
                  final isSelected = _selectedHobbies.contains(hobby);
                  return FilterChip(
                    label: Text(hobby),
                    selected: isSelected,
                    selectedColor: Colors.pink.shade100,
                    checkmarkColor: Colors.pink,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedHobbies.add(hobby);
                        } else {
                          _selectedHobbies.remove(hobby);
                        }
                      });
                    },
                  );
                }).toList(),
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
                    // Xử lý lưu thông tin chỉnh sửa
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
