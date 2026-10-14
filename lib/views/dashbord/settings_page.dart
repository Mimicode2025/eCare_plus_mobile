import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../services/app_share_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/settings_section.dart';
import '../profile/profile_page.dart';
import '../settings/ecare_page.dart';
import '../settings/local_data_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    try {
      await AppShareService.share(
        origin: box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir le partage. Réessayez.'),
        ),
      );
    }
  }

  void _profile(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
  );
  void _about(BuildContext context, {bool guideOnly = false}) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => ECarePage(guideOnly: guideOnly)),
  );
  Future<void> _logout(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitter votre espace ?'),
        content: const Text(
          'Les mesures, rendez-vous, messages et la photo de cette session seront effacés. Votre carnet de documents et vos suivis médicaux resteront sur cet appareil.',
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
      subtitle: 'Votre espace, vos préférences.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: AppColors.primaryDeep,
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: AppDecor.buttonGradient,
                ),
                child: InkWell(
                  onTap: () => _profile(context),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .8),
                            ),
                          ),
                          child: const PatientAvatar(radius: 25),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mon espace santé',
                                style: AppDecor.t(
                                  17,
                                  w: FontWeight.w700,
                                  c: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Profil et suivis médicaux',
                                style: AppDecor.t(
                                  12,
                                  c: Colors.white.withValues(alpha: .85),
                                  h: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Mon espace',
            children: [
              SettingsItem(
                icon: Icons.person_outline_rounded,
                title: 'Mon profil',
                onTap: () => _profile(context),
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: 'Mes documents',
                onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
              ),
              SettingsItem(
                icon: Icons.notifications_none_rounded,
                title: 'Mes notifications',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Préférences',
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.event_available_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
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
                                'Afficher les rendez-vous dans mes notifications.',
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
                    const SizedBox(height: 12),
                    Row(
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
                  ],
                ),
              ),
              const SettingsItem(
                icon: Icons.palette_outlined,
                title: 'Français · Thème clair',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Aide et confidentialité',
            children: [
              Builder(
                builder: (shareContext) => SettingsItem(
                  icon: Icons.share_outlined,
                  title: 'Partager l’application',
                  subtitle:
                      'Présenter eCARE+ sur WhatsApp ou une autre application.',
                  onTap: () => _share(shareContext),
                ),
              ),
              SettingsItem(
                icon: Icons.info_outline_rounded,
                title: 'À propos de eCARE+',
                onTap: () => _about(context),
              ),
              SettingsItem(
                icon: Icons.help_outline_rounded,
                title: 'Guide d’utilisation',
                onTap: () => _about(context, guideOnly: true),
              ),
              SettingsItem(
                icon: Icons.phone_android_rounded,
                title: 'Mes données sur cet appareil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const LocalDataPage(),
                  ),
                ),
              ),
              SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.privacyPolicy),
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: 'Conditions générales d’utilisation',
                onTap: () => Navigator.pushNamed(context, AppRoutes.termsOfUse),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB74A58),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                side: BorderSide(
                  color: const Color(0xFFB74A58).withValues(alpha: .35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Se déconnecter'),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => _about(context),
              child: Text(
                'eCare+',
                style: AppDecor.t(17, w: FontWeight.w700, c: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
