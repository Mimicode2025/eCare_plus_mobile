import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareData>();
    final appointments = data.remindersEnabled
        ? data.appointments
        : <CareAppointment>[];
    return CarePage(
      title: 'Mes notifications',
      subtitle: 'Les informations utiles pour ne rien oublier.',
      child: appointments.isEmpty
          ? CareEmpty(
              icon: Icons.notifications_none_rounded,
              title: data.remindersEnabled
                  ? 'Vous êtes à jour'
                  : 'Les rappels sont désactivés',
              description: data.remindersEnabled
                  ? 'Les entrées de votre agenda personnel apparaîtront ici.'
                  : 'Vous pouvez les réactiver depuis les paramètres.',
            )
          : Column(
              children: [
                for (final appointment in appointments) ...[
                  CareCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.event_note_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        appointment.doctor,
                        style: AppDecor.t(14, w: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${careDate(appointment.date)} à ${careTime(appointment.date)}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.appointments),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
    );
  }
}
