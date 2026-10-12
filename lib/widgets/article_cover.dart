import 'package:flutter/material.dart';
import '../data/article_catalog.dart';

/// Local vector artwork is crisp at every size and available offline.
class ArticleCover extends StatelessWidget {
  final ArticlePreview article;
  const ArticleCover({super.key, required this.article});
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: article.background,
    child: article.artwork == 0
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/images/ecareImage1.png',
              fit: BoxFit.contain,
            ),
          )
        : CustomPaint(
            painter: _CoverPainter(article),
            child: const SizedBox.expand(),
          ),
  );
}

class _CoverPainter extends CustomPainter {
  final ArticlePreview article;
  _CoverPainter(this.article);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 240, size.height / 160);
    final paint = Paint()..color = article.accent;
    canvas.drawCircle(
      const Offset(122, 84),
      61,
      Paint()..color = Colors.white.withValues(alpha: .35),
    );
    canvas.drawCircle(
      const Offset(206, 22),
      39,
      Paint()..color = article.accent.withValues(alpha: .08),
    );
    canvas.drawCircle(
      const Offset(12, 160),
      47,
      Paint()..color = article.accent.withValues(alpha: .09),
    );
    for (final p in [const Offset(43, 37), const Offset(194, 113)]) {
      final detail = Paint()
        ..color = article.accent.withValues(alpha: .45)
        ..strokeWidth = 2;
      canvas.drawLine(p - const Offset(5, 0), p + const Offset(5, 0), detail);
      canvas.drawLine(p - const Offset(0, 5), p + const Offset(0, 5), detail);
    }
    switch (article.artwork) {
      case 1:
        final drop = Path()
          ..moveTo(120, 30)
          ..cubicTo(110, 53, 85, 76, 85, 98)
          ..cubicTo(85, 142, 155, 142, 155, 98)
          ..cubicTo(155, 76, 130, 53, 120, 30)
          ..close();
        canvas.drawShadow(
          drop,
          article.accent.withValues(alpha: .25),
          5,
          false,
        );
        canvas.drawPath(drop, paint);
        canvas.drawArc(
          const Rect.fromLTWH(99, 86, 34, 30),
          .7,
          1.6,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: .7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
      case 2:
        final heart = Path()
          ..moveTo(120, 129)
          ..cubicTo(104, 117, 73, 94, 73, 70)
          ..cubicTo(73, 39, 107, 35, 120, 57)
          ..cubicTo(137, 34, 168, 40, 168, 70)
          ..cubicTo(168, 94, 137, 116, 120, 129)
          ..close();
        canvas.drawShadow(
          heart,
          article.accent.withValues(alpha: .2),
          5,
          false,
        );
        canvas.drawPath(heart, paint);
        final pulse = Path()
          ..moveTo(87, 84)
          ..lineTo(105, 84)
          ..lineTo(114, 70)
          ..lineTo(126, 98)
          ..lineTo(136, 81)
          ..lineTo(154, 81);
        canvas.drawPath(
          pulse,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round,
        );
      case 3:
        canvas.drawCircle(const Offset(117, 81), 43, paint);
        canvas.drawCircle(
          const Offset(138, 64),
          36,
          Paint()..color = Color.lerp(article.background, Colors.white, .35)!,
        );
        final star = Path()
          ..moveTo(159, 92)
          ..lineTo(163, 104)
          ..lineTo(175, 108)
          ..lineTo(163, 112)
          ..lineTo(159, 124)
          ..lineTo(155, 112)
          ..lineTo(143, 108)
          ..lineTo(155, 104)
          ..close();
        canvas.drawPath(star, Paint()..color = const Color(0xFFE4B762));
        canvas.drawCircle(const Offset(86, 39), 3, paint);
      default:
        canvas.drawLine(
          const Offset(122, 125),
          const Offset(122, 54),
          Paint()
            ..color = article.accent
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
        for (var i = 0; i < 3; i++) {
          final y = 63.0 + i * 22;
          final left = Path()
            ..moveTo(122, y + 14)
            ..quadraticBezierTo(82, y + 16, 84, y - 13)
            ..quadraticBezierTo(113, y - 16, 122, y + 14)
            ..close();
          final right = Path()
            ..moveTo(122, y + 4)
            ..quadraticBezierTo(126, y - 23, 158, y - 22)
            ..quadraticBezierTo(160, y + 7, 122, y + 4)
            ..close();
          canvas.drawPath(
            left,
            Paint()..color = article.accent.withValues(alpha: .7),
          );
          canvas.drawPath(right, paint);
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(98, 120, 48, 12),
            const Radius.circular(6),
          ),
          Paint()..color = article.accent.withValues(alpha: .2),
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoverPainter oldDelegate) =>
      oldDelegate.article != article;
}
