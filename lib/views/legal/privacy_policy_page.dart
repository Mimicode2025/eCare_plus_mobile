import 'package:flutter/material.dart';
import 'legal_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) => const LegalPage(
    title: 'Politique de confidentialité',
    icon: Icons.privacy_tip_outlined,
    introduction:
        'Cette politique décrit la version actuelle d’eCARE+. Elle sera complétée avant l’ouverture du service avec l’identité de l’éditeur, ses coordonnées et les modalités des services connectés.',
    sections: [
      LegalSection(
        'Données utilisées',
        'Vous pouvez renseigner vos informations personnelles, vos mesures de glycémie et de tension, votre agenda et une photo de profil. Les formulaires de compte et de profil ne sont pas encore reliés à un service d’enregistrement. Les mesures, rendez-vous, notifications, préférences et photo servent à personnaliser votre session dans l’application.',
      ),
      LegalSection(
        'Pourquoi ces informations ?',
        'Les mesures permettent de dessiner vos graphiques de suivi. Les rendez-vous alimentent votre agenda personnel et ses rappels. La photo personnalise votre profil, l’accueil et les paramètres. La consultation des graphiques ne produit pas de diagnostic médical.',
      ),
      LegalSection(
        'Photo et accès à la galerie',
        'La galerie s’ouvre uniquement lorsque vous appuyez sur le bouton + de votre profil. Vous choisissez la photo à importer et pouvez annuler sans modifier votre photo actuelle. L’application n’importe pas automatiquement les autres photos de votre galerie. La photo choisie peut être redimensionnée pour son affichage.',
      ),
      LegalSection(
        'Conservation et suppression',
        'Les données de suivi et la photo sont conservées pendant la session active. Elles sont effacées de l’état de l’application à la déconnexion et ne constituent pas une sauvegarde permanente. Le système du téléphone peut conserver temporairement une copie technique d’une photo sélectionnée. Votre photo originale reste dans votre galerie. Cette version ne doit pas être votre seul moyen de conserver une mesure ou un rendez-vous important.',
      ),
      LegalSection(
        'Partage et services connectés',
        'Cette version n’envoie pas vos mesures, rendez-vous ou photo à un serveur eCARE+ ou à un médecin. Aucun service publicitaire ou de mesure d’audience n’est intégré à cette version. Les boutons de connexion sociale ne réalisent pas encore une authentification auprès de Google ou Facebook. Les destinataires et modalités d’hébergement seront précisés avant l’activation de services connectés.',
      ),
      LegalSection(
        'Vos choix',
        'Vous pouvez remplacer votre photo, désactiver les rappels de rendez-vous et effacer les données de session en vous déconnectant. Vous pouvez gérer les autorisations accordées à l’application depuis les paramètres du téléphone. Les modalités d’exercice des droits relatifs aux données et le contact responsable seront précisés avec l’éditeur avant l’ouverture du service.',
      ),
      LegalSection(
        'Éditeur et contact',
        'L’identité juridique de l’éditeur, son adresse et son adresse e-mail de contact ne sont pas encore renseignées. Cette politique est une version de travail et doit être complétée et validée avant la mise à disposition d’un service réel.',
      ),
    ],
  );
}
