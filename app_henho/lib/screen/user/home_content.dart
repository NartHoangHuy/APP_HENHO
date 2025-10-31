import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../model/candidate.dart';
import '../../service/discover_service.dart';
import '../../widgets/candidate_card.dart';
import '../../widgets/match_dialog.dart';
import '../../providers/filter_provider.dart';

// Màn hình chính hiển thị các thẻ profile để swipe
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final CardSwiperController _controller = CardSwiperController();
  final DiscoverService _discoverService = DiscoverService();

  List<Candidate> _candidates = [];
  bool _isLoading = true;
  int _currentPage = 1;

  // Track current filter to detect changes
  String? _currentFilterMode;
  String? _currentFilterHobby;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read (not watch!) for filter changes from Provider
    // Using watch here causes infinite loop because didChangeDependencies
    // is called every time Provider changes
    final filterProvider = context.read<FilterProvider>();
    final newFilterMode = filterProvider.filterMode;
    final newFilterHobby = filterProvider.filterHobby;

    // Reload if filter changed
    if (newFilterMode != _currentFilterMode ||
        newFilterHobby != _currentFilterHobby) {
      print('🔄 Filter changed! Reloading candidates...');
      print('   Old: mode=$_currentFilterMode, hobby=$_currentFilterHobby');
      print('   New: mode=$newFilterMode, hobby=$newFilterHobby');

      // Update tracking BEFORE reload to prevent multiple calls
      _currentFilterMode = newFilterMode;
      _currentFilterHobby = newFilterHobby;

      _loadCandidates(reset: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Tải danh sách người dùng để swipe từ API với filters từ Provider
  Future<void> _loadCandidates({bool reset = false}) async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        // Get filter from Provider
        final filterProvider = context.read<FilterProvider>();
        final filterMode = filterProvider.filterMode;
        final filterHobby = filterProvider.filterHobby;

        // Reset candidates if filter changed or explicit reset
        if (reset) {
          _candidates.clear();
          _currentPage = 1;
        }

        final candidates = await _discoverService.getDiscoverList(
          token,
          page: _currentPage,
          mode: filterMode, // 'all' or null from Provider
          hobby: filterHobby, // hobby name or null from Provider
        );

        setState(() {
          _candidates.addAll(candidates);
          _isLoading = false;
        });

        // Debug log
        print(
          '🎯 Loaded candidates with filter: mode=$filterMode, hobby=$filterHobby',
        );
        print('   Total candidates: ${_candidates.length}');
      }
    } catch (e) {
      print('Error loading candidates: $e');
      setState(() => _isLoading = false);
    }
  }

  // Xử lý sự kiện swipe
  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final candidate = _candidates[previousIndex];
    final action = direction == CardSwiperDirection.right ? 'like' : 'dislike';

    // Gửi hành động lên server
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final result = await _discoverService.swipe(
          token,
          candidate.id,
          action,
        );

        // Nếu match, hiển thị dialog
        if (result != null && result['matched'] == true) {
          _showMatchDialog(candidate);
        }
      }
    } catch (e) {
      print('Error swiping: $e');
    }

    // Nếu sắp hết card, load thêm
    if (currentIndex != null && _candidates.length - currentIndex <= 2) {
      _currentPage++;
      _loadCandidates();
    }

    return true;
  }

  // Hiển thị dialog khi match với Match Dialog component
  void _showMatchDialog(Candidate candidate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        matchedUser: candidate,
        onSendMessage: () {
          // TODO: Navigate to chat screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chức năng chat đang phát triển')),
          );
        },
        onKeepSwiping: () {
          // Just close dialog and continue swiping
        },
      ),
    );
  }

  // Build modern action button
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 56,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(icon, color: color, size: size * 0.45),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _candidates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_candidates.isEmpty) {
      return Center(
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
                  Icons.person_search,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Không còn người dùng mới',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy quay lại sau để khám phá thêm người mới',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Container(
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
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Tải lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPage = 1;
                      _candidates.clear();
                    });
                    _loadCandidates();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Watch filter for UI display
    final filterProvider = context.watch<FilterProvider>();

    return SafeArea(
      child: Column(
        children: [
          // Filter indicator chip (if active)
          if (filterProvider.hasActiveFilter)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade100, Colors.purple.shade100],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_alt, color: Colors.pink.shade700, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    filterProvider.filterDisplayText,
                    style: TextStyle(
                      color: Colors.pink.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      filterProvider.clearFilter();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa bộ lọc')),
                      );
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.pink.shade700,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

          // Card swiper
          Flexible(
            child: CardSwiper(
              controller: _controller,
              cardsCount: _candidates.length,
              onSwipe: _onSwipe,
              // Ensure numberOfCardsDisplayed is at least 1 and at most cardsCount
              numberOfCardsDisplayed: _candidates.length >= 3
                  ? 3
                  : _candidates.length,
              backCardOffset: const Offset(40, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              cardBuilder: (context, index, _, __) {
                return CandidateCard(
                  candidate: _candidates[index],
                  controller: _controller,
                );
              },
            ),
          ),

          // Các nút điều khiển với modern design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút Undo
                  _buildActionButton(
                    icon: Icons.rotate_left,
                    color: Colors.amber.shade400,
                    onPressed: _controller.undo,
                    size: 46,
                  ),
                  const SizedBox(width: 10),

                  // Nút Dislike
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.red.shade400,
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.left),
                    size: 54,
                  ),
                  const SizedBox(width: 10),

                  // Nút Super Like
                  _buildActionButton(
                    icon: Icons.star,
                    color: Colors.blue.shade400,
                    onPressed: () => _controller.swipe(CardSwiperDirection.top),
                    size: 46,
                  ),
                  const SizedBox(width: 10),

                  // Nút Like
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: Colors.pink.shade400,
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.right),
                    size: 54,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
