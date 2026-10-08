import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../../widgets/gradient_button.dart';

class FollowUpPage extends StatelessWidget {
  const FollowUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    final readings = context.watch<CareData>().readings;
    return CarePage(
      title: 'Mon suivi',
      subtitle: 'Retrouvez vos mesures et gardez une trace de votre quotidien.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CareCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(height: 14),
                Text('Glycémie', style: AppDecor.t(20, w: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  readings.isEmpty
                      ? 'Aucune mesure enregistrée'
                      : '${readings.first.value} mg/dL',
                  style: AppDecor.t(
                    16,
                    c: AppColors.primary,
                    w: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  text: 'Ajouter une mesure',
                  onPressed: () => _addReading(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Mes statistiques',
              style: AppDecor.t(15, w: FontWeight.w600),
            ),
            trailing: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
          ),
          const SizedBox(height: 12),
          Text(
            'Historique de cette session',
            style: AppDecor.t(16, w: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (readings.isEmpty)
            const CareEmpty(
              icon: Icons.monitor_heart_outlined,
              title: 'Votre suivi commence ici',
              description:
                  'Ajoutez la valeur affichée par votre lecteur, en mg/dL. '
                  'Vos mesures restent disponibles pendant cette session.',
            )
          else
            for (final reading in readings) ...[
              CareCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '${careDate(reading.date)} · ${careTime(reading.date)}',
                        style: AppDecor.t(12, c: AppColors.textMuted),
                      ),
                    ),
                    Text(
                      '${reading.value} mg/dL',
                      style: AppDecor.t(14, w: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Future<void> _addReading(BuildContext context) async {
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _ReadingForm(),
    );
    if (value != null && context.mounted) {
      context.read<CareData>().addReading(value);
    }
  }
}

class _ReadingForm extends StatefulWidget {
  const _ReadingForm();
  @override
  State<_ReadingForm> createState() => _ReadingFormState();
}

class _ReadingFormState extends State<_ReadingForm> {
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  double? get _number =>
      double.tryParse(_value.text.trim().replaceAll(',', '.'));
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      24,
      24,
      24,
      24 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nouvelle mesure', style: AppDecor.t(21, w: FontWeight.w700)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Glycémie',
              suffixText: 'mg/dL',
              border: OutlineInputBorder(),
            ),
            validator: (_) =>
                _number == null || !_number!.isFinite || _number! <= 0
                ? 'Saisissez une valeur positive en mg/dL'
                : null,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Enregistrer la mesure',
            onPressed: () {
              if (_form.currentState!.validate()) {
                Navigator.pop(context, _number);
              }
            },
          ),
        ],
      ),
    ),
  );
}
