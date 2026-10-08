import 'package:flutter/material.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});
  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  String _category = 'Tous';
  @override
  Widget build(BuildContext context) => CarePage(
    showBack: false,
    title: 'Articles des médecins',
    subtitle: 'Un espace pour les publications de vos professionnels de santé.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explorer par thème', style: AppDecor.t(15, w: FontWeight.w600)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in [
              'Tous',
              'Diabète',
              'Hypertension',
              'Bien-être',
            ])
              ChoiceChip(
                label: Text(category),
                selected: _category == category,
                onSelected: (_) => setState(() => _category = category),
              ),
          ],
        ),
        const SizedBox(height: 24),
        CareEmpty(
          icon: Icons.auto_stories_outlined,
          title: _category == 'Tous'
              ? 'Les publications arrivent ici'
              : 'Aucun article sur ce thème',
          description:
              'Aucun article de médecin n’est disponible pour le moment. '
              'Les publications afficheront leur auteur, leur spécialité et leur date.',
        ),
      ],
    ),
  );
}
