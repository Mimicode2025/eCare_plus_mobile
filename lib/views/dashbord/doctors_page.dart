import 'package:flutter/material.dart';
import '../../data/doctor_catalog.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/care_page.dart';
import 'appointments_page.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});
  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final doctors = doctorCatalog
        .where(
          (doctor) => '${doctor.name} ${doctor.specialty}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    return CarePage(
      title: 'Mes médecins',
      subtitle:
          'Recherchez un professionnel par nom ou par spécialité. Profils de démonstration.',
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Nom ou spécialité',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (doctors.isEmpty)
            const CareEmpty(
              icon: Icons.search_off_rounded,
              title: 'Aucun résultat',
              description: 'Essayez un autre nom ou une autre spécialité.',
            )
          else
            for (final doctor in doctors) ...[
              CareCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: doctor.color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              doctor.imageAsset,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              semanticLabel: doctor.name,
                              errorBuilder: (_, _, _) => Icon(
                                doctor.icon,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: AppDecor.t(15, w: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                doctor.specialty,
                                style: AppDecor.t(12, c: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          showAppointmentForm(context, doctor: doctor.name),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Ajouter à mon agenda'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}
