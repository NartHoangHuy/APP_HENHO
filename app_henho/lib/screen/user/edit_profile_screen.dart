import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../service/auth_service.dart';
import '../../service/location_service.dart';
import '../../service/master_data_service.dart';
import '../../config/app_theme.dart';
import '../../model/master_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedCity;
  String? _selectedGender; // THÊM: Gender selection
  final _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile?> _images = List<XFile?>.filled(6, null, growable: false);
  String? _existingAvatarUrl; // Lưu avatar URL từ server
  List<String> _existingPhotosUrls = []; // Lưu photos URLs từ server

  // Location services
  final LocationService _locationService = LocationService();
  final MasterDataService _masterDataService = MasterDataService();
  double? _latitude;
  double? _longitude;
  bool _isDetectingLocation = false;

  // Master data from API
  List<City> cities = [];
  List<Hobby> hobbies = [];
  bool _isLoadingMasterData = true;

  final Set<int> selectedHobbyIds = {};

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    _loadCurrentProfile(); // Load dữ liệu hiện tại
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final profile = await AuthService().getProfile(token);

        if (profile != null && mounted) {
          setState(() {
            // Load các giá trị hiện tại vào form
            _nameController.text = profile.username;

            if (profile.bio != null && profile.bio!.isNotEmpty) {
              _bioController.text = profile.bio!;
            }

            if (profile.birthday != null) {
              _birthDate = DateTime.tryParse(profile.birthday!);
            }

            if (profile.gender != null && profile.gender!.isNotEmpty) {
              _selectedGender = profile.gender;
            }

            if (profile.location != null && profile.location!.isNotEmpty) {
              _selectedCity = profile.location;
            }

            if (profile.latitude != null && profile.longitude != null) {
              _latitude = profile.latitude;
              _longitude = profile.longitude;
            }

            // Load hobbies đã chọn
            if (profile.hobbies != null && profile.hobbies!.isNotEmpty) {
              final hobbyNames = profile.hobbies!
                  .split(',')
                  .map((e) => e.trim())
                  .toList();
              // Sẽ match với hobby IDs sau khi load xong hobbies list
              _selectedHobbyNames = hobbyNames;
            }

            // Load avatar URL từ server
            print(
              '🔍 Profile data: avatar=${profile.avatar}, avatarUrl=${profile.avatarUrl}',
            );
            print(
              '🔍 Photos data: photos=${profile.photos}, photosUrls=${profile.photosUrls}',
            );

            if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
              _existingAvatarUrl = profile.avatarUrl;
              print('🖼️ Loaded existing avatar: $_existingAvatarUrl');
            } else {
              print('⚠️ No avatar URL found in profile');
            }

            // Load additional photos URLs từ server
            if (profile.photosUrls != null && profile.photosUrls!.isNotEmpty) {
              _existingPhotosUrls = profile.photosUrls!;
              print('📸 Loaded ${_existingPhotosUrls.length} existing photos');
              for (int i = 0; i < _existingPhotosUrls.length; i++) {
                print('  Photo ${i + 1}: ${_existingPhotosUrls[i]}');
              }
            } else {
              print('⚠️ No photos URLs found in profile');
            }
          });
        }
      }
    } catch (e) {
      print('❌ Error loading current profile: $e');
    }
  }

  List<String> _selectedHobbyNames = []; // Temporary store

  Future<void> _loadMasterData() async {
    setState(() => _isLoadingMasterData = true);

    try {
      final loadedCities = await _masterDataService.getCitiesWithCache();
      final loadedHobbies = await _masterDataService.getHobbiesWithCache();

      if (mounted) {
        setState(() {
          cities = loadedCities;
          hobbies = loadedHobbies;
          _isLoadingMasterData = false;

          // Match hobby names với IDs
          if (_selectedHobbyNames.isNotEmpty && hobbies.isNotEmpty) {
            for (var hobbyName in _selectedHobbyNames) {
              try {
                final hobby = hobbies.firstWhere((h) => h.name == hobbyName);
                selectedHobbyIds.add(hobby.id);
              } catch (e) {
                print('❌ Hobby not found: $hobbyName');
              }
            }
          }
        });
      }
    } catch (e) {
      print('❌ Error loading master data: $e');
      if (mounted) {
        setState(() => _isLoadingMasterData = false);
      }
    }
  }

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

  int get imageCount {
    int count = _images.where((img) => img != null).length;
    // Cộng thêm 1 nếu có avatar từ server và chưa có ảnh local ở vị trí đầu
    if (_existingAvatarUrl != null && _images[0] == null) {
      count++;
    }
    return count;
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetectingLocation = true);

    try {
      // Request permission
      final hasPermission = await _locationService.requestLocationPermission();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Cần cấp quyền vị trí để sử dụng tính năng này'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isDetectingLocation = false);
        return;
      }

      // Get current position
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        // Get city name from coordinates
        final city = await _locationService.getCityFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _selectedCity = city;
            _isDetectingLocation = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã phát hiện vị trí: $city'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isDetectingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Không thể lấy vị trí hiện tại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error detecting location: $e');
      if (mounted) {
        setState(() => _isDetectingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Vui lòng nhập tên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('🔑 Token: $token');

      // Convert hobby IDs to names
      final selectedHobbyNames = hobbies
          .where((hobby) => selectedHobbyIds.contains(hobby.id))
          .map((hobby) => hobby.name)
          .toList();

      final Map<String, dynamic> data = {
        'username': _nameController.text.trim(),
      };

      // Chỉ thêm bio nếu không rỗng
      if (_bioController.text.trim().isNotEmpty) {
        data['bio'] = _bioController.text.trim();
      }

      // Chỉ thêm hobbies nếu có chọn
      if (selectedHobbyNames.isNotEmpty) {
        data['hobbies'] = selectedHobbyNames.join(', ');
      }

      // Chỉ thêm gender nếu đã chọn
      if (_selectedGender != null && _selectedGender!.isNotEmpty) {
        data['gender'] = _selectedGender!;
      }

      // Chỉ thêm các trường khi đã được chọn
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        data['location'] = _selectedCity!;
      }

      // Thêm latitude và longitude CHỈ KHI CÓ CẢ HAI
      if (_latitude != null && _longitude != null) {
        data['latitude'] = _latitude.toString();
        data['longitude'] = _longitude.toString();
      }

      if (_birthDate != null) {
        data['birthday'] = DateFormat('yyyy-MM-dd').format(_birthDate!);
        final age = _calculateAge(_birthDate!);
        if (age >= 18 && age <= 100) {
          data['age'] = age;
        }
      }

      print('📦 Data gửi lên: $data');

      // Count total images (existing + new)
      int totalImages = 0;

      // Count avatar
      if (_images[0] != null) {
        totalImages++; // New avatar
      } else if (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty) {
        totalImages++; // Existing avatar
      }

      // Count photos
      int newPhotoCount = 0;
      for (int i = 1; i < _images.length; i++) {
        if (_images[i] != null) {
          newPhotoCount++;
        }
      }
      totalImages += newPhotoCount > 0
          ? newPhotoCount
          : _existingPhotosUrls.length;

      // Validate: Require at least 2 images
      if (totalImages < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ Cần tối thiểu 2 ảnh (1 ảnh đại diện + 1 ảnh phụ)',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Lấy đường dẫn ảnh đầu tiên (nếu có)
      String? avatarPath;
      if (_images.isNotEmpty && _images[0] != null) {
        avatarPath = _images[0]!.path;
        print('📷 Avatar path: $avatarPath');
      }

      // Lấy đường dẫn các ảnh phụ (từ index 1-5)
      List<String> photoPaths = [];
      for (int i = 1; i < _images.length && i < 6; i++) {
        if (_images[i] != null) {
          photoPaths.add(_images[i]!.path);
          print('📸 Photo ${i} path: ${_images[i]!.path}');
        }
      }

      print(
        '📊 Total images: $totalImages (Avatar: ${avatarPath != null || _existingAvatarUrl != null ? '✅' : '❌'}, Photos: ${photoPaths.length + _existingPhotosUrls.length})',
      );

      if (token != null) {
        // Dùng updateProfileWithAvatar nếu có ảnh, không thì dùng updateProfile thường
        final success = (avatarPath != null || photoPaths.isNotEmpty)
            ? await AuthService().updateProfileWithAvatar(
                token,
                data,
                avatarPath,
                photoPaths: photoPaths.isNotEmpty ? photoPaths : null,
              )
            : await AuthService().updateProfile(token, data);

        print('✅ Kết quả lưu: $success');

        // Close loading
        Navigator.pop(context);

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cập nhật profile thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Return true to indicate success
          Navigator.pop(context, true);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Không thể cập nhật profile'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Không tìm thấy token'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar với gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Chỉnh sửa hồ sơ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Grid Section
                  _buildImageSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // Personal Info Section
                  _buildPersonalInfoSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // Hobbies Section
                  _buildHobbiesSection(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Save Button
                  _buildSaveButton(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ảnh hồ sơ',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  gradient: imageCount >= 2
                      ? LinearGradient(
                          colors: [AppColors.success, AppColors.success],
                        )
                      : LinearGradient(
                          colors: [AppColors.error, AppColors.error],
                        ),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  '$imageCount/6',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final img = _images[index];
              return _buildImageCard(img, index);
            },
          ),

          if (imageCount < 2)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Bạn cần chọn ít nhất 2 ảnh để hoàn thiện hồ sơ',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCard(XFile? img, int index) {
    // Hiển thị ảnh từ server cho ô đầu tiên nếu chưa có ảnh local
    final hasExistingAvatar =
        index == 0 &&
        img == null &&
        _existingAvatarUrl != null &&
        _existingAvatarUrl!.isNotEmpty;
    // Hiển thị ảnh phụ từ server cho các ô còn lại (index 1-5)
    final hasExistingPhoto =
        index > 0 &&
        img == null &&
        _existingPhotosUrls.isNotEmpty &&
        (index - 1) < _existingPhotosUrls.length &&
        _existingPhotosUrls[index - 1].isNotEmpty;
    final existingPhotoUrl = hasExistingPhoto
        ? _existingPhotosUrls[index - 1]
        : null;

    // Debug log CHI TIẾT
    if (index == 0 && _existingAvatarUrl != null) {
      print(
        '🎨 Card $index: hasExistingAvatar=$hasExistingAvatar, url=$_existingAvatarUrl',
      );
    }
    if (index > 0 && _existingPhotosUrls.isNotEmpty) {
      print('🎨 Card $index DEBUG:');
      print('   img == null: ${img == null}');
      print(
        '   _existingPhotosUrls.isNotEmpty: ${_existingPhotosUrls.isNotEmpty}',
      );
      print(
        '   (index - 1) < _existingPhotosUrls.length: ${(index - 1) < _existingPhotosUrls.length}',
      );
      if ((index - 1) < _existingPhotosUrls.length) {
        print(
          '   _existingPhotosUrls[${index - 1}]: "${_existingPhotosUrls[index - 1]}"',
        );
        print('   .isNotEmpty: ${_existingPhotosUrls[index - 1].isNotEmpty}');
      }
      print(
        '   → hasExistingPhoto=$hasExistingPhoto, url=$existingPhotoUrl, totalPhotos=${_existingPhotosUrls.length}',
      );
    }

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: (img == null && !hasExistingAvatar && !hasExistingPhoto)
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: (img == null && !hasExistingAvatar && !hasExistingPhoto)
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.primary,
            width: (img == null && !hasExistingAvatar && !hasExistingPhoto)
                ? 1
                : 2,
          ),
          boxShadow: (img != null || hasExistingAvatar || hasExistingPhoto)
              ? AppShadows.small
              : null,
        ),
        child: Stack(
          children: [
            if (img == null && !hasExistingAvatar && !hasExistingPhoto)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.primary,
                      size: AppIconSize.lg,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      index == 0 ? 'Avatar' : 'Thêm',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (img != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.file(
                  File(img.path),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else if (hasExistingAvatar)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  _existingAvatarUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.error,
                        size: AppIconSize.lg,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              )
            else if (hasExistingPhoto && existingPhotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  existingPhotoUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.error,
                        size: AppIconSize.lg,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),

            if (img != null || hasExistingAvatar || hasExistingPhoto)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    if (img != null) {
                      _removeImage(index);
                    } else if (hasExistingAvatar) {
                      setState(() {
                        _existingAvatarUrl = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.small,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Thông tin cá nhân',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildTextField(
            controller: _nameController,
            label: 'Họ và tên',
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: AppSpacing.md),

          _buildBirthDateSelector(),
          const SizedBox(height: AppSpacing.md),

          _buildGenderSelector(),
          const SizedBox(height: AppSpacing.md),

          _buildCitySelector(),
          _buildLocationAutoDetectButton(),
          const SizedBox(height: AppSpacing.md),

          _buildTextField(
            controller: _bioController,
            label: 'Giới thiệu về bạn',
            icon: Icons.info_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    const genderOptions = [
      {'value': 'male', 'label': 'Nam', 'icon': Icons.male_rounded},
      {'value': 'female', 'label': 'Nữ', 'icon': Icons.female_rounded},
      {'value': 'other', 'label': 'Khác', 'icon': Icons.transgender_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wc_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Giới tính',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: genderOptions.map((option) {
              final isSelected = _selectedGender == option['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = option['value'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [Colors.transparent, Colors.transparent],
                            ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: AppIconSize.lg,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['label'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateSelector() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày sinh',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _birthDate != null
                        ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                        : 'Chọn ngày sinh của bạn',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _birthDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: _birthDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (_birthDate != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  '${_calculateAge(_birthDate!)} tuổi',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.textSecondary,
                size: AppIconSize.sm,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitySelector() {
    if (_isLoadingMasterData) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.location_city_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Đang tải danh sách thành phố...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.location_city_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                hint: Text(
                  'Chọn thành phố',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                items: cities.map((City city) {
                  return DropdownMenuItem<String>(
                    value: city.name,
                    child: Text(city.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAutoDetectButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isDetectingLocation ? null : _detectLocation,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: _isDetectingLocation
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
          label: Text(
            _isDetectingLocation
                ? 'Đang phát hiện...'
                : '📍 Tự động phát hiện vị trí',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHobbiesSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sở thích',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.accent.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Text(
                  '${selectedHobbyIds.length} đã chọn',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (_isLoadingMasterData)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Đang tải danh sách sở thích...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: hobbies.map((hobby) {
                final isSelected = selectedHobbyIds.contains(hobby.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedHobbyIds.remove(hobby.id);
                      } else {
                        selectedHobbyIds.add(hobby.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.primaryGradient
                          : LinearGradient(
                              colors: [AppColors.surface, AppColors.surface],
                            ),
                      borderRadius: BorderRadius.circular(AppRadius.round),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: isSelected ? AppShadows.small : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        Text(
                          hobby.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final isValid = imageCount >= 2 && _nameController.text.isNotEmpty;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isValid
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [AppColors.textSecondary, AppColors.textSecondary],
              ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: isValid ? AppShadows.medium : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isValid ? _saveProfile : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Lưu thay đổi',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
