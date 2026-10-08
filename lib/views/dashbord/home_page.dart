import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grande forme décorative en haut à droite (comme la maquette)
        Positioned(
          top: -90,
          right: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
                color: AppColors.primaryLighter, shape: BoxShape.circle),
          ),
        ),
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              _Header(greeting: _greeting, name: 'Gloria'),
              const SizedBox(height: 22),
              const _SearchBar(),
              const SizedBox(height: 20),
              const _WelcomeCard(),
              const SizedBox(height: 22),
              const _QuickActions(),
              const SizedBox(height: 26),
              _SectionTitle(title: 'Mes médecins', onSeeAll: () {}),
              const SizedBox(height: 14),
              const _DoctorList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String name;
  const _Header({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfilePage())),
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
                gradient: AppDecor.gradient, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryLighter,
              backgroundImage: AssetImage('assets/images/avatar.png'),
              onBackgroundImageError: _ignore,
              child: Icon(Icons.person_rounded, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting $name',
                  style: AppDecor.t(17, w: FontWeight.w700)),
              Text('Comment allez-vous aujourd\'hui ?',
                  style: AppDecor.t(12.5, c: AppColors.textMuted)),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppDecor.shadow()),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.textDark, size: 24),
            ),
            Positioned(
              top: 10,
              right: 11,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void _ignore(Object e, StackTrace? s) {}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppDecor.shadow(.06),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: AppDecor.t(14),
              decoration: InputDecoration(
                hintText: 'Rechercher un médecin, un document...',
                hintStyle: AppDecor.t(13.5, c: AppColors.textMuted),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: AppColors.primaryLighter, shape: BoxShape.circle),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 19),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
      decoration: BoxDecoration(
        gradient: AppDecor.gradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppDecor.shadow(.28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bienvenue',
                    style: AppDecor.t(20, w: FontWeight.w700, c: Colors.white)),
                const SizedBox(height: 6),
                Text('Votre suivi médical\ncommence ici.',
                    style: AppDecor.t(13,
                        c: Colors.white.withValues(alpha: .88), h: 1.5)),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Compléter mon profil',
                      style: AppDecor.t(12, w: FontWeight.w700, c: AppDecor.primaryDark)),
                ),
              ],
            ),
          ),
          // Remplace par ton illustration : assets/images/welcome.png
          SizedBox(
            width: 120,
            height: 110,
            child: Image.asset(
              'assets/images/welcome.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                  Icons.medical_services_rounded,
                  size: 70,
                  color: Colors.white.withValues(alpha: .4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.monitor_heart_rounded, 'Suivi'),
      (Icons.folder_copy_rounded, 'Documents'),
      (Icons.medication_rounded, 'Traitements'),
      (Icons.event_available_rounded, 'Rendez-vous'),
    ];
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => Container(
          width: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppDecor.shadow(.07),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(items[i].$1, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(items[i].$2,
                      style: AppDecor.t(11.5, w: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionTitle({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppDecor.t(17, w: FontWeight.w700)),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('Voir tout',
              style: AppDecor.t(12.5, w: FontWeight.w600, c: AppColors.primary)),
        ),
      ],
    );
  }
}

class _Doctor {
  final String name, specialty, image;
  const _Doctor(this.name, this.specialty, this.image);
}

class _DoctorList extends StatelessWidget {
  const _DoctorList();

  static const _doctors = [
    _Doctor('Dr Johnson Mike', 'Médecin généraliste',
        'assets/images/doctor1.png'),
    _Doctor('Dr Lawson Jennifer', 'Cardiologue',
        'assets/images/doctor2.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 262,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _doctors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _DoctorCard(doctor: _doctors[i]),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final _Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppDecor.shadow(.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: Image.asset(
                doctor.image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primaryLighter,
                  child: const Icon(Icons.person_rounded,
                      size: 56, color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(doctor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppDecor.t(13.5, w: FontWeight.w700)),
          Text(doctor.specialty, style: AppDecor.t(11.5, c: AppColors.textMuted)),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppDecor.gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('Réserver',
                      style: AppDecor.t(12.5, w: FontWeight.w700, c: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
