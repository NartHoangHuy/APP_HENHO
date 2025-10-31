import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hobby.dart';

/// Service để lấy danh sách hobbies từ backend
class HobbyService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

  /// Lấy danh sách tất cả hobbies
  /// Không cần token vì API public
  Future<List<Hobby>> getHobbies() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}hobbies/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hobby.fromJson(json)).toList();
      }

      print('❌ Error loading hobbies: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Exception loading hobbies: $e');
      return [];
    }
  }
}
