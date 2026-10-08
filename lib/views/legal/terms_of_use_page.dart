import 'package:flutter/material.dart';
import 'legal_page.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});
  @override
  Widget build(BuildContext context) => const LegalPage(
    title: 'Conditions générales d’utilisation',
    icon: Icons.description_outlined,
    introduction:
        'Ces conditions présentent l’utilisation de la version actuelle d’eCARE+. L’identité de l’éditeur et les modalités du service définitif doivent être complétées avant son ouverture.',
    sections: [
      LegalSection(
        'Objet de l’application',
        'eCARE+ propose un espace personnel pour consulter des graphiques de constantes, organiser un agenda et accéder aux rubriques de suivi. La version actuelle sert à essayer ces fonctions. Elle ne constitue pas un dossier médical connecté ni une confirmation de prise en charge par un professionnel.',
      ),
      LegalSection(
        'Accès et acceptation',
        'Vous pouvez consulter ces conditions et la politique de confidentialité avant de cocher la case d’acceptation dans le formulaire d’inscription. Ouvrir un document ne vaut pas acceptation. La version actuelle ne crée pas encore de compte enregistré auprès d’un service distant.',
      ),
      LegalSection(
        'Utilisation responsable',
        'Renseignez vos propres informations et vérifiez les unités, dates et valeurs saisies. Importez uniquement une photo que vous êtes autorisé à utiliser. N’utilisez pas l’application pour diffuser des contenus illicites, usurper l’identité d’une autre personne ou tenter d’accéder à ses données.',
      ),
      LegalSection(
        'Suivi et rendez-vous',
        'Les courbes représentent les valeurs saisies et ne constituent ni une prescription ni un diagnostic. L’agenda personnel n’envoie pas de demande de réservation à un médecin. Les rappels affichés dans l’application ne garantissent pas une alarme système. eCARE+ ne fournit pas de service d’urgence.',
      ),
      LegalSection(
        'Données de session',
        'Les mesures, rendez-vous et photo de cette version sont temporaires. Ils sont effacés de l’état de l’application à la déconnexion. Conservez séparément les informations dont vous avez besoin. Les modalités de traitement des données sont décrites dans la politique de confidentialité.',
      ),
      LegalSection(
        'Disponibilité et évolution',
        'Des fonctions peuvent être indisponibles ou évoluer pendant le développement. Aucune disponibilité continue ni conservation permanente n’est annoncée pour cette version. Les fonctions connectées et leurs conditions seront présentées avant leur activation.',
      ),
      LegalSection(
        'Éditeur, contact et cadre applicable',
        'L’identité de l’éditeur, son contact, les conditions du service définitif et le cadre juridique applicable restent à renseigner. Ce document est une version de travail à compléter et à valider avant l’ouverture du service ; il n’annonce aucune certification ou validation juridique.',
      ),
    ],
  );
}
