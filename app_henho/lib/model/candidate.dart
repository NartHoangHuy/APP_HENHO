// Model đại diện cho một ứng viên/người dùng trong tính năng swipe
class Candidate {
  final int id;
  final String name;
  final int age;
  final String bio;
  final String avatar;
  final String? location;
  final double? distanceKm;
  final List<String>? hobbies;
  final List<String>? images; // Danh sách ảnh profile

  Candidate({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.avatar,
    this.location,
    this.distanceKm,
    this.hobbies,
    this.images,
  });

  // Chuyển đổi từ JSON response của backend
  factory Candidate.fromJson(Map<String, dynamic> json) {
    // Combine avatar_url and photos_urls for images list
    List<String> allImages = [];
    if (json['avatar_url'] != null &&
        json['avatar_url'].toString().isNotEmpty) {
      allImages.add(json['avatar_url']);
    }
    if (json['photos_urls'] != null) {
      allImages.addAll(List<String>.from(json['photos_urls']));
    }

    return Candidate(
      id: json['id'],
      name: json['username'] ?? '',
      age: json['age'] ?? 0,
      bio: json['bio'] ?? '',
      avatar: json['avatar_url'] ?? '',
      location: json['location'],
      distanceKm: json['distance_km']?.toDouble(),
      hobbies: json['hobbies'] != null
          ? (json['hobbies'] as String).split(',').map((e) => e.trim()).toList()
          : null,
      images: allImages.isNotEmpty ? allImages : null,
    );
  }

  // Chuyển đổi sang JSON để gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'age': age,
      'bio': bio,
      'avatar': avatar,
      'location': location,
      'distance_km': distanceKm,
      'hobbies': hobbies?.join(', '),
      'images': images,
    };
  }
}
