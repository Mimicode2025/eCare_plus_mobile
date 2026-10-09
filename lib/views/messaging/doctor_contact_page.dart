import 'package:flutter/material.dart';
import '../../data/doctor_catalog.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/page_header.dart';
import '../dashbord/appointments_page.dart';

class DoctorContactPage extends StatelessWidget {
  final CareDoctor doctor;
  const DoctorContactPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      leading: const PageBackButton(),
      title: const Text('Profil du médecin'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 64,
                backgroundImage: AssetImage(doctor.imageAsset),
              ),
              const SizedBox(height: 22),
              Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: AppDecor.t(23, w: FontWeight.w700, c: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.specialty,
                textAlign: TextAlign.center,
                style: AppDecor.t(15, c: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Profil de démonstration. Les coordonnées du médecin seront disponibles après connexion du service.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () =>
                    showAppointmentForm(context, doctor: doctor.name),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Planifier un rendez-vous'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Retour à la conversation'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
