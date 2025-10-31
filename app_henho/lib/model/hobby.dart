/// Model cho Sở thích/Hobby
class Hobby {
  final int id;
  final String name;
  final String? icon;
  final int displayOrder;
  final bool isActive;

  Hobby({
    required this.id,
    required this.name,
    this.icon,
    required this.displayOrder,
    required this.isActive,
  });

  /// Parse từ JSON
  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return icon != null ? '$icon $name' : name;
  }
}
