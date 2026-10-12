import 'package:flutter/material.dart';

/// Previews are distinct from future published medical content.
class ArticlePreview {
  final String id, title, category, collection, introduction;
  final List<String> topics;
  final Color background, accent;
  final int artwork;
  Color get textAccent => Color.lerp(accent, const Color(0xFF0D1B2A), .25)!;
  const ArticlePreview({
    required this.id,
    required this.title,
    required this.category,
    required this.collection,
    required this.introduction,
    required this.topics,
    required this.background,
    required this.accent,
    required this.artwork,
  });
}

const featuredArticle = ArticlePreview(
  id: 'welcome',
  title: 'Mieux comprendre sa santé, un article à la fois',
  category: 'Bien-être',
  collection: 'À la une',
  introduction:
      'Un espace pour explorer les sujets qui vous concernent et préparer vos échanges avec vos professionnels de santé.',
  topics: [
    'Comprendre les mots de la santé',
    'Trouver les sujets qui vous concernent',
    'Préparer ses questions pour une consultation',
  ],
  background: Color(0xFFE1F2FC),
  accent: Color(0xFF168BC4),
  artwork: 0,
);

const articlePreviews = [
  ArticlePreview(
    id: 'glucose',
    title: 'Comprendre sa glycémie',
    category: 'Diabète',
    collection: 'Comprendre votre santé',
    introduction:
        'Un futur article pour mettre des mots simples sur la glycémie et mieux comprendre son suivi.',
    topics: [
      'Le vocabulaire du suivi',
      'Les informations à noter',
      'Les questions à poser à son médecin',
    ],
    background: Color(0xFFE9E5F6),
    accent: Color(0xFF7963AD),
    artwork: 1,
  ),
  ArticlePreview(
    id: 'pressure',
    title: 'La tension, en mots simples',
    category: 'Hypertension',
    collection: 'Comprendre votre santé',
    introduction:
        'Un aperçu des sujets qui pourront vous aider à échanger avec votre médecin au sujet de la tension.',
    topics: [
      'Comprendre les termes utilisés',
      'Parler de son suivi',
      'Préparer sa prochaine consultation',
    ],
    background: Color(0xFFF9E3DD),
    accent: Color(0xFFC96959),
    artwork: 2,
  ),
  ArticlePreview(
    id: 'rest',
    title: 'Faire une place au repos',
    category: 'Bien-être',
    collection: 'Prendre soin de soi',
    introduction:
        'Une invitation à observer son rythme et à prendre le temps de parler de son sommeil.',
    topics: [
      'Observer son rythme quotidien',
      'Identifier ses moments de repos',
      'Parler de son sommeil en consultation',
    ],
    background: Color(0xFFE6EAF8),
    accent: Color(0xFF677DB9),
    artwork: 3,
  ),
  ArticlePreview(
    id: 'balance',
    title: 'Retrouver son équilibre au quotidien',
    category: 'Bien-être',
    collection: 'Prendre soin de soi',
    introduction:
        'Un futur rendez-vous éditorial autour du bien-être et de la place que l’on accorde à soi-même.',
    topics: [
      'Faire le point sur ses habitudes',
      'Reconnaître ses besoins',
      'Échanger avec un professionnel',
    ],
    background: Color(0xFFE0EFE7),
    accent: Color(0xFF4F8975),
    artwork: 4,
  ),
  ArticlePreview(
    id: 'food',
    title: 'Alimentation : les bonnes questions',
    category: 'Diabète',
    collection: 'Les petits gestes qui comptent',
    introduction:
        'Un aperçu pour préparer une discussion sur l’alimentation avec son équipe soignante.',
    topics: [
      'Décrire ses habitudes',
      'Noter ses interrogations',
      'Préparer un échange personnalisé',
    ],
    background: Color(0xFFF9EED6),
    accent: Color(0xFFAD8239),
    artwork: 4,
  ),
  ArticlePreview(
    id: 'tracking',
    title: 'Un suivi qui vous ressemble',
    category: 'Hypertension',
    collection: 'Les petits gestes qui comptent',
    introduction:
        'Un futur article pour réfléchir aux informations utiles à partager lors de vos rendez-vous.',
    topics: [
      'Organiser ses notes',
      'Garder ses questions à portée de main',
      'Faire le point avec son médecin',
    ],
    background: Color(0xFFDDEEF4),
    accent: Color(0xFF41899C),
    artwork: 2,
  ),
];
