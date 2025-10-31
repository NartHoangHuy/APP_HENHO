import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service để xử lý tất cả các tính năng liên quan đến vị trí
class LocationService {
  /// Kiểm tra và request permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check xem location service đã bật chưa
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Lấy vị trí hiện tại của user
  Future<Position?> getCurrentPosition() async {
    try {
      // Check location service
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location service disabled');
        return null;
      }

      // Check permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied');
        return null;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('✅ Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting position: $e');
      return null;
    }
  }

  /// Convert tọa độ thành địa chỉ (reverse geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Format địa chỉ Việt Nam
        final parts = <String>[];

        if (place.street?.isNotEmpty == true) parts.add(place.street!);
        if (place.subAdministrativeArea?.isNotEmpty == true) {
          parts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          parts.add(place.administrativeArea!);
        }
        if (place.country?.isNotEmpty == true) parts.add(place.country!);

        final address = parts.join(', ');
        print('✅ Address: $address');
        return address;
      }
      return null;
    } catch (e) {
      print('❌ Error getting address: $e');
      return null;
    }
  }

  /// Lấy tên thành phố từ tọa độ
  Future<String?> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Ưu tiên lấy administrativeArea (Tỉnh/Thành phố)
        final rawCity = place.administrativeArea ?? place.subAdministrativeArea;

        if (rawCity != null) {
          // Chuẩn hóa tên thành phố để khớp với database
          return _normalizeCityName(rawCity);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting city: $e');
      return null;
    }
  }

  /// Chuẩn hóa tên thành phố để khớp với database
  String _normalizeCityName(String rawCity) {
    // Map các tên thành phố phổ biến
    final cityMap = {
      'Hanoi': 'Hà Nội',
      'Ha Noi': 'Hà Nội',
      'Hà Nội': 'Hà Nội',
      'Ho Chi Minh': 'TP. Hồ Chí Minh',
      'Ho Chi Minh City': 'TP. Hồ Chí Minh',
      'Hồ Chí Minh': 'TP. Hồ Chí Minh',
      'Thành phố Hồ Chí Minh': 'TP. Hồ Chí Minh',
      'Da Nang': 'Đà Nẵng',
      'Đà Nẵng': 'Đà Nẵng',
      'Hai Phong': 'Hải Phòng',
      'Hải Phòng': 'Hải Phòng',
      'Can Tho': 'Cần Thơ',
      'Cần Thơ': 'Cần Thơ',
      'Bien Hoa': 'Biên Hòa',
      'Biên Hòa': 'Biên Hòa',
      'Nha Trang': 'Nha Trang',
      'Hue': 'Huế',
      'Huế': 'Huế',
      'Vung Tau': 'Vũng Tàu',
      'Vũng Tàu': 'Vũng Tàu',
    };

    // Kiểm tra trong map
    if (cityMap.containsKey(rawCity)) {
      print('✅ Normalized: $rawCity -> ${cityMap[rawCity]}');
      return cityMap[rawCity]!;
    }

    // Nếu không có trong map, thử xóa "Tỉnh" hoặc "Thành phố" prefix
    String normalized = rawCity
        .replaceAll('Tỉnh ', '')
        .replaceAll('Thành phố ', '')
        .replaceAll('TP. ', '')
        .trim();

    print('✅ Normalized: $rawCity -> $normalized');
    return normalized;
  }

  /// Convert địa chỉ thành tọa độ (forward geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      print('❌ Error getting coordinates: $e');
      return null;
    }
  }

  /// Tính khoảng cách giữa 2 vị trí (km)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distanceInMeters / 1000; // Convert to km
  }

  /// Get location với retry logic
  Future<Position?> getCurrentPositionWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final position = await getCurrentPosition();
        if (position != null) return position;

        // Wait before retry
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(seconds: i + 1));
        }
      } catch (e) {
        print('❌ Retry $i failed: $e');
      }
    }
    return null;
  }

  /// Stream vị trí realtime (cho features như tracking)
  Stream<Position> getPositionStream({
    int intervalDuration = 10,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter, // meters
      ),
    );
  }
}
