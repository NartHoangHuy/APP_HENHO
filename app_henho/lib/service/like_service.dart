import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/like.dart';

// Service xử lý các tính năng liên quan đến lượt thích
class LikeService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

  // Lấy danh sách những người đã thích bạn
  Future<List<Like>> getLikesList(String token, {int page = 1}) async {
    try {
      final uri = Uri.parse(
        '${baseUrl}likes/',
      ).replace(queryParameters: {'page': page.toString()});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => Like.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting likes list: $e');
      return [];
    }
  }

  // Thích lại người đã thích bạn (có thể tạo match)
  Future<Map<String, dynamic>?> likeBack(String token, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}likes/like_back/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend trả về: { "matched": true/false, "match_id": ... }
        return data;
      }
      return null;
    } catch (e) {
      print('Error liking back: $e');
      return null;
    }
  }

  // Bỏ qua (xóa) một lượt thích
  Future<bool> removeLike(String token, int likeId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}likes/$likeId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 204; // 204 No Content = success
    } catch (e) {
      print('Error removing like: $e');
      return false;
    }
  }
}
