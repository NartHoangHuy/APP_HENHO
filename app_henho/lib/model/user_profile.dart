class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? avatar;
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final String? birthday;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int? age;
  final String? hobbies;
  final bool isProfileComplete;
  final DateTime? dateJoined;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.birthday,
    this.location,
    this.latitude,
    this.longitude,
    this.age,
    this.hobbies,
    this.isProfileComplete = false,
    this.dateJoined,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      gender: json['gender'],
      birthday: json['birthday'],
      location: json['location'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      age: json['age'],
      hobbies: json['hobbies'],
      isProfileComplete: json['is_profile_complete'] ?? false,
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'gender': gender,
      'birthday': birthday,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'age': age,
      'hobbies': hobbies,
    };
  }

  // Helper getters
  String get displayName => username;
  String get displayLocation => location ?? 'Chưa cập nhật';
  String get displayAge => age != null ? '$age tuổi' : '';
  String get displayBio => bio ?? 'Chưa có giới thiệu';

  List<String> get hobbiesList {
    if (hobbies == null || hobbies!.isEmpty) return [];
    return hobbies!.split(',').map((e) => e.trim()).toList();
  }
}
