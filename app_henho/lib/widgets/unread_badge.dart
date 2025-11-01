import 'package:flutter/material.dart';

/// Widget hiển thị badge số lượng tin nhắn chưa đọc
class UnreadBadge extends StatelessWidget {
  final int count;
  final double size;

  const UnreadBadge({super.key, required this.count, this.size = 20});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.4,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(size * 0.6),
      ),
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
