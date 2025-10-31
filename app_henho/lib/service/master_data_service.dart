import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/master_data.dart';

class MasterDataService {
  static const String baseUrl = 'http://192.168.1.61:8000/api/users/';

  /// Lấy danh sách thành phố từ backend
  Future<List<City>> getCities() async {
    try {
      print('🏙️  Fetching cities from API...');
      final response = await http.get(
        Uri.parse('${baseUrl}cities/'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Cities response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final cities = data.map((json) => City.fromJson(json)).toList();
        print('✅ Loaded ${cities.length} cities');
        return cities;
      } else {
        print('❌ Failed to load cities: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error loading cities: $e');
      return [];
    }
  }

  /// Lấy danh sách sở thích từ backend
  Future<List<Hobby>> getHobbies() async {
    try {
      print('❤️  Fetching hobbies from API...');
      final response = await http.get(
        Uri.parse('${baseUrl}hobbies/'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Hobbies response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final hobbies = data.map((json) => Hobby.fromJson(json)).toList();
        print('✅ Loaded ${hobbies.length} hobbies');
        return hobbies;
      } else {
        print('❌ Failed to load hobbies: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error loading hobbies: $e');
      return [];
    }
  }

  /// Cache cho cities (optional - để tránh gọi API nhiều lần)
  static List<City>? _cachedCities;

  Future<List<City>> getCitiesWithCache() async {
    if (_cachedCities != null && _cachedCities!.isNotEmpty) {
      print('📦 Using cached cities');
      return _cachedCities!;
    }
    _cachedCities = await getCities();
    return _cachedCities!;
  }

  /// Cache cho hobbies (optional)
  static List<Hobby>? _cachedHobbies;

  Future<List<Hobby>> getHobbiesWithCache() async {
    if (_cachedHobbies != null && _cachedHobbies!.isNotEmpty) {
      print('📦 Using cached hobbies');
      return _cachedHobbies!;
    }
    _cachedHobbies = await getHobbies();
    return _cachedHobbies!;
  }

  /// Clear cache (dùng khi cần refresh data)
  static void clearCache() {
    _cachedCities = null;
    _cachedHobbies = null;
    print('🗑️  Cache cleared');
  }
}
