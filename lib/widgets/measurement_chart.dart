import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

class MeasurementPoint {
  final DateTime date;
  final double primary;
  final double? secondary;
  const MeasurementPoint(this.date, this.primary, [this.secondary]);
}

class MeasurementChart extends StatelessWidget {
  final List<MeasurementPoint> points;
  final DateTime start;
  final DateTime end;
  final bool pressure;
  const MeasurementChart({
    super.key,
    required this.points,
    required this.start,
    required this.end,
    this.pressure = false,
  });

  @override
  Widget build(BuildContext context) {
    final maximum = points.fold<double>(
      0,
      (value, point) =>
          math.max(value, math.max(point.primary, point.secondary ?? 0)),
    );
    final rawStep = (maximum == 0 ? 100 : math.max(1.0, maximum)) / 4 * 1.1;
    final magnitude = math
        .pow(10, (math.log(rawStep) / math.ln10).floor())
        .toDouble();
    final step =
        [1.0, 2.0, 5.0, 10.0].firstWhere(
          (factor) => factor * magnitude >= rawStep,
          orElse: () => 10,
        ) *
        magnitude;
    final roundedMax = step * 4;
    final maxY = roundedMax.isFinite ? roundedMax : maximum;
    return Semantics(
      label: pressure
          ? 'Graphique de tension artérielle en millimètres de mercure, ${points.length} mesures.'
          : 'Graphique de glycémie en milligrammes par décilitre, ${points.length} mesures.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pressure ? 'mmHg' : 'mg/dL',
            style: AppDecor.t(11, c: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 4; i >= 0; i--)
                        Text(
                          maxY >= 10000
                              ? (maxY * (i / 4)).toStringAsExponential(0)
                              : (maxY * (i / 4)).toStringAsFixed(
                                  step < 1 ? 1 : 0,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppDecor.t(10, c: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LinePainter(points, start, end, maxY),
                        ),
                      ),
                      if (points.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Aucune mesure\nsur cette période',
                              textAlign: TextAlign.center,
                              style: AppDecor.t(
                                12,
                                c: AppColors.textMuted,
                                h: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${start.day}/${start.month}',
                    style: AppDecor.t(10, c: AppColors.textMuted),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${end.day}/${end.month}',
                    textAlign: TextAlign.right,
                    style: AppDecor.t(10, c: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              ChartLegend(
                color: AppColors.primary,
                label: pressure ? 'Systolique' : 'Glycémie',
              ),
              if (pressure)
                const ChartLegend(
                  color: Color(0xFF315D85),
                  label: 'Diastolique',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const ChartLegend({super.key, required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Flexible(
        child: Text(label, style: AppDecor.t(11, c: AppColors.textMuted)),
      ),
    ],
  );
}

class _LinePainter extends CustomPainter {
  final List<MeasurementPoint> points;
  final DateTime start, end;
  final double maxY;
  _LinePainter(this.points, this.start, this.end, this.maxY);
  @override
  void paint(Canvas canvas, Size size) {
    final top = 5.0;
    final height = size.height - 10;
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = top + height * i / 4;
      canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), grid);
    }
    if (points.isEmpty) return;
    final duration = math.max(1, end.difference(start).inMilliseconds);
    Offset position(MeasurementPoint point, double value) => Offset(
      4 +
          (size.width - 8) *
              (point.date.difference(start).inMilliseconds / duration).clamp(
                0,
                1,
              ),
      top + height * (1 - value / maxY),
    );
    void series(Color color, bool secondary) {
      final entries = points
          .where((point) => !secondary || point.secondary != null)
          .toList();
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var i = 0; i < entries.length; i++) {
        final point = position(
          entries[i],
          secondary ? entries[i].secondary! : entries[i].primary,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
      for (final entry in entries) {
        final point = position(
          entry,
          secondary ? entry.secondary! : entry.primary,
        );
        canvas.drawCircle(point, 4, Paint()..color = color);
        canvas.drawCircle(point, 1.5, Paint()..color = Colors.white);
      }
    }

    series(AppColors.primary, false);
    if (points.any((point) => point.secondary != null)) {
      series(const Color(0xFF315D85), true);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.maxY != maxY;
}

class MeasurementDistribution extends StatelessWidget {
  final List<DateTime> dates;
  const MeasurementDistribution({super.key, required this.dates});
  @override
  Widget build(BuildContext context) {
    final counts = [
      dates.where((date) => date.hour < 12).length,
      dates.where((date) => date.hour >= 12 && date.hour < 18).length,
      dates.where((date) => date.hour >= 18).length,
    ];
    const colors = [AppColors.primary, Color(0xFF8BC8F0), Color(0xFF315D85)];
    final ring = SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RingPainter(counts, colors)),
          ),
          Text('${dates.length}', style: AppDecor.t(23, w: FontWeight.w700)),
        ],
      ),
    );
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ChartLegend(
              color: colors[i],
              label: '${['Matin', 'Après-midi', 'Soir'][i]} · ${counts[i]}',
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 290 ||
            MediaQuery.textScalerOf(context).scale(12) > 18) {
          return Column(children: [ring, const SizedBox(height: 16), legend]);
        }
        return Row(
          children: [
            ring,
            const SizedBox(width: 24),
            Expanded(child: legend),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<int> counts;
  final List<Color> colors;
  _RingPainter(this.counts, this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(10);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawOval(rect, paint..color = AppColors.border);
    final total = counts.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return;
    var start = -math.pi / 2;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;
      final sweep = 2 * math.pi * counts[i] / total;
      final gap = math.min(.05, sweep * .1);
      canvas.drawArc(
        rect,
        start + gap / 2,
        sweep - gap,
        false,
        paint..color = colors[i],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.counts != counts;
}
