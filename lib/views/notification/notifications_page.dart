import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _search = TextEditingController();
  NotificationCategory? _category;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _normalize(String text) {
    var result = text.toLowerCase();
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'œ': 'oe',
    };
    for (final entry in accents.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  String _label(NotificationCategory category) => switch (category) {
    NotificationCategory.medication => 'Médicaments',
    NotificationCategory.appointment => 'Rendez-vous',
    NotificationCategory.measurement => 'Constantes',
    NotificationCategory.alert => 'Alertes',
  };
  IconData _icon(NotificationCategory category) => switch (category) {
    NotificationCategory.medication => Icons.medication_outlined,
    NotificationCategory.appointment => Icons.calendar_month_outlined,
    NotificationCategory.measurement => Icons.monitor_heart_outlined,
    NotificationCategory.alert => Icons.notifications_active_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareData>();
    final query = _normalize(_search.text.trim());
    final words = query.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    final notifications = data.notifications.where((item) {
      final text = _normalize(
        '${item.title} ${item.message} ${_label(item.category)} '
        '${careDate(item.date)} ${careTime(item.date)}',
      );
      return (_category == null || item.category == _category) &&
          words.every(text.contains);
    }).toList();
    return CarePage(
      title: 'Mes notifications',
      subtitle: 'Vos rappels et informations, réunis au même endroit.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Rechercher une notification',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
              ),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filter('Toutes', Icons.apps_rounded, null),
              for (final category in NotificationCategory.values)
                _filter(_label(category), _icon(category), category),
            ],
          ),
          const SizedBox(height: 24),
          if (!data.remindersEnabled &&
              _category == NotificationCategory.appointment)
            const CareEmpty(
              icon: Icons.notifications_off_outlined,
              title: 'Les rappels de rendez-vous sont désactivés',
              description: 'Vous pouvez les réactiver depuis les paramètres.',
            )
          else if (notifications.isEmpty)
            CareEmpty(
              icon: _category == null
                  ? Icons.notifications_none_rounded
                  : _icon(_category!),
              title: query.isNotEmpty
                  ? 'Aucun résultat'
                  : 'Aucune notification',
              description: query.isNotEmpty
                  ? 'Essayez un autre mot ou choisissez une autre catégorie.'
                  : _category == null
                  ? 'Vos prochains rappels et informations apparaîtront ici.'
                  : 'Vous n’avez aucune notification dans cette catégorie.',
            )
          else ...[
            Text(
              '${notifications.length} notification${notifications.length > 1 ? 's' : ''}',
              style: AppDecor.t(13, c: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            for (final item in notifications) ...[
              CareCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _icon(item.category),
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _label(item.category),
                            style: AppDecor.t(
                              12,
                              w: FontWeight.w600,
                              c: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(item.title, style: AppDecor.t(15, w: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: AppDecor.t(13, c: AppColors.textMuted, h: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${careDate(item.date)} à ${careTime(item.date)}',
                      style: AppDecor.t(11, c: AppColors.textMuted),
                    ),
                    if (item.category != NotificationCategory.alert) ...[
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          switch (item.category) {
                            NotificationCategory.medication =>
                              AppRoutes.treatments,
                            NotificationCategory.appointment =>
                              AppRoutes.appointments,
                            NotificationCategory.measurement =>
                              AppRoutes.followUp,
                            NotificationCategory.alert =>
                              AppRoutes.notifications,
                          },
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(switch (item.category) {
                          NotificationCategory.medication =>
                            'Voir mes traitements',
                          NotificationCategory.appointment =>
                            'Voir mes rendez-vous',
                          NotificationCategory.measurement =>
                            'Ouvrir mon suivi',
                          NotificationCategory.alert =>
                            'Voir les notifications',
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }

  Widget _filter(String label, IconData icon, NotificationCategory? category) =>
      ChoiceChip(
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color: _category == category ? Colors.white : AppColors.primary,
        ),
        selected: _category == category,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: AppDecor.t(
          12,
          w: FontWeight.w600,
          c: _category == category ? Colors.white : AppColors.textMuted,
        ),
        side: BorderSide(
          color: _category == category ? AppColors.primary : AppColors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (_) => setState(() => _category = category),
      );
}
