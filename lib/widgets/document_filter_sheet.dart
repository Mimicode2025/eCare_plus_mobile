import 'package:flutter/material.dart';
import '../models/medical_document.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

class DocumentFilters {
  final DocumentCategory? category;
  final MedicalCondition? condition;
  final bool general;
  const DocumentFilters({this.category, this.condition, this.general = false});
}

/// Les choix restent provisoires jusqu'à « Afficher les résultats ».
class DocumentFilterSheet extends StatefulWidget {
  final DocumentFilters initial;
  final Set<MedicalCondition> conditions;
  const DocumentFilterSheet({
    super.key,
    required this.initial,
    required this.conditions,
  });

  @override
  State<DocumentFilterSheet> createState() => _DocumentFilterSheetState();
}

class _DocumentFilterSheetState extends State<DocumentFilterSheet> {
  late DocumentCategory? _category = widget.initial.category;
  late String _followUp = widget.initial.general
      ? 'general'
      : widget.initial.condition?.name ?? 'all';

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    filled: true,
    fillColor: AppColors.scaffoldBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filtrer mes documents',
                  style: AppDecor.t(
                    20,
                    w: FontWeight.w700,
                    c: AppColors.primaryDeep,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Fermer les filtres',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          Text(
            'Affinez votre recherche en quelques choix.',
            style: AppDecor.t(12, c: AppColors.textMuted, h: 1.5),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<DocumentCategory>(
            key: ValueKey('category-${_category?.name}'),
            initialValue: _category,
            isExpanded: true,
            isDense: false,
            itemHeight: null,
            style: AppDecor.t(14),
            decoration: _decoration(
              'Type de document',
              Icons.folder_copy_outlined,
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Tous les types'),
              ),
              for (final category in DocumentCategory.values)
                DropdownMenuItem(value: category, child: Text(category.label)),
            ],
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            key: ValueKey('follow-up-$_followUp'),
            initialValue: _followUp,
            isExpanded: true,
            isDense: false,
            itemHeight: null,
            style: AppDecor.t(14),
            decoration: _decoration(
              'Suivi médical',
              Icons.favorite_outline_rounded,
            ),
            items: [
              const DropdownMenuItem(
                value: 'all',
                child: Text('Tous les suivis'),
              ),
              for (final condition in MedicalCondition.values.where(
                widget.conditions.contains,
              ))
                DropdownMenuItem(
                  value: condition.name,
                  child: Text(condition.label),
                ),
              const DropdownMenuItem(value: 'general', child: Text('Général')),
            ],
            onChanged: (value) => setState(() => _followUp = value ?? 'all'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              clipBehavior: Clip.antiAlias,
              label: Text(
                'Afficher les résultats',
                style: AppDecor.t(
                  14,
                  w: FontWeight.w600,
                  c: Colors.white,
                  h: 1.3,
                ),
              ),
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundBuilder: AppDecor.buttonBackground,
                minimumSize: const Size(0, 54),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              onPressed: () => Navigator.pop(
                context,
                DocumentFilters(
                  category: _category,
                  condition: _followUp == 'all' || _followUp == 'general'
                      ? null
                      : MedicalCondition.values.byName(_followUp),
                  general: _followUp == 'general',
                ),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _category = null;
                _followUp = 'all';
              }),
              child: const Text('Réinitialiser'),
            ),
          ),
        ],
      ),
    ),
  );
}
