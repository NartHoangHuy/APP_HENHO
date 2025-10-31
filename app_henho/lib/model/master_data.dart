class City {
  final int id;
  final String name;
  final int displayOrder;

  City({required this.id, required this.name, required this.displayOrder});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      displayOrder: json['display_order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'display_order': displayOrder};
  }
}

class Hobby {
  final int id;
  final String name;
  final String? icon;
  final int displayOrder;

  Hobby({
    required this.id,
    required this.name,
    this.icon,
    required this.displayOrder,
  });

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      displayOrder: json['display_order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'display_order': displayOrder,
    };
  }

  String get displayName => icon != null ? '$icon $name' : name;
}
