import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/match.dart';

// Service xử lý các tính năng liên quan đến match (cặp đôi)
class MatchService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

  // Lấy danh sách các match (những người đã match với bạn)
  Future<List<Match>> getMatchesList(String token, {int page = 1}) async {
    try {
      final uri = Uri.parse(
        '${baseUrl}matches/',
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

        print('🔥🔥🔥 [MATCH_SERVICE] ===== LOADED MATCHES FROM API =====');
        print('🔥 [MATCH_SERVICE] Total matches: ${results.length}');

        final matches = results.map((json) {
          print('🔥 [MATCH_SERVICE] Processing match:');
          print('   - Match ID: ${json['id']}');
          print('   - other_user: ${json['other_user']}');
          print('   - other_user_name: ${json['other_user_name']}');
          print('   - user_id fallback: ${json['user_id']}');
          return Match.fromJson(json);
        }).toList();

        print('🔥 [MATCH_SERVICE] ===== FINAL MATCH LIST =====');
        for (var match in matches) {
          print('   Match: userId=${match.userId}, name=${match.name}');
        }

        return matches;
      }
      return [];
    } catch (e) {
      print('❌ [MATCH_SERVICE] Error getting matches list: $e');
      return [];
    }
  }

  // Xóa một match (unmatch)
  Future<bool> unmatch(String token, int matchId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}matches/$matchId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error unmatching: $e');
      return false;
    }
  }

  // Lấy thông tin chi tiết một match
  Future<Match?> getMatchDetail(String token, int matchId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}matches/$matchId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Match.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error getting match detail: $e');
      return null;
    }
  }
}
