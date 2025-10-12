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
  int _age = 25;
  final _locationController = TextEditingController(text: 'Hà Nội');
  final _bioController = TextEditingController(
    text: 'Tôi thích du lịch, đọc sách và gặp gỡ bạn mới.',
  );

  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = List<XFile?>.filled(6, null, growable: false);

  // Danh sách sở thích mẫu
  final List<String> hobbies = [
    'Nghệ thuật',
    'Bơi lội',
    'Xem phim',
    'Nhạc cụ',
    'Du lịch',
    'Ẩm thực',
    'Thể thao',
    'Đọc sách',
    'Chụp ảnh',
    'Công nghệ',
  ];

  // Sở thích đã chọn
  final Set<String> selectedHobbies = {};

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images[index] = pickedFile;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
  }

  int get imageCount => _images.where((img) => img != null).length;

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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ảnh hồ sơ (${imageCount}/6)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final img = _images[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.pinkAccent,
                              width: img == null ? 1 : 2,
                            ),
                          ),
                          child: img == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.pink,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Thêm ảnh',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(img.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      if (img != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (imageCount < 2)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Bạn cần chọn ít nhất 2 ảnh!',
                    style: TextStyle(color: Colors.red),
                  ),
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sở thích',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: hobbies.map((hobby) {
                  final isSelected = selectedHobbies.contains(hobby);
                  return ChoiceChip(
                    label: Text(hobby),
                    selected: isSelected,
                    selectedColor: Colors.pinkAccent,
                    backgroundColor: Colors.pink.shade50,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.pinkAccent,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedHobbies.add(hobby);
                        } else {
                          selectedHobbies.remove(hobby);
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
                  onPressed: imageCount < 2
                      ? null
                      : () {
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
