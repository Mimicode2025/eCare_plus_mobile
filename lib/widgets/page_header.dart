import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

/// Shared heading for patient pages and authentication screens.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? leading;
  final Widget? action;
  final Color titleColor;
  final Color subtitleColor;
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.leading,
    this.action,
    this.titleColor = AppColors.textDark,
    this.subtitleColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final prefix =
        leading ??
        (showBack && Navigator.canPop(context) ? const PageBackButton() : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (prefix != null) ...[prefix, const SizedBox(width: 12)],
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppDecor.t(
                    25,
                    w: FontWeight.w700,
                    c: titleColor,
                    h: 1.25,
                  ),
                ),
              ),
            ),
            if (action != null) ...[const SizedBox(width: 8), action!],
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: AppDecor.t(13, c: subtitleColor, h: 1.6)),
        ],
      ],
    );
  }
}

class PageBackButton extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  const PageBackButton({
    super.key,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.primaryLighter,
  });
  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: 'Retour',
    style: IconButton.styleFrom(
      minimumSize: const Size(48, 48),
      backgroundColor: backgroundColor,
      foregroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: () => Navigator.maybePop(context),
    icon: const Icon(Icons.arrow_back_rounded, size: 22),
  );
}
