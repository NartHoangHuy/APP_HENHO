import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/like.dart';
import '../service/like_service.dart';

/// Provider quản lý danh sách người đã thích mình
class LikeProvider extends ChangeNotifier {
  final LikeService _likeService = LikeService();

  List<Like> _likes = [];
  bool _isLoading = false;
  String? _error;

  List<Like> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get likeCount => _likes.length;

  /// Load danh sách người đã thích
  Future<void> loadLikes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        _likes = await _likeService.getLikesList(token);
        print('❤️ LikeProvider: Loaded ${_likes.length} likes');
      }
    } catch (e) {
      _error = 'Error loading likes: $e';
      print('❌ LikeProvider: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Like lại người đã thích mình
  Future<Map<String, dynamic>?> likeBack(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final result = await _likeService.likeBack(token, userId);

        // Remove from likes list after like back
        if (result != null) {
          _likes.removeWhere((like) => like.fromUserId == userId);
          print('❤️ LikeProvider: Liked back user $userId, removed from list');
          notifyListeners();
        }

        return result;
      }
    } catch (e) {
      print('❌ LikeProvider: Error liking back: $e');
    }
    return null;
  }

  /// Xóa một like (ignore)
  Future<bool> removeLike(int likeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final success = await _likeService.removeLike(token, likeId);

        if (success) {
          _likes.removeWhere((like) => like.id == likeId);
          print('❤️ LikeProvider: Removed like $likeId');
          notifyListeners();
        }

        return success;
      }
    } catch (e) {
      print('❌ LikeProvider: Error removing like: $e');
    }
    return false;
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    await loadLikes();
  }

  /// Reset state
  void reset() {
    _likes = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
