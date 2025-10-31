import 'package:flutter/material.dart';

/// Provider quản lý filter state cho Discover/Home screens
///
/// Sử dụng:
/// ```dart
/// // Set filter
/// context.read<FilterProvider>().setFilter(mode: 'all');
///
/// // Watch filter changes
/// final filter = context.watch<FilterProvider>();
/// ```
class FilterProvider extends ChangeNotifier {
  String? _filterMode; // 'all' for "Kết bạn bốn phương"
  String? _filterHobby; // Hobby name to filter

  String? get filterMode => _filterMode;
  String? get filterHobby => _filterHobby;

  /// Check if any filter is active
  bool get hasActiveFilter => _filterMode != null || _filterHobby != null;

  /// Get display text for current filter
  String get filterDisplayText {
    if (_filterMode == 'all') return 'Kết bạn bốn phương';
    if (_filterHobby != null) return _filterHobby!;
    return 'Tất cả';
  }

  /// Set filter with mode OR hobby (not both)
  void setFilter({String? mode, String? hobby}) {
    if (mode != null) {
      _filterMode = mode;
      _filterHobby = null;
      print('🎯 FilterProvider: Set mode=$mode');
    } else if (hobby != null) {
      _filterMode = null;
      _filterHobby = hobby;
      print('🎯 FilterProvider: Set hobby=$hobby');
    }
    notifyListeners();
  }

  /// Clear all filters
  void clearFilter() {
    _filterMode = null;
    _filterHobby = null;
    print('🎯 FilterProvider: Cleared filters');
    notifyListeners();
  }

  /// Reset to default (no filters)
  void reset() {
    clearFilter();
  }
}
