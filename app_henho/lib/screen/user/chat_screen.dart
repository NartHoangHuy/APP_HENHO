import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/match.dart';
import '../../widgets/realtime_match_card.dart';
import '../../providers/match_provider.dart';
import 'chat_detail_screen.dart';

// Màn hình hiển thị danh sách match và chat
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load matches when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadMatches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mở màn hình chat chi tiết
  void _openChat(Match match) async {
    print('🔥🔥🔥 [CHAT_SCREEN] ===== OPENING CHAT =====');
    print('🔥 [CHAT_SCREEN] Match ID: ${match.id}');
    print('🔥 [CHAT_SCREEN] Match userId: ${match.userId}');
    print('🔥 [CHAT_SCREEN] Match name: ${match.name}');
    print('🔥 [CHAT_SCREEN] Match age: ${match.age}');
    print('🔥 [CHAT_SCREEN] Match avatar: ${match.avatar}');
    print('🔥 [CHAT_SCREEN] Last message: ${match.lastMessage}');

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(match: match)),
    );
    // Reload sau khi quay lại để cập nhật trạng thái đã đọc
    if (mounted) {
      context.read<MatchProvider>().refresh();
    }
  }

  // Lọc matches theo search query
  List<Match> _filterMatches(List<Match> matches) {
    if (_searchQuery.isEmpty) {
      return matches;
    }

    final query = _searchQuery.toLowerCase();
    return matches.where((match) {
      final name = match.name.toLowerCase();
      final lastMessage = match.lastMessage?.toLowerCase() ?? '';
      return name.contains(query) || lastMessage.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch MatchProvider
    final matchProvider = context.watch<MatchProvider>();
    final matches = matchProvider.matches;
    final isLoading = matchProvider.isLoading;

    // Filter matches by search query
    final filteredMatches = _filterMatches(matches);

    // Sort matches: unread messages first, then by time
    final sortedMatches = List<Match>.from(filteredMatches);
    sortedMatches.sort((a, b) {
      if (a.hasUnreadMessages && !b.hasUnreadMessages) return -1;
      if (!a.hasUnreadMessages && b.hasUnreadMessages) return 1;

      final timeA = a.lastMessageTime ?? a.matchedAt;
      final timeB = b.lastMessageTime ?? b.matchedAt;
      return timeB.compareTo(timeA);
    });

    if (isLoading && matches.isEmpty) {
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
        onRefresh: () => matchProvider.refresh(),
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
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tên hoặc tin nhắn...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
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
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  // Hiển thị số kết quả tìm kiếm
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tìm thấy ${sortedMatches.length} kết quả',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Danh sách matches
            Expanded(
              child: sortedMatches.isEmpty
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
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Không tìm thấy kết quả'
                                  : 'Chưa có cuộc trò chuyện',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Không có cuộc trò chuyện nào khớp với\n"$_searchQuery"'
                                  : 'Khi bạn match với ai đó,\ncuộc trò chuyện sẽ xuất hiện ở đây',
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
                      itemCount: sortedMatches.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 80,
                        endIndent: 16,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final match = sortedMatches[index];
                        return RealtimeMatchCard(
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
