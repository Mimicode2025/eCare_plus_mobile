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
        'Vous pouvez renseigner vos informations personnelles, vos mesures de glycémie et de tension, votre agenda, une photo de profil, vos pathologies suivies et des documents médicaux. Les formulaires de compte et de profil ne sont pas reliés à un service distant. Les documents et les pathologies choisies sont enregistrés localement ; les mesures, rendez-vous, notifications, messages et photo personnalisent votre session.',
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
        'Les mesures, rendez-vous, messages, rappels et photo sont conservés pendant la session active. Ils sont effacés de l’état de l’application à la déconnexion et ne sont pas restaurés après un redémarrage. Les fichiers du carnet et les pathologies sélectionnées restent conservés sur cet appareil après déconnexion. Le système du téléphone peut conserver temporairement une copie technique d’un fichier sélectionné. Conservez séparément les informations importantes : le carnet local ne constitue pas une sauvegarde distante.',
      ),
      LegalSection(
        'Documents médicaux',
        'Le sélecteur de fichiers s’ouvre lorsque vous choisissez d’ajouter un document. Seul le fichier sélectionné est copié dans le carnet, avec le nom, la catégorie, la date et les suivis que vous indiquez. Vous pouvez ouvrir, télécharger ou retirer ce document. Un téléchargement crée une copie à l’emplacement choisi. Retirer un document du carnet ne supprime ni son fichier d’origine ni les copies exportées.',
      ),
      LegalSection(
        'Partage et services connectés',
        'Cette version n’envoie pas vos mesures, rendez-vous, messages, documents ou photo à un serveur eCARE+ ou à un médecin. L’ouverture d’un document utilise une application compatible du téléphone ; les copies exportées sont gérées à l’emplacement choisi. Aucun service publicitaire ou de mesure d’audience n’est intégré. Les boutons de connexion sociale ne réalisent pas encore une authentification auprès de Google ou Facebook. Les destinataires et modalités d’hébergement seront précisés avant l’activation de services connectés.',
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
