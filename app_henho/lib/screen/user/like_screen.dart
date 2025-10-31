import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/like.dart';
import '../../widgets/like_card.dart';
import '../../providers/like_provider.dart';
import '../../providers/match_provider.dart';
import 'candidate_detail_screen.dart';

// Màn hình hiển thị danh sách những người đã thích bạn
class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  @override
  void initState() {
    super.initState();
    // Load likes when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LikeProvider>().loadLikes();
    });
  }

  // Thích lại người đã thích bạn
  Future<void> _likeBack(Like like) async {
    try {
      final likeProvider = context.read<LikeProvider>();
      final result = await likeProvider.likeBack(like.fromUserId);

      if (result != null) {
        // Nếu match, hiển thị thông báo
        if (result['matched'] == true) {
          // Load matches trước khi show dialog
          final matchProvider = context.read<MatchProvider>();
          await matchProvider.loadMatches();

          if (mounted) {
            _showMatchDialog(like);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã thích lại ${like.name}!')),
            );
          }
        }
      }
    } catch (e) {
      print('Error liking back: $e');
    }
  }

  // Bỏ qua một lượt thích
  Future<void> _ignore(Like like) async {
    try {
      final likeProvider = context.read<LikeProvider>();
      final success = await likeProvider.removeLike(like.id);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã bỏ qua ${like.name}.')));
      }
    } catch (e) {
      print('Error ignoring: $e');
    }
  }

  // Hiển thị chi tiết người dùng - Navigate to CandidateDetailScreen
  void _showDetails(Like like) {
    // Convert Like to Candidate and navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateDetailScreen(
          candidate: like.toCandidate(),
          // Don't pass controller - user can't swipe from detail
        ),
      ),
    );
  }

  // Hiển thị dialog match với modern design
  void _showMatchDialog(Like like) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink.shade50, Colors.purple.shade50],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated heart
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade400, Colors.pink.shade600],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'It\'s a Match!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn và ${like.name} đã thích nhau!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade400, Colors.pink.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog

                          // Navigate to Chat tab (index 2 trong home_screen)
                          // Use Navigator.popUntil để về home screen
                          Navigator.popUntil(context, (route) => route.isFirst);

                          // TODO: Cần add callback để switch sang Chat tab
                          // Hoặc navigate trực tiếp đến ChatDetailScreen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Nhắn tin',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch LikeProvider
    final likeProvider = context.watch<LikeProvider>();
    final likes = likeProvider.likes;
    final isLoading = likeProvider.isLoading;

    if (isLoading && likes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Đang tải...',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<LikeProvider>().refresh(),
        color: Colors.pink.shade400,
        child: Column(
          children: [
            // Modern Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade50, Colors.purple.shade50],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.pink.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Người đã thích bạn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${likes.length} người',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách
            Expanded(
              child: likes.isEmpty
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
                                Icons.favorite_border,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Chưa có ai thích bạn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hãy hoàn thiện hồ sơ và tiếp tục khám phá',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: likes.length,
                      itemBuilder: (context, index) {
                        final like = likes[index];
                        return Dismissible(
                          key: ValueKey(like.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade300,
                                  Colors.red.shade500,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          onDismissed: (_) => _ignore(like),
                          child: LikeCard(
                            like: like,
                            onLikeBack: () => _likeBack(like),
                            onIgnore: () => _ignore(like),
                            onTap: () => _showDetails(like),
                          ),
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
