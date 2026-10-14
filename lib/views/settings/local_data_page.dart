import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_decor.dart';
import '../../utils/app_colors.dart';
import '../../widgets/care_page.dart';
import '../../widgets/settings_section.dart';

class LocalDataPage extends StatelessWidget {
  const LocalDataPage({super.key});
  @override
  Widget build(BuildContext context) => CarePage(
    title: 'Mes données',
    subtitle: 'Comprendre ce qui est conservé sur cet appareil.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          'Documents et suivis médicaux',
          Icons.folder_copy_outlined,
          'Les fichiers de votre carnet et les pathologies sélectionnées sont enregistrés sur cet appareil. Fermer l’application ou vous déconnecter ne supprime pas ces éléments. Vous pouvez retirer un document depuis son menu dans le carnet.',
        ),
        const SizedBox(height: 16),
        _card(
          'Mesures et agenda',
          Icons.timeline_rounded,
          'Les mesures, rendez-vous, messages du chat et photo de profil sont conservés pendant la session active. Ils sont effacés à la déconnexion et ne sont pas restaurés après un redémarrage de l’application. Les fichiers choisis pour un message peuvent aussi avoir une copie temporaire gérée par le téléphone.',
        ),
        const SizedBox(height: 16),
        _card(
          'Export et partage',
          Icons.file_download_outlined,
          'Télécharger un document crée une copie à l’emplacement choisi. Retirer le document du carnet ne supprime ni cette copie ni le fichier d’origine. Aucun document du carnet n’est envoyé automatiquement à un médecin.',
        ),
        const SizedBox(height: 22),
        SettingsSection(
          title: 'Gérer mes informations',
          children: [
            SettingsItem(
              icon: Icons.folder_outlined,
              title: 'Ouvrir mon carnet',
              onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
            ),
            SettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.privacyPolicy),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _card(String title, IconData icon, String description) => CareCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppDecor.t(16, w: FontWeight.w700, c: AppColors.primaryDeep),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: AppDecor.t(13, c: AppColors.textMuted, h: 1.6),
        ),
      ],
    ),
  );
}
