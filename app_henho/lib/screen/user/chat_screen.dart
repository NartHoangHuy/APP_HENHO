import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/match.dart';
import '../../service/match_service.dart';
import '../../widgets/match_card.dart';
import 'chat_detail_screen.dart';

// Màn hình hiển thị danh sách match và chat
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MatchService _matchService = MatchService();
  List<Match> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  // Tải danh sách matches từ API
  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final matches = await _matchService.getMatchesList(token);

        // Sắp xếp: tin nhắn chưa đọc lên trước, sau đó theo thời gian
        matches.sort((a, b) {
          if (a.hasUnreadMessages && !b.hasUnreadMessages) return -1;
          if (!a.hasUnreadMessages && b.hasUnreadMessages) return 1;

          final timeA = a.lastMessageTime ?? a.matchedAt;
          final timeB = b.lastMessageTime ?? b.matchedAt;
          return timeB.compareTo(timeA);
        });

        setState(() {
          _matches = matches;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading matches: $e');
      setState(() => _isLoading = false);
    }
  }

  // Mở màn hình chat chi tiết
  void _openChat(Match match) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(match: match)),
    );
    // Reload sau khi quay lại để cập nhật trạng thái đã đọc
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Đang tải cuộc trò chuyện...',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadMatches,
        color: Colors.pink.shade400,
        child: Column(
          children: [
            // Modern search bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cuộc trò chuyện...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),

            // Danh sách matches
            Expanded(
              child: _matches.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.pink.shade100.withOpacity(0.3),
                                    Colors.purple.shade100.withOpacity(0.3),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Chưa có cuộc trò chuyện',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Khi bạn match với ai đó,\ncuộc trò chuyện sẽ xuất hiện ở đây',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _matches.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 80,
                        endIndent: 16,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        return MatchCard(
                          match: match,
                          onTap: () => _openChat(match),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
