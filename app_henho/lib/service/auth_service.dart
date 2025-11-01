import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_profile.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

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

  Future<bool> registerWithConfirm(
    String username,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    try {
      print('📝 Registering user: $username, $email');
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
        }),
      );

      print('📡 Register response status: ${response.statusCode}');
      print('📦 Register response body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Registration successful');
        return true;
      } else {
        // Parse error from backend
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Registration errors: $errorData');
        } catch (e) {
          print('❌ Raw error: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      print('❌ Registration exception: $e');
      return false;
    }
  }

  Future<String?> login(String email, String password) async {
    print('🔐 Logging in with email: $email');
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('📡 Login response status: ${response.statusCode}');
    print('📦 Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access'];
      print('✅ Token received: $token');
      return token; // JWT token hoặc token từ backend
    }
    print('❌ Login failed');
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
    print(
      '🔑 Token being sent: ${token.substring(0, 50)}... (length: ${token.length})',
    );
    print('🔑 Full token: $token');

    final response = await http.get(
      Uri.parse('${baseUrl}profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('📡 Profile Response status: ${response.statusCode}');
    print('📦 Profile Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Profile loaded successfully');
      return UserProfile.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      print('❌ 401 Unauthorized - Token không hợp lệ hoặc đã hết hạn');
      print(
        '⚠️ Token format check: starts with "ey"? ${token.startsWith("ey")}',
      );
      // DON'T AUTO LOGOUT - Let user manually logout if needed
    } else {
      print('❌ Unexpected status: ${response.statusCode}');
    }
    return null;
  }

  Future<bool> updateProfile(String token, Map<String, dynamic> data) async {
    try {
      print('🔧 Updating profile with data: $data');
      final response = await http.put(
        Uri.parse('${baseUrl}profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 400) {
        // Parse error details
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Validation errors: $errorData');
        } catch (e) {
          print('❌ Raw error: ${response.body}');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  Future<bool> updateProfileWithAvatar(
    String token,
    Map<String, dynamic> data,
    String? avatarPath, {
    List<String>? photoPaths,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${baseUrl}profile/'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add avatar if provided
      if (avatarPath != null && avatarPath.isNotEmpty) {
        var file = await http.MultipartFile.fromPath('avatar', avatarPath);
        request.files.add(file);
        print('📷 Adding avatar: $avatarPath');
      }

      // Add additional photos if provided (photo_1 to photo_5)
      if (photoPaths != null && photoPaths.isNotEmpty) {
        for (int i = 0; i < photoPaths.length && i < 5; i++) {
          if (photoPaths[i].isNotEmpty) {
            var file = await http.MultipartFile.fromPath(
              'photo_${i + 1}',
              photoPaths[i],
            );
            request.files.add(file);
            print('📸 Adding photo_${i + 1}: ${photoPaths[i]}');
          }
        }
      }

      print('🔧 Updating profile with multipart data');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Validation errors: $errorData');
        } catch (e) {
          print('❌ Raw error: ${response.body}');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error updating profile with avatar: $e');
      return false;
    }
  }
}
