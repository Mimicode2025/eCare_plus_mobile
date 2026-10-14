import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

class DoctorSpecialtyFilterSheet extends StatefulWidget {
  final List<String> specialties;
  final String? initialSpecialty;
  const DoctorSpecialtyFilterSheet({
    super.key,
    required this.specialties,
    this.initialSpecialty,
  });

  @override
  State<DoctorSpecialtyFilterSheet> createState() =>
      _DoctorSpecialtyFilterSheetState();
}

class _DoctorSpecialtyFilterSheetState
    extends State<DoctorSpecialtyFilterSheet> {
  late String _selected = widget.initialSpecialty ?? '';

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
                  'Filtrer par spécialité',
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
            'Choisissez la spécialité du médecin recherché.',
            style: AppDecor.t(12, c: AppColors.textMuted, h: 1.5),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            key: ValueKey(_selected),
            initialValue: _selected,
            isExpanded: true,
            isDense: false,
            itemHeight: null,
            style: AppDecor.t(14),
            decoration: InputDecoration(
              labelText: 'Spécialité',
              prefixIcon: const Icon(
                Icons.medical_services_outlined,
                color: AppColors.primary,
                size: 20,
              ),
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
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Toutes les spécialités'),
              ),
              for (final specialty in widget.specialties)
                DropdownMenuItem(value: specialty, child: Text(specialty)),
            ],
            onChanged: (value) => setState(() => _selected = value ?? ''),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              clipBehavior: Clip.antiAlias,
              onPressed: () => Navigator.pop(context, _selected),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(
                'Afficher les médecins',
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
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _selected = ''),
              child: const Text('Réinitialiser'),
            ),
          ),
        ],
      ),
    ),
  );
}
