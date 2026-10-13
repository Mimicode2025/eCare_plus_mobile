import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// A rolling history of the actual microphone level in dBFS.
class RecordingWaveform extends StatefulWidget {
  final Stream<double> levels;
  const RecordingWaveform({super.key, required this.levels});
  @override
  State<RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<RecordingWaveform> {
  final _samples = <double>[];
  StreamSubscription<double>? _subscription;
  bool _available = true;
  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _subscription = widget.levels.listen(
      (db) {
        if (!mounted || !db.isFinite) return;
        final value = ((db + 60) / 60).clamp(0.0, 1.0);
        setState(() {
          _available = true;
          _samples.add(value);
          if (_samples.length > 128) _samples.removeAt(0);
        });
      },
      onError: (Object _) {
        if (mounted) setState(() => _available = false);
      },
    );
  }

  @override
  void didUpdateWidget(covariant RecordingWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levels != widget.levels) {
      unawaited(_subscription?.cancel());
      _samples.clear();
      _listen();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Niveau sonore du microphone',
    value: _available
        ? '${((_samples.lastOrNull ?? 0) * 100).round()} %'
        : 'Indisponible',
    child: ExcludeSemantics(
      child: SizedBox(
        height: 44,
        child: _available
            ? CustomPaint(painter: _WavePainter(List.of(_samples)))
            : const Center(
                child: Icon(Icons.mic_off_outlined, color: AppColors.textMuted),
              ),
      ),
    ),
  );
}

class _WavePainter extends CustomPainter {
  final List<double> samples;
  _WavePainter(this.samples);
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 5.0;
    const width = 2.8;
    final count = math.max(1, (size.width / spacing).floor());
    final visible = samples.length > count
        ? samples.sublist(samples.length - count)
        : samples;
    final active = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE6A269), AppColors.navigationBlue],
      ).createShader(Offset.zero & size);
    final inactive = Paint()
      ..color = AppColors.navigationBlue.withValues(alpha: .13);
    for (var i = 0; i < count; i++) {
      final height = i < visible.length
          ? 4 + math.pow(visible[i], .7) * (size.height - 8)
          : 6.0;
      final rect = Rect.fromLTWH(
        i * spacing + (spacing - width) / 2,
        (size.height - height) / 2,
        width,
        height.toDouble(),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        i < visible.length ? active : inactive,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
