import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/match.dart';
import '../service/match_service.dart';

/// Provider quản lý danh sách matches
class MatchProvider extends ChangeNotifier {
  final MatchService _matchService = MatchService();

  List<Match> _matches = [];
  bool _isLoading = false;
  String? _error;

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get matchCount => _matches.length;

  /// Load danh sách matches
  Future<void> loadMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        _matches = await _matchService.getMatchesList(token);
        print('💘 MatchProvider: Loaded ${_matches.length} matches');
      }
    } catch (e) {
      _error = 'Error loading matches: $e';
      print('❌ MatchProvider: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm match mới (called when match happens)
  void addMatch(Match match) {
    _matches.insert(0, match); // Add to beginning
    print('💘 MatchProvider: Added new match with ${match.name}');
    notifyListeners();
  }

  /// Unmatch (xóa match)
  Future<bool> removeMatch(int matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final success = await _matchService.unmatch(token, matchId);

        if (success) {
          _matches.removeWhere((match) => match.id == matchId);
          print('💘 MatchProvider: Removed match $matchId');
          notifyListeners();
        }

        return success;
      }
    } catch (e) {
      print('❌ MatchProvider: Error removing match: $e');
    }
    return false;
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    await loadMatches();
  }

  /// Reset state
  void reset() {
    _matches = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
