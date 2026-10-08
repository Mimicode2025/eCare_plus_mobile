import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppDecor {
  static const primaryDark = AppColors.primary;

  static const gradient = LinearGradient(
    colors: [AppColors.primary, Color(0xFF3BBFF3)],
  );

  static TextStyle t(
    double size, {
    FontWeight w = FontWeight.w400,
    Color c = AppColors.textDark,
    double? h,
  }) => AppTextStyles.body.copyWith(
    fontSize: size,
    fontWeight: w,
    color: c,
    height: h,
  );

  static List<BoxShadow> shadow([double opacity = .08]) => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: opacity),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}
