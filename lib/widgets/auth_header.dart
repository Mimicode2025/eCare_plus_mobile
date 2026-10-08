import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// En-tête signature d'eCare+ : dégradé profond, bord en vague et
/// un battement de cœur (ECG) qui se dessine à l'ouverture de la page.
class AuthHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final double height;
  final bool showBack;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 300,
    this.showBack = false,
  });

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..forward();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(AppColors.primary, const Color(0xFF06214A), .55)!;
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [deep, AppColors.primary, const Color(0xFF3BBFF3)],
            stops: const [0, .55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: _Orb(size: 220, alpha: 22),
            ),
            Positioned(
              top: 90,
              left: -80,
              child: _Orb(size: 170, alpha: 14),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, _) => CustomPaint(
                  painter: _EcgPainter(
                    Curves.easeInOut.transform(_pulse.value),
                    widget.height - 92,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.showBack) ...[
                          _GlassButton(onTap: () => Navigator.pop(context)),
                          const SizedBox(width: 12),
                        ],
                        const _LogoMark(),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      widget.title,
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withAlpha(215),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final int alpha;
  const _Orb({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(alpha),
        ),
      );
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.favorite_rounded,
              color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          'eCare+',
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retour',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(70)),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..lineTo(0, s.height - 44)
    ..quadraticBezierTo(s.width * .25, s.height, s.width * .55, s.height - 30)
    ..quadraticBezierTo(s.width * .82, s.height - 58, s.width, s.height - 26)
    ..lineTo(s.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _EcgPainter extends CustomPainter {
  final double t;
  final double baseY;
  _EcgPainter(this.t, this.baseY);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Path()
      ..moveTo(0, baseY)
      ..lineTo(w * .30, baseY)
      ..lineTo(w * .36, baseY - 8)
      ..lineTo(w * .41, baseY)
      ..lineTo(w * .46, baseY + 10)
      ..lineTo(w * .52, baseY - 46)
      ..lineTo(w * .58, baseY + 22)
      ..lineTo(w * .63, baseY)
      ..lineTo(w * .70, baseY - 12)
      ..lineTo(w * .76, baseY)
      ..lineTo(w, baseY);

    final line = Paint()
      ..color = Colors.white.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final PathMetric m = p.computeMetrics().first;
    final len = m.length * t;
    canvas.drawPath(m.extractPath(0, len), line);

    if (t < 1) {
      final tip = m.getTangentForOffset(len)?.position;
      if (tip != null) {
        canvas.drawCircle(tip, 7, Paint()..color = Colors.white.withAlpha(60));
        canvas.drawCircle(tip, 3.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) => old.t != t;
}
