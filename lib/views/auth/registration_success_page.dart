import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';

class RegistrationSuccessPage extends StatefulWidget {
  const RegistrationSuccessPage({super.key});

  @override
  State<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage>
    with SingleTickerProviderStateMixin {
  static const _items = [
    'Profil créé',
    'Pathologie configurée',
    'Données initiales enregistrées',
    'Notifications activées',
  ];

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  Animation<double> _iv(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(AppColors.primary, const Color(0xFF06214A), .55)!;
    final badge = _iv(0, .35, Curves.elasticOut);
    final title = _iv(.2, .45);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [deep, AppColors.primary, const Color(0xFF3BBFF3)],
            stops: const [0, .55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: badge,
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withAlpha(70),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: AppColors.primary, size: 64),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: title,
                      child: Column(
                        children: [
                          Text('Félicitations !',
                              style: AppTextStyles.heading1.copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          Text(
                            'Votre profil est configuré. Vous êtes prêt à prendre soin de votre santé.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                                color: Colors.white.withAlpha(225),
                                fontSize: 15,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(34),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white.withAlpha(70)),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < _items.length; i++)
                            _CheckRow(
                              label: _items[i],
                              animation: _iv(.30 + i * .1, .58 + i * .1),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _iv(.8, 1),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.home, (r) => false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text('Accéder à mon tableau de bord',
                              style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _iv(.85, 1),
                      child: Text('Commencez votre suivi de santé dès maintenant.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final Animation<double> animation;
  const _CheckRow({required this.label, required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(.12, 0), end: Offset.zero)
            .animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
