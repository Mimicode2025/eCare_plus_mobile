import 'package:flutter/material.dart';
import '../../data/doctor_catalog.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import '../messaging/doctor_chat_page.dart';
import '../messaging/doctor_contact_page.dart';
import 'appointments_page.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});
  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = doctorCatalog
        .where(
          (doctor) => '${doctor.name} ${doctor.specialty}'
              .toLowerCase()
              .contains(_query.trim().toLowerCase()),
        )
        .toList();
    return CarePage(
      title: 'Mes médecins',
      subtitle: 'Trouvez votre médecin et découvrez son parcours.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppDecor.shadow(.035),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              style: AppDecor.t(14),
              decoration: InputDecoration(
                labelText: 'Rechercher un médecin',
                hintText: 'Nom ou spécialité',
                labelStyle: AppDecor.t(13, c: AppColors.textMuted),
                hintStyle: AppDecor.t(13, c: AppColors.textHint),
                prefixIcon: const Icon(Icons.search_rounded, size: 23),
                prefixIconColor: AppColors.primary,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer la recherche',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: .7),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (doctors.isEmpty)
            const CareEmpty(
              icon: Icons.search_off_rounded,
              title: 'Aucun résultat',
              description: 'Essayez un autre nom ou une autre spécialité.',
            )
          else
            for (final doctor in doctors) ...[
              _DoctorDirectoryCard(doctor: doctor),
              const SizedBox(height: 18),
            ],
        ],
      ),
    );
  }
}

class _DoctorDirectoryCard extends StatelessWidget {
  final CareDoctor doctor;
  const _DoctorDirectoryCard({required this.doctor});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DoctorContactPage(doctor: doctor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final portrait = ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ColoredBox(
                color: doctor.color,
                child: Image.asset(
                  doctor.imageAsset,
                  width: stacked ? constraints.maxWidth : 104,
                  height: 146,
                  fit: stacked ? BoxFit.contain : BoxFit.cover,
                  alignment: const Alignment(-.44, -1),
                  semanticLabel: doctor.name,
                  errorBuilder: (_, _, _) => SizedBox(
                    width: stacked ? constraints.maxWidth : 104,
                    height: 146,
                    child: Icon(
                      doctor.icon,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                ),
              ),
            );
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: AppDecor.t(15, w: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  doctor.specialty,
                  style: AppDecor.t(12, c: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: Tooltip(
                    message: 'Message à ${doctor.name}',
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DoctorChatPage(doctor: doctor),
                        ),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        'Message',
                        textAlign: TextAlign.center,
                        style: AppDecor.t(
                          12,
                          c: Colors.white,
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
            return Column(
              children: [
                if (stacked) ...[
                  portrait,
                  const SizedBox(height: 16),
                  details,
                ] else
                  Row(
                    children: [
                      portrait,
                      const SizedBox(width: 14),
                      Expanded(child: details),
                    ],
                  ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () =>
                        showAppointmentForm(context, doctor: doctor.name),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.calendar_month_outlined, size: 19),
                    label: Text(
                      'Ajouter à mon agenda',
                      textAlign: TextAlign.center,
                      style: AppDecor.t(
                        11,
                        c: AppColors.primary,
                        w: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
