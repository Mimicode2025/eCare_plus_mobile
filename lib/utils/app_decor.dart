import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppDecor {
  static const primaryDark = AppColors.primaryDeep;

  static const gradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryAccent],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.primaryDeep,
      AppColors.primaryAccent,
      AppColors.primaryBright,
    ],
    stops: [0, .6, 1],
  );

  static Widget buttonBackground(
    BuildContext context,
    Set<WidgetState> states,
    Widget? child,
  ) => states.contains(WidgetState.disabled)
      ? child ?? const SizedBox.shrink()
      : Ink(
          decoration: const BoxDecoration(gradient: buttonGradient),
          child: child,
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
