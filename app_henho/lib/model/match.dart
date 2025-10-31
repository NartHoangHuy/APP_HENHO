// Model đại diện cho một cặp đôi match (2 người thích nhau)
class Match {
  final int id;
  final int userId; // ID của người còn lại trong match
  final String name;
  final int age;
  final String avatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime matchedAt;
  final bool hasUnreadMessages; // Có tin nhắn chưa đọc không

  Match({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.avatar,
    this.lastMessage,
    this.lastMessageTime,
    required this.matchedAt,
    this.hasUnreadMessages = false,
  });

  // Chuyển đổi từ JSON response của backend
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      userId: json['user_id'],
      name: json['user_name'] ?? '',
      age: json['user_age'] ?? 0,
      avatar: json['user_avatar'] ?? '',
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      matchedAt: DateTime.parse(json['matched_at']),
      hasUnreadMessages: json['has_unread_messages'] ?? false,
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': name,
      'user_age': age,
      'user_avatar': avatar,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'matched_at': matchedAt.toIso8601String(),
      'has_unread_messages': hasUnreadMessages,
    };
  }
}
