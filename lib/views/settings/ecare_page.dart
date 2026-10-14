import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../../widgets/settings_section.dart';
import '../profile/profile_page.dart';
import 'local_data_page.dart';

class ECarePage extends StatelessWidget {
  final bool guideOnly;
  const ECarePage({super.key, this.guideOnly = false});
  @override
  Widget build(BuildContext context) => CarePage(
    title: guideOnly ? 'Guide d’utilisation' : 'eCare+',
    subtitle: guideOnly
        ? 'Des réponses simples pour bien démarrer.'
        : 'Votre compagnon de suivi au quotidien.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!guideOnly) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppDecor.buttonGradient,
              ),
              child: Wrap(
                spacing: 18,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Image.asset('assets/images/ecare_logo.png'),
                  ),
                  Text(
                    'Votre santé,\nau même endroit.',
                    style: AppDecor.t(
                      23,
                      w: FontWeight.w700,
                      c: Colors.white,
                      h: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Explorer mon espace',
            children: [
              SettingsItem(
                icon: Icons.monitor_heart_outlined,
                title: 'Mes constantes',
                onTap: () => Navigator.pushNamed(context, AppRoutes.followUp),
              ),
              SettingsItem(
                icon: Icons.description_outlined,
                title: 'Mon carnet de documents',
                onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
              ),
              SettingsItem(
                icon: Icons.calendar_month_outlined,
                title: 'Mon agenda',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.appointments),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        SettingsSection(
          title: 'Bien démarrer',
          children: [
            _HelpItem(
              title: 'Personnaliser mes suivis',
              text:
                  'Dans votre profil, sélectionnez Diabète, Hypertension ou les deux. Le carnet adapte ses filtres à vos choix. Un document peut concerner plusieurs suivis sans être enregistré deux fois.',
              action: 'Modifier mon profil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
              ),
            ),
            _HelpItem(
              title: 'Ajouter et retrouver un document',
              text:
                  'Votre carnet accepte les PDF, images et fichiers Word jusqu’à 20 Mo. Choisissez un fichier, donnez-lui un nom et classez-le. La recherche et les filtres vous permettent de le retrouver ; son menu propose l’ouverture, le téléchargement et le retrait.',
              action: 'Ouvrir mon carnet',
              onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
            ),
            _HelpItem(
              title: 'Comprendre mes rappels',
              text:
                  'Les rappels de rendez-vous affichent les entrées de votre agenda dans Mes notifications. Vous pouvez les désactiver dans les paramètres. Ils ne déclenchent pas encore d’alarme ou de notification système lorsque l’application est fermée.',
              action: 'Voir mes notifications',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          title: 'Sur cet appareil',
          children: [
            SettingsItem(
              icon: Icons.phone_android_rounded,
              title: 'Mes données sur cet appareil',
              subtitle: 'Documents conservés et données de session',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const LocalDataPage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () =>
                showLicensePage(context: context, applicationName: 'eCare+'),
            child: const Text('Licences et bibliothèques'),
          ),
        ),
      ],
    ),
  );
}

class _HelpItem extends StatelessWidget {
  final String title, text, action;
  final VoidCallback onTap;
  const _HelpItem({
    required this.title,
    required this.text,
    required this.action,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ExpansionTile(
    shape: const Border(),
    collapsedShape: const Border(),
    tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
    title: Text(title, style: AppDecor.t(14, w: FontWeight.w600)),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppDecor.t(13, c: AppColors.textMuted, h: 1.6),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(onPressed: onTap, child: Text(action)),
      ),
    ],
  );
}
