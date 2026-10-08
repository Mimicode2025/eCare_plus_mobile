import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';

class LegalSection {
  final String title, body;
  const LegalSection(this.title, this.body);
}

class LegalPage extends StatelessWidget {
  final String title, introduction;
  final IconData icon;
  final List<LegalSection> sections;
  const LegalPage({
    super.key,
    required this.title,
    required this.introduction,
    required this.icon,
    required this.sections,
  });
  @override
  Widget build(BuildContext context) => CarePage(
    title: title,
    subtitle: 'eCARE+ · Mise à jour du 8 octobre 2026',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CareCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 30),
              const SizedBox(height: 14),
              Text(
                'Version de développement',
                style: AppDecor.t(15, w: FontWeight.w700, c: AppColors.primary),
              ),
              const SizedBox(height: 8),
              SelectableText(
                introduction,
                style: AppDecor.t(13, c: AppColors.textMuted, h: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        for (final section in sections) ...[
          CareCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    section.title,
                    style: AppDecor.t(16, w: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  section.body,
                  style: AppDecor.t(13, c: AppColors.textMuted, h: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    ),
  );
}
