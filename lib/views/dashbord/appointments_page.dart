import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../../widgets/gradient_button.dart';

class AppointmentsPage extends StatefulWidget {
  final bool showBack;
  final String initialDoctor;
  const AppointmentsPage({
    super.key,
    this.showBack = true,
    this.initialDoctor = '',
  });

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late bool _adding = widget.initialDoctor.isNotEmpty;

  void _save(CareAppointment appointment) {
    context.read<CareData>().addAppointment(appointment);
    setState(() => _adding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rendez-vous ajouté à votre agenda personnel.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<CareData>().appointments;
    return CarePage(
      title: 'Mes rendez-vous',
      subtitle:
          'Organisez vos consultations et retrouvez vos prochains rendez-vous.',
      showBack: widget.showBack,
      child: Column(
        children: [
          if (_adding)
            CareCard(
              child: Column(
                children: [
                  _AppointmentForm(
                    doctor: widget.initialDoctor,
                    onSaved: _save,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _adding = false),
                    child: const Text('Annuler'),
                  ),
                ],
              ),
            )
          else
            GradientButton(
              text: 'Ajouter un rendez-vous',
              onPressed: () => setState(() => _adding = true),
            ),
          const SizedBox(height: 20),
          if (appointments.isEmpty)
            const CareEmpty(
              icon: Icons.event_available_outlined,
              title: 'Votre agenda est libre',
              description:
                  'Ajoutez un rendez-vous déjà convenu avec votre médecin pour le retrouver ici.',
            )
          else
            for (final appointment in appointments) ...[
              CareCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appointment.doctor,
                            style: AppDecor.t(15, w: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Supprimer le rendez-vous',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () async {
                            final remove = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Supprimer ce rendez-vous ?'),
                                content: const Text(
                                  'Cette action supprime uniquement votre entrée dans cet agenda.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Conserver'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                            if (remove == true && context.mounted) {
                              context.read<CareData>().removeAppointment(
                                appointment,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${careDate(appointment.date)} · ${careTime(appointment.date)}',
                      style: AppDecor.t(
                        14,
                        c: AppColors.primary,
                        w: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 18),
          Text(
            'Agenda personnel · Les entrées restent disponibles pendant cette session. '
            'L’ajout ne réserve pas de consultation auprès du médecin.',
            textAlign: TextAlign.center,
            style: AppDecor.t(11, c: AppColors.textMuted, h: 1.6),
          ),
        ],
      ),
    );
  }
}

Future<void> openAppointmentsPage(
  BuildContext context, {
  String doctor = '',
}) async {
  await Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) => AppointmentsPage(initialDoctor: doctor),
    ),
  );
}

class _AppointmentForm extends StatefulWidget {
  final String doctor;
  final ValueChanged<CareAppointment> onSaved;
  const _AppointmentForm({required this.doctor, required this.onSaved});
  @override
  State<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<_AppointmentForm> {
  final _form = GlobalKey<FormState>();
  late final _doctor = TextEditingController(text: widget.doctor);
  DateTime? _day;
  TimeOfDay? _time;
  String? _error;
  @override
  void dispose() {
    _doctor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.zero,
    child: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter une consultation',
              style: AppDecor.t(21, w: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _doctor,
              decoration: const InputDecoration(
                labelText: 'Médecin',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Indiquez le nom du médecin'
                  : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
              ),
              title: Text(_day == null ? 'Choisir une date' : careDate(_day!)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _day ?? now,
                  firstDate: DateTime(now.year, now.month, now.day),
                  lastDate: DateTime(now.year + 3),
                );
                if (picked != null && mounted) setState(() => _day = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                _time == null ? 'Choisir une heure' : _time!.format(context),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time ?? TimeOfDay.now(),
                );
                if (picked != null && mounted) setState(() => _time = picked);
              },
            ),
            if (_error != null)
              Text(_error!, style: AppDecor.t(12, c: AppColors.required)),
            const SizedBox(height: 22),
            GradientButton(
              text: 'Enregistrer dans mon agenda',
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                if (_day == null || _time == null) {
                  setState(() => _error = 'Choisissez la date et l’heure.');
                  return;
                }
                final date = DateTime(
                  _day!.year,
                  _day!.month,
                  _day!.day,
                  _time!.hour,
                  _time!.minute,
                );
                if (!date.isAfter(DateTime.now())) {
                  setState(
                    () => _error = 'Choisissez une date et une heure à venir.',
                  );
                  return;
                }
                widget.onSaved(
                  CareAppointment(doctor: _doctor.text.trim(), date: date),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
