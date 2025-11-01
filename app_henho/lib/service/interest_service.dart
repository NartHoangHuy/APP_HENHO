import 'dart:convert';
import 'package:http/http.dart' as http;

class InterestService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

  /// Add an interest to user's interested_in array
  Future<bool> addInterest(String token, String interest) async {
    try {
      print(
        '📤 Adding interest: "$interest" with token: ${token.substring(0, 20)}...',
      );

      final response = await http.post(
        Uri.parse('${baseUrl}interests/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'interest': interest}),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Interest "$interest" added successfully');
        return true;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Token may be expired');
        return false;
      } else {
        print(
          '❌ Failed to add interest: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error adding interest: $e');
      return false;
    }
  }

  /// Remove an interest from user's interested_in array
  Future<bool> removeInterest(String token, String interest) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}interests/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'interest': interest}),
      );

      if (response.statusCode == 200) {
        print('✅ Interest "$interest" removed successfully');
        return true;
      } else {
        print(
          '❌ Failed to remove interest: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error removing interest: $e');
      return false;
    }
  }
}
