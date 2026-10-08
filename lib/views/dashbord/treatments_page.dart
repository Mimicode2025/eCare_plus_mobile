import 'package:flutter/material.dart';
import '../../widgets/care_page.dart';

class TreatmentsPage extends StatelessWidget {
  const TreatmentsPage({super.key});
  @override
  Widget build(BuildContext context) => const CarePage(
    title: 'Mes traitements',
    subtitle: 'Retrouvez les traitements prescrits par votre médecin.',
    child: CareEmpty(
      icon: Icons.medication_outlined,
      title: 'Aucun traitement renseigné',
      description:
          'Votre traitement et ses horaires de prise apparaîtront ici lorsque votre dossier médical sera connecté.',
    ),
  );
}
