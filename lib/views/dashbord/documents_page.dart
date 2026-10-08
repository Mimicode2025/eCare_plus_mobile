import 'package:flutter/material.dart';
import '../../widgets/care_page.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String _category = 'Tous';
  @override
  Widget build(BuildContext context) => CarePage(
    title: 'Mes documents',
    subtitle: 'Vos ordonnances, résultats et comptes rendus au même endroit.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in [
              'Tous',
              'Ordonnances',
              'Résultats',
              'Comptes rendus',
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
          icon: Icons.folder_copy_outlined,
          title: 'Aucun document pour le moment',
          description: _category == 'Tous'
              ? 'Les documents partagés par votre équipe médicale apparaîtront ici lorsque votre dossier sera connecté.'
              : 'Aucun document dans la catégorie « $_category ».',
        ),
      ],
    ),
  );
}
