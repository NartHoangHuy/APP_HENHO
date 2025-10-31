// Model đại diện cho một lượt thích từ người khác
class Like {
  final int id;
  final int fromUserId; // ID của người thích bạn
  final String name;
  final int age;
  final String avatar;
  final double distanceKm;
  final String? bio;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.fromUserId,
    required this.name,
    required this.age,
    required this.avatar,
    required this.distanceKm,
    this.bio,
    required this.createdAt,
  });

  // Chuyển đổi từ JSON response của backend
  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      fromUserId: json['from_user_id'],
      name: json['from_user_name'] ?? '',
      age: json['from_user_age'] ?? 0,
      avatar: json['from_user_avatar'] ?? '',
      distanceKm: json['distance_km']?.toDouble() ?? 0.0,
      bio: json['from_user_bio'],
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
      'from_user_avatar': avatar,
      'distance_km': distanceKm,
      'from_user_bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
