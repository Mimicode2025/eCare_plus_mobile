import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

/// Ligne commune aux menus de la conversation, dans les couleurs eCARE+.
class ChatMenuEntry extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool caution;
  const ChatMenuEntry({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.caution = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = caution ? const Color(0xFFB74A58) : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: caution
                    ? const Color(0xFFFBEFF1)
                    : AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppDecor.t(
                    13,
                    w: FontWeight.w600,
                    c: caution ? color : AppColors.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: AppDecor.t(11, c: AppColors.textMuted, h: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
