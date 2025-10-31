import 'candidate.dart';

// Model đại diện cho một lượt thích từ người khác
class Like {
  final int id;
  final int fromUserId; // ID của người thích bạn
  final String name;
  final int age;
  final String gender;
  final String avatar;
  final double distanceKm;
  final String? bio;
  final String? hobbies;
  final List<String> interestedIn;
  final List<String> photos;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.fromUserId,
    required this.name,
    required this.age,
    required this.gender,
    required this.avatar,
    required this.distanceKm,
    this.bio,
    this.hobbies,
    required this.interestedIn,
    required this.photos,
    required this.createdAt,
  });

  // Chuyển đổi từ JSON response của backend
  factory Like.fromJson(Map<String, dynamic> json) {
    // Parse photos
    List<String> photosList = [];
    if (json['from_user_photos'] != null) {
      photosList = List<String>.from(json['from_user_photos']);
    }

    // Parse interested_in
    List<String> interestedInList = [];
    if (json['from_user_interested_in'] != null) {
      interestedInList = List<String>.from(json['from_user_interested_in']);
    }

    return Like(
      id: json['id'],
      fromUserId:
          json['from_user'] ??
          json['from_user_id'], // Backend returns 'from_user' (ID)
      name: json['from_user_name'] ?? '',
      age: json['from_user_age'] ?? 0,
      gender: json['from_user_gender'] ?? '',
      avatar: json['from_user_avatar'] ?? '',
      distanceKm: 0.0, // Distance not provided by backend
      bio: json['from_user_bio'],
      hobbies: json['from_user_hobbies'],
      interestedIn: interestedInList,
      photos: photosList,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'from_user_name': name,
      'from_user_age': age,
      'from_user_gender': gender,
      'from_user_avatar': avatar,
      'distance_km': distanceKm,
      'from_user_bio': bio,
      'from_user_hobbies': hobbies,
      'from_user_interested_in': interestedIn,
      'from_user_photos': photos,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Chuyển Like sang Candidate để hiển thị detail screen
  Candidate toCandidate() {
    // Combine avatar and photos for images list
    List<String> allImages = [];
    if (avatar.isNotEmpty) {
      allImages.add(avatar);
    }
    allImages.addAll(photos);

    return Candidate(
      id: fromUserId,
      name: name,
      age: age,
      bio: bio ?? '',
      avatar: avatar,
      location: null, // Location not provided
      distanceKm: distanceKm,
      hobbies: hobbies?.split(',').map((e) => e.trim()).toList(),
      images: allImages.isNotEmpty ? allImages : null,
    );
  }
}
