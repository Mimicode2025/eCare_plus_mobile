# les régle a respecter

01 dégradé violet vers bleu
02 hero text en dégradé
03 emojis dans les titres
04 la police Inter partout
05 cartes à bordure colorée
06 cartes en glassmorphism
07 dark mode sans contraste
08 trois icon boxes alignées
09 un badge au-dessus du titre
10 les icônes Lucide partout
11 composants shadcn jamais retouchés
12 fade-in au scroll
13 une traînée qui suit le curseur
14 boutons qui s'estompent au survol
15 espacements incohérents
16 em dashes partout
17 texte plein de buzzwords
18 italique serif sur les mots d'accent
19 Space Grotesk + Instrument Serif
20 texture de grain sur un degrade

## Code style

- **Architecture :** Respecter strictement l'architecture Model-View-Service. Les Vues ne doivent pas contenir de logique métier ou d'appels directs à l'API.
- **Gestion d'état :** Utiliser le package `provider` comme spécifié dans le `pubspec.yaml`.
- **Convention de nommage :** 
  - `camelCase` pour les variables et méthodes.
  - `PascalCase` pour les classes.
  - `snake_case` pour les noms de fichiers et de dossiers.
- **Widgets :** Découper l'interface en petits widgets réutilisables (placés dans `lib/widgets/`).
- **Langue :** Rédiger les commentaires et le texte de l'interface utilisateur en français.
- **Design :** Appliquer les règles visuelles listées ci-dessus (dégradés, polices, etc.) en utilisant les outils de Flutter (LinearGradient, BackdropFilter pour le glassmorphism, etc.).
