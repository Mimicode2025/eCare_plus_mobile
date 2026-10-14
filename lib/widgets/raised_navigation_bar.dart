import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

class _Destination {
  final String label;
  final IconData icon, selectedIcon;
  const _Destination(this.label, this.icon, this.selectedIcon);
}

/// Four destinations surrounding a fixed, independent add action.
class RaisedNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onAddMeasurement;
  const RaisedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onAddMeasurement,
  }) : assert(selectedIndex >= 0 && selectedIndex < 4);

  static const _destinations = [
    _Destination(
      'Accueil',
      CupertinoIcons.house_alt,
      CupertinoIcons.house_alt_fill,
    ),
    _Destination(
      'Rendez-vous',
      Icons.calendar_month_outlined,
      Icons.calendar_month_rounded,
    ),
    _Destination('Articles', CupertinoIcons.book, CupertinoIcons.book_fill),
    _Destination('Paramètres', Icons.settings_outlined, Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final insets = MediaQuery.paddingOf(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - insets.left - insets.right;
        final contentWidth = math.min(available, 680.0);
        final side = insets.left + (available - contentWidth) / 2;
        final cellWidth = contentWidth / 5;
        final diameter = math.min(52.0, cellWidth - 4);
        final labelStyle = AppDecor.t(10, w: FontWeight.w600, h: 1.25);
        var labelHeight = 0.0;
        for (final destination in _destinations) {
          final painter = TextPainter(
            text: TextSpan(text: destination.label, style: labelStyle),
            textDirection: direction,
            textScaler: textScaler,
          )..layout(maxWidth: cellWidth - 8);
          labelHeight = math.max(labelHeight, painter.height);
          painter.dispose();
        }
        const labelTop = 52.0;
        final contentHeight = labelTop + labelHeight.ceilToDouble() + 8;
        final center = side + contentWidth / 2;
        return SizedBox(
          height: contentHeight + math.max(6.0, insets.bottom),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _NavigationSurface(
                      center: center,
                      shoulder: math.min(56.0, cellWidth),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: side,
                width: contentWidth,
                top: 0,
                height: contentHeight,
                child: Row(
                  children: [
                    for (var slot = 0; slot < 5; slot++)
                      if (slot == 2)
                        const Expanded(child: SizedBox())
                      else
                        Expanded(
                          child: _destination(
                            slot < 2 ? slot : slot - 1,
                            duration,
                            labelTop,
                            labelStyle,
                          ),
                        ),
                  ],
                ),
              ),
              Positioned(
                left: center - diameter / 2,
                top: 0,
                width: diameter,
                height: diameter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navigationBlue.withValues(alpha: .22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Material(
                      color: AppColors.navigationBlue,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: Tooltip(
                        message: 'Ajouter mes constantes',
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onAddMeasurement,
                          child: Semantics(
                            button: true,
                            label: 'Ajouter mes constantes',
                            child: ExcludeSemantics(
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _destination(
    int index,
    Duration duration,
    double labelTop,
    TextStyle labelStyle,
  ) {
    final destination = _destinations[index];
    final selected = selectedIndex == index;
    void select() => onDestinationSelected(index);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.label,
      onTap: select,
      child: ExcludeSemantics(
        child: Tooltip(
          message: destination.label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: select,
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned(
                    top: 28,
                    left: 0,
                    right: 0,
                    child: Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      size: 22,
                      color: selected
                          ? AppColors.navigationBlue
                          : AppColors.textMuted,
                    ),
                  ),
                  Positioned(
                    top: labelTop,
                    left: 4,
                    right: 4,
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      style: labelStyle.copyWith(
                        color: selected
                            ? AppColors.navigationBlue
                            : AppColors.textMuted,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      child: Text(
                        destination.label,
                        textAlign: TextAlign.center,
                      ),
                    ),
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

class _NavigationSurface extends CustomPainter {
  final double center, shoulder;
  _NavigationSurface({required this.center, required this.shoulder});

  @override
  void paint(Canvas canvas, Size size) {
    const baseline = 20.0;
    const corner = 18.0;
    final left = math.max(corner, center - shoulder);
    final right = math.min(size.width - corner, center + shoulder);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baseline + corner)
      ..quadraticBezierTo(0, baseline, corner, baseline)
      ..lineTo(left, baseline)
      ..cubicTo(
        left + (center - left) * .55,
        baseline,
        center - (center - left) * .5,
        0,
        center,
        0,
      )
      ..cubicTo(
        center + (right - center) * .5,
        0,
        right - (right - center) * .55,
        baseline,
        right,
        baseline,
      )
      ..lineTo(size.width - corner, baseline)
      ..quadraticBezierTo(size.width, baseline, size.width, baseline + corner)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawShadow(
      path,
      AppColors.textDark.withValues(alpha: .12),
      7,
      false,
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_NavigationSurface oldDelegate) =>
      oldDelegate.center != center || oldDelegate.shoulder != shoulder;
}
