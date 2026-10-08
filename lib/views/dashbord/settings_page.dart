import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../profile/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => CarePage(
    showBack: false,
    title: 'Paramètres',
    subtitle:
        'Votre compte, vos préférences et les informations de l’application.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mon compte', style: AppDecor.t(16, w: FontWeight.w700)),
        const SizedBox(height: 14),
        CareCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Mon profil'),
                subtitle: const Text('Mes informations personnelles'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Mes notifications'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Préférences', style: AppDecor.t(16, w: FontWeight.w700)),
        const SizedBox(height: 14),
        CareCard(
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rappels dans l’application'),
                subtitle: const Text(
                  'Afficher les entrées de votre agenda dans les notifications.',
                ),
                value: context.watch<CareData>().remindersEnabled,
                onChanged: context.read<CareData>().setReminders,
              ),
              const Divider(),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language_rounded, color: AppColors.primary),
                title: Text('Langue'),
                trailing: Text('Français'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CareCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
            ),
            title: const Text('À propos de eCARE+'),
            subtitle: const Text('Votre santé, notre priorité'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'eCARE+',
              applicationVersion: '1.0.0',
              children: [
                const Text(
                  'Votre espace personnel de suivi et d’accompagnement au quotidien.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
          onPressed: () async {
            final exit = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Quitter votre espace ?'),
                content: const Text(
                  'Les mesures et rendez-vous de cette session seront effacés.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Rester'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            );
            if (exit == true && context.mounted) {
              context.read<CareData>().clear();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
            }
          },
        ),
      ],
    ),
  );
}
