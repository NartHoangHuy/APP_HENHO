class UserProfile {
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final String? gender;
  final String? birthday;
  final String? location;
  final int? age;
  final String? hobbies;

  UserProfile({
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    this.gender,
    this.birthday,
    this.location,
    this.age,
    this.hobbies,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      bio: json['bio'],
      gender: json['gender'],
      birthday: json['birthday'],
      location: json['location'],
      age: json['age'],
      hobbies: json['hobbies'],
    );
  }
}
