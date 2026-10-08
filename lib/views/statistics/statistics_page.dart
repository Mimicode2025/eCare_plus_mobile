import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final readings = context.watch<CareData>().readings;
    return CarePage(
      title: 'Mes statistiques',
      subtitle: 'Un aperçu de vos mesures enregistrées pendant cette session.',
      child: readings.isEmpty
          ? const CareEmpty(
              icon: Icons.bar_chart_rounded,
              title: 'Pas encore de statistiques',
              description:
                  'Ajoutez une première mesure depuis Mon suivi pour retrouver vos données ici.',
            )
          : CareCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesures de glycémie',
                    style: AppDecor.t(17, w: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${readings.length} mesure(s) enregistrée(s)',
                    style: AppDecor.t(15),
                  ),
                  const Divider(height: 30),
                  Text(
                    'Dernière mesure : ${readings.first.value} mg/dL',
                    style: AppDecor.t(15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${careDate(readings.first.date)} à ${careTime(readings.first.date)}',
                    style: AppDecor.t(12),
                  ),
                ],
              ),
            ),
    );
  }
}
