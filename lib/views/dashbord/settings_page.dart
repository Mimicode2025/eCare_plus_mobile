import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/patient_avatar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _profile(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
  );

  Future<void> _logout(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitter votre espace ?'),
        content: const Text(
          'Les mesures, rendez-vous et notifications de cette session seront effacés.',
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
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareData>();
    return CarePage(
      showBack: false,
      title: 'Paramètres',
      subtitle: 'Un espace qui vous ressemble.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileBanner(onTap: () => _profile(context)),
          const SizedBox(height: 28),
          const _SectionHeading(
            title: 'Mon compte',
            subtitle: 'L’essentiel, à portée de main.',
          ),
          const SizedBox(height: 14),
          CareCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Mon profil',
                  subtitle: 'Mes informations personnelles',
                  onTap: () => _profile(context),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'Mes notifications',
                  subtitle: 'Médicaments, rendez-vous et alertes',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.notifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionHeading(
            title: 'À votre rythme',
            subtitle: 'Des préférences simples et utiles.',
          ),
          const SizedBox(height: 14),
          CareCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SettingsIcon(Icons.event_available_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rappels de rendez-vous',
                            style: AppDecor.t(14, w: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Afficher les entrées de votre agenda dans les notifications.',
                            style: AppDecor.t(
                              12,
                              c: AppColors.textMuted,
                              h: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.remindersEnabled
                              ? 'Rappels activés'
                              : 'Rappels désactivés',
                          style: AppDecor.t(
                            12,
                            w: FontWeight.w600,
                            c: AppColors.primary,
                          ),
                        ),
                      ),
                      Semantics(
                        label: 'Rappels de rendez-vous',
                        child: Switch.adaptive(
                          value: data.remindersEnabled,
                          activeTrackColor: AppColors.primary,
                          onChanged: data.setReminders,
                        ),
                      ),
                    ],
                  ),
                ),
                const _SettingsDivider(),
                const _SettingsRow(
                  icon: Icons.language_rounded,
                  title: 'Langue',
                  subtitle: 'Français',
                ),
                const _SettingsDivider(),
                const _SettingsRow(
                  icon: Icons.palette_outlined,
                  title: 'Votre univers',
                  subtitle: 'Thème clair · Bleu eCARE+',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionHeading(
            title: 'Bien comprendre',
            subtitle: 'Votre application, en toute simplicité.',
          ),
          const SizedBox(height: 14),
          CareCard(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: 'À propos de eCARE+',
                  subtitle: 'Votre santé, notre priorité',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'eCARE+',
                    applicationVersion: '1.0.0',
                    applicationIcon: const _SettingsIcon(
                      Icons.favorite_border_rounded,
                    ),
                    children: const [
                      Text(
                        'Votre espace personnel de suivi et d’accompagnement au quotidien.',
                      ),
                    ],
                  ),
                ),
                const _SettingsDivider(),
                const _SettingsRow(
                  icon: Icons.hourglass_bottom_rounded,
                  title: 'Les données de cette session',
                  subtitle:
                      'Vos mesures et rendez-vous sont conservés pendant cette session. Ils sont effacés à la déconnexion.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Se déconnecter'),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                Text(
                  'eCARE+',
                  style: AppDecor.t(
                    17,
                    w: FontWeight.w700,
                    c: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pensé pour votre quotidien',
                  style: AppDecor.t(11, c: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileBanner({required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      boxShadow: AppDecor.shadow(.15),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppDecor.gradient),
            ),
          ),
          Positioned(right: -75, top: -85, child: _orbit(220)),
          Positioned(right: -100, top: -110, child: _orbit(270)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .65),
                          width: 2,
                        ),
                      ),
                      child: const PatientAvatar(radius: 27),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MON ESPACE PATIENT',
                            style: AppDecor.t(
                              10,
                              w: FontWeight.w600,
                              c: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tout commence par vous.',
                            style: AppDecor.t(13, c: Colors.white, h: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  'Votre espace, à votre rythme.',
                  style: AppDecor.t(
                    24,
                    w: FontWeight.w700,
                    c: Colors.white,
                    h: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Retrouvez vos informations et adaptez vos rappels au quotidien.',
                  style: AppDecor.t(12, c: Colors.white, h: 1.6),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier mon profil'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _orbit(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: .12), width: 1),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeading({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppDecor.t(18, w: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppDecor.t(12, c: AppColors.textMuted, h: 1.4),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SettingsIcon extends StatelessWidget {
  final IconData icon;
  const _SettingsIcon(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: AppColors.primaryLighter,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(icon, size: 22, color: AppColors.primary),
  );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppDecor.t(14, w: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: AppDecor.t(12, c: AppColors.textMuted, h: 1.5),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, color: AppColors.border),
  );
}
