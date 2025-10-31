import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/candidate.dart';

// Service xử lý các tính năng khám phá và swipe người dùng
class DiscoverService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

  // Lấy danh sách người dùng để swipe (discover)
  // Parameters:
  // - token: JWT token để xác thực
  // - page: Trang hiện tại (phân trang)
  // - mode: 'all' cho "Kết bạn bốn phương" (optional)
  // - hobby: Lọc theo sở thích cụ thể (optional)
  // - gender: Lọc theo giới tính (optional)
  // - minAge, maxAge: Lọc theo độ tuổi (optional)
  Future<List<Candidate>> getDiscoverList(
    String token, {
    int page = 1,
    String? mode,
    String? hobby,
    String? gender,
    int? minAge,
    int? maxAge,
  }) async {
    try {
      // Tạo query parameters
      final queryParams = {
        'page': page.toString(),
        if (mode != null) 'mode': mode,
        if (hobby != null) 'hobby': hobby,
        if (gender != null) 'gender': gender,
        if (minAge != null) 'min_age': minAge.toString(),
        if (maxAge != null) 'max_age': maxAge.toString(),
      };

      final uri = Uri.parse(
        '${baseUrl}discover/',
      ).replace(queryParameters: queryParams);

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
        return results.map((json) => Candidate.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting discover list: $e');
      return [];
    }
  }

  // Gửi hành động swipe (like hoặc dislike)
  // Parameters:
  // - token: JWT token
  // - targetUserId: ID của người được swipe
  // - action: 'like' hoặc 'dislike'
  Future<Map<String, dynamic>?> swipe(
    String token,
    int targetUserId,
    String action,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}discover/swipe/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'target_user_id': targetUserId,
          'action': action, // 'like' hoặc 'dislike'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend trả về: { "matched": true/false, "match_id": ... }
        return data;
      }
      return null;
    } catch (e) {
      print('Error swiping: $e');
      return null;
    }
  }
}
