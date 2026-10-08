import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/doctor_catalog.dart';
import '../../models/care_data.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../profile/profile_page.dart';
import 'appointments_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        top: -100,
        right: -80,
        child: Container(
          width: 270,
          height: 270,
          decoration: const BoxDecoration(
            color: AppColors.primaryLighter,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top: 345,
        left: -115,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: .45),
            shape: BoxShape.circle,
          ),
        ),
      ),
      SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              key: const PageStorageKey('home-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                _Header(greeting: _greeting),
                const SizedBox(height: 24),
                const _SearchBar(),
                const SizedBox(height: 22),
                const _WelcomeCard(),
                const SizedBox(height: 24),
                const _QuickActions(),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Mes médecins',
                        style: AppDecor.t(18, w: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.doctors),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                Text(
                  'Profils de démonstration',
                  style: AppDecor.t(11, c: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height:
                      258 +
                      90 *
                          (MediaQuery.textScalerOf(context).scale(14) / 14 - 1)
                              .clamp(0, double.infinity),
                  child: ListView.separated(
                    key: const PageStorageKey('doctor-scroll'),
                    scrollDirection: Axis.horizontal,
                    itemCount: doctorCatalog.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, index) =>
                        _DoctorCard(doctor: doctorCatalog[index]),
                  ),
                ),
                const SizedBox(height: 26),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.statistics),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insights_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Votre suivi, en un coup d’œil',
                                  style: AppDecor.t(13, w: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Retrouvez vos dernières mesures',
                                  style: AppDecor.t(11, c: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  final String greeting;
  const _Header({required this.greeting});
  @override
  Widget build(BuildContext context) {
    final data = context.watch<CareData>();
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Mon profil',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                gradient: AppDecor.gradient,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryLighter,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting Gloria',
                style: AppDecor.t(17, w: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Comment allez-vous aujourd’hui ?',
                style: AppDecor.t(11.5, c: AppColors.textMuted, h: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppDecor.shadow(.04),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
            icon: Badge(
              isLabelVisible:
                  data.remindersEnabled && data.appointments.isNotEmpty,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => Navigator.pushNamed(context, AppRoutes.doctors),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rechercher un médecin',
                style: AppDecor.t(13, c: AppColors.textMuted),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
      boxShadow: AppDecor.shadow(.06),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bienvenue', style: AppDecor.t(21, w: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Votre suivi médical\ncommence ici.',
                style: AppDecor.t(13, c: AppColors.textMuted, h: 1.6),
              ),
              const SizedBox(height: 14),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryLighter,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
                child: Text(
                  'Compléter mon profil',
                  style: AppDecor.t(
                    11,
                    c: AppColors.primary,
                    w: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Image.asset(
          'assets/images/ecareImage1.png',
          width: 112,
          height: 130,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.monitor_heart_outlined, 'Suivi', AppRoutes.followUp),
      (Icons.folder_copy_outlined, 'Documents', AppRoutes.documents),
      (Icons.medication_outlined, 'Traitements', AppRoutes.treatments),
      (Icons.medical_services_outlined, 'Médecins', AppRoutes.doctors),
      (Icons.bar_chart_rounded, 'Statistiques', AppRoutes.statistics),
    ];
    final textGrowth = (MediaQuery.textScalerOf(context).scale(11) / 11 - 1)
        .clamp(0, double.infinity)
        .toDouble();
    return SizedBox(
      height: 110 + 55 * textGrowth,
      child: ListView.separated(
        key: const PageStorageKey('shortcut-scroll'),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => SizedBox(
          width: 100 + 50 * textGrowth,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.pushNamed(context, items[index].$3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      items[index].$1,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    items[index].$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppDecor.t(11, w: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final CareDoctor doctor;
  const _DoctorCard({required this.doctor});
  @override
  Widget build(BuildContext context) => Container(
    width: 186,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withValues(alpha: .5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: doctor.color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Icon(doctor.icon, color: AppColors.primary, size: 54),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          doctor.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppDecor.t(13, w: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialty,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppDecor.t(11, c: AppColors.textMuted),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () => showAppointmentForm(context, doctor: doctor.name),
            icon: const Icon(Icons.calendar_month_outlined, size: 16),
            label: Text(
              'Planifier',
              style: AppDecor.t(12, w: FontWeight.w600, c: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
