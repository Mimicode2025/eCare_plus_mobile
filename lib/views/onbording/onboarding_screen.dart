import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';

/// Données pour chaque page d'onboarding
class _OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Maîtrisez votre\nparcours de soin',
      subtitle:
          'Suivez l\'évolution de vos symptômes et de vos constantes vitales en temps réel.',
      icon: Icons.monitor_heart_rounded,
      iconBg: Color(0xFFE0F3FF),
    ),
    _OnboardingData(
      title: 'Votre allié 24h/24\net 7j/7',
      subtitle:
          'Une question ? Un doute ? Discutez instantanément avec votre médecin spécialisé.',
      icon: Icons.support_agent_rounded,
      iconBg: Color(0xFFE8F5FF),
    ),
    _OnboardingData(
      title: 'Reprenez le pouvoir\nsur votre santé',
      subtitle:
          'Grâce à l\'accompagnement intelligent d\'eCARE+, votre traitement devient simple et personnalisé.',
      icon: Icons.favorite_rounded,
      iconBg: Color(0xFFD9F0FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fond décoratif
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLighter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Bouton Skip
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 20),
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Ignorer',
                        style: AppTextStyles.link,
                      ),
                    ),
                  ),
                ),

                // Pages d'onboarding
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        fadeAnim: _fadeAnim,
                        slideAnim: _slideAnim,
                        screenSize: size,
                      );
                    },
                  ),
                ),

                // Dots de pagination
                _DotsIndicator(
                  count: _pages.length,
                  current: _currentPage,
                ),
                const SizedBox(height: 20),

                // Bouton d'action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: PrimaryButton(
                    text: isLastPage ? 'Commencer !' : 'Suivant',
                    onPressed: _nextPage,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final Size screenSize;

  const _OnboardingPage({
    required this.data,
    required this.fadeAnim,
    required this.slideAnim,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration (icône grande dans un cercle coloré)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Taille adaptative : max 220 pour éviter l'overflow
                  final double outerSize =
                      (screenSize.width * 0.52).clamp(160.0, 220.0);
                  final double innerSize = outerSize * 0.58;
                  final double iconSize = outerSize * 0.32;
                  return Container(
                    width: outerSize,
                    height: outerSize,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: innerSize,
                        height: innerSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data.icon,
                          size: iconSize,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Titre
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 22,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicateur de points (pagination)
class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
