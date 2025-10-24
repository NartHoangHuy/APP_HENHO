import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_profile.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.111:8000/api/users/';

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 201;
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access']; // JWT token hoặc token từ backend
    }
    return null;
  }

  // Đăng nhập bằng Google sử dụng idToken
  Future<Map<String, dynamic>?> googleSignIn(String idToken) async {
    final response = await http.post(
      Uri.parse('${baseUrl}google-signin/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<UserProfile?> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${baseUrl}profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> updateProfile(String token, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${baseUrl}profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
}
