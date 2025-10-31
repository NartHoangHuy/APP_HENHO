import 'package:flutter/material.dart';

// Màu sắc chủ đạo của ứng dụng
class AppColors {
  // Màu chính
  static const Color primary = Color(0xFFE94057); // Đỏ hồng
  static const Color primaryDark = Color(0xFFD02040);
  static const Color primaryLight = Color(0xFFFF6B7A);

  // Màu gradient
  static const Color gradientStart = Color(0xFFE94057);
  static const Color gradientEnd = Color(0xFFF27121);

  // Màu accent
  static const Color accent = Color(0xFFF27121); // Cam
  static const Color accentLight = Color(0xFFFFB088);

  // Màu nền
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Màu text
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFFAAAAAA);

  // Màu trạng thái
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Màu border
  static const Color border = Color(0xFFE8E8E8);
  static const Color divider = Color(0xFFEEEEEE);

  // Màu nút
  static const Color likeButton = Color(0xFF4CAF50);
  static const Color dislikeButton = Color(0xFFE8E8E8);
  static const Color superLikeButton = Color(0xFF2196F3);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFF5F5), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Khoảng cách và padding chuẩn
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Bo góc chuẩn
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 100.0;
}

// Kích thước icon
class AppIconSize {
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
}

// Text styles
class AppTextStyles {
  // Heading
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
}

// Shadow
class AppShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

// Animation duration
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
