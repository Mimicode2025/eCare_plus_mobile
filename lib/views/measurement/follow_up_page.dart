import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/measurement_chart.dart';

class FollowUpPage extends StatefulWidget {
  const FollowUpPage({super.key});
  @override
  State<FollowUpPage> createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  bool _pressure = false;
  int _period = 0;

  DateTime _start(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (_period < 2) {
      return today.subtract(Duration(days: _period == 0 ? 6 : 29));
    }
    final month = DateTime(now.year, now.month - (_period == 2 ? 3 : 6), 1);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, math.min(now.day, lastDay));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareData>();
    final now = DateTime.now();
    final start = _start(now);
    final points =
        (_pressure
                ? data.bloodPressureReadings.map(
                    (reading) => MeasurementPoint(
                      reading.date,
                      reading.systolic,
                      reading.diastolic,
                    ),
                  )
                : data.readings.map(
                    (reading) => MeasurementPoint(reading.date, reading.value),
                  ))
            .where(
              (point) =>
                  !point.date.isBefore(start) && !point.date.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: 72,
        title: Text(
          'Mon suivi',
          style: AppDecor.t(22, w: FontWeight.w700, c: AppColors.primary),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                tooltip: 'Retour',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _tab('Glycémie', false),
                    _tab('Tension artérielle', true),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            ['7 jours', '30 jours', '3 mois', '6 mois'][i],
                          ),
                          selected: _period == i,
                          selectedColor: AppColors.primary,
                          labelStyle: AppDecor.t(
                            12,
                            w: FontWeight.w600,
                            c: _period == i ? Colors.white : AppColors.primary,
                          ),
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _period = i),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CareCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pressure
                                    ? 'Évolution de la tension'
                                    : 'Évolution de la glycémie',
                                style: AppDecor.t(16, w: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${points.length} ${points.length == 1 ? 'mesure' : 'mesures'} sur la période',
                                style: AppDecor.t(11, c: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: 'Ajouter une mesure',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _addMeasurement,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    MeasurementChart(
                      key: const ValueKey('measurement-chart'),
                      points: points,
                      start: start,
                      end: now,
                      pressure: _pressure,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CareCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Répartition des mesures',
                      style: AppDecor.t(
                        17,
                        w: FontWeight.w700,
                        c: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Par moment de la journée',
                      style: AppDecor.t(11, c: AppColors.textMuted),
                    ),
                    const SizedBox(height: 18),
                    MeasurementDistribution(
                      dates: points.map((point) => point.date).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'lib/data/Icon_bon a savoir.png',
                      width: 48,
                      height: 54,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bon à savoir',
                            style: AppDecor.t(
                              14,
                              w: FontWeight.w700,
                              c: const Color(0xFF315D85),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Le bouton + permet d’ajouter une constante avec sa date. Les courbes suivent les mesures de la période choisie.',
                            style: AppDecor.t(
                              12,
                              c: const Color(0xFF315D85),
                              h: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (points.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Historique de la période',
                  style: AppDecor.t(16, w: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                for (final point in points.reversed) ...[
                  CareCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${careDate(point.date)} · ${careTime(point.date)}',
                          style: AppDecor.t(11, c: AppColors.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pressure
                              ? '${point.primary} / ${point.secondary} mmHg'
                              : '${point.primary} mg/dL',
                          style: AppDecor.t(
                            15,
                            w: FontWeight.w700,
                            c: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 10),
              Text(
                'Mesures conservées pendant cette session.',
                textAlign: TextAlign.center,
                style: AppDecor.t(10, c: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool pressure) => Expanded(
    child: Material(
      color: _pressure == pressure ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => setState(() => _pressure = pressure),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppDecor.t(
              13,
              w: FontWeight.w700,
              c: _pressure == pressure ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _addMeasurement() async {
    final result = await showModalBottomSheet<_MeasurementInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _MeasurementForm(pressure: _pressure),
    );
    if (result != null && mounted) {
      final data = context.read<CareData>();
      if (result.secondary == null) {
        data.addReading(result.primary, date: result.date);
      } else {
        data.addBloodPressure(
          result.primary,
          result.secondary!,
          date: result.date,
        );
      }
    }
  }
}

class _MeasurementInput {
  final double primary;
  final double? secondary;
  final DateTime date;
  const _MeasurementInput(this.primary, this.secondary, this.date);
}

class _MeasurementForm extends StatefulWidget {
  final bool pressure;
  const _MeasurementForm({required this.pressure});
  @override
  State<_MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<_MeasurementForm> {
  final _form = GlobalKey<FormState>();
  final _primary = TextEditingController();
  final _secondary = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;
  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    super.dispose();
  }

  double? _parse(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));
  Widget _field(TextEditingController controller, String label, String unit) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        validator: (value) {
          final number = _parse(value ?? '');
          return number == null || !number.isFinite || number <= 0
              ? 'Saisissez une valeur positive en $unit'
              : null;
        },
      );
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
          Text(
            widget.pressure
                ? 'Nouvelle tension artérielle'
                : 'Nouvelle glycémie',
            style: AppDecor.t(20, w: FontWeight.w700),
          ),
          const SizedBox(height: 22),
          _field(
            _primary,
            widget.pressure ? 'Systolique' : 'Glycémie',
            widget.pressure ? 'mmHg' : 'mg/dL',
          ),
          if (widget.pressure) ...[
            const SizedBox(height: 16),
            _field(_secondary, 'Diastolique', 'mmHg'),
          ],
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
            ),
            title: Text(careDate(_date)),
            trailing: const Icon(Icons.edit_outlined, size: 18),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) {
                setState(
                  () => _date = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _date.hour,
                    _date.minute,
                  ),
                );
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.schedule_rounded,
              color: AppColors.primary,
            ),
            title: Text(careTime(_date)),
            trailing: const Icon(Icons.edit_outlined, size: 18),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_date),
              );
              if (time != null && mounted) {
                setState(
                  () => _date = DateTime(
                    _date.year,
                    _date.month,
                    _date.day,
                    time.hour,
                    time.minute,
                  ),
                );
              }
            },
          ),
          if (_error != null)
            Text(_error!, style: AppDecor.t(12, c: AppColors.required)),
          const SizedBox(height: 16),
          GradientButton(
            text: 'Enregistrer la mesure',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              if (_date.isAfter(DateTime.now())) {
                setState(
                  () => _error =
                      'La date de la mesure ne peut pas être dans le futur.',
                );
                return;
              }
              if (widget.pressure &&
                  _parse(_primary.text)! <= _parse(_secondary.text)!) {
                setState(
                  () => _error =
                      'La systolique doit être supérieure à la diastolique.',
                );
                return;
              }
              Navigator.pop(
                context,
                _MeasurementInput(
                  _parse(_primary.text)!,
                  widget.pressure ? _parse(_secondary.text)! : null,
                  _date,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
