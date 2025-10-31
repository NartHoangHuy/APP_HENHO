// Model đại diện cho một tin nhắn chat
class Message {
  final String id; // Firebase key
  final int senderId;
  final int receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl; // Ảnh đính kèm (nếu có)

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  // Chuyển đổi từ Firebase Realtime Database snapshot
  factory Message.fromJson(String key, Map<String, dynamic> json) {
    return Message(
      id: key,
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
      imageUrl: json['image_url'],
    );
  }

  // Chuyển đổi sang JSON để lưu vào Firebase
  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
    };
  }

  // Tạo bản sao với các thuộc tính được cập nhật
  Message copyWith({
    String? id,
    int? senderId,
    int? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
