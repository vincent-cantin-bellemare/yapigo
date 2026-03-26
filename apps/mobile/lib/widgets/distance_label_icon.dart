import 'package:flutter/material.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/theme/app_theme.dart';

Widget distanceLabelIcon(DistanceLabel distance, {double size = 24}) {
  final level = DistanceLabel.values.indexOf(distance);
  return _ConcentricCirclesIcon(level: level, total: DistanceLabel.values.length, size: size);
}

class _ConcentricCirclesIcon extends StatelessWidget {
  const _ConcentricCirclesIcon({
    required this.level,
    required this.total,
    required this.size,
  });

  final int level;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ConcentricPainter(
          rings: level + 1,
          maxRings: total,
          ringColor: _colorForLevel(level),
          trackColor: AppTheme.slateGrey.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  static Color _colorForLevel(int level) {
    const colors = [
      AppTheme.teal,
      AppTheme.teal,
      AppTheme.warning,
      AppTheme.ocean,
      AppTheme.error,
    ];
    return colors[level.clamp(0, colors.length - 1)];
  }
}

class _ConcentricPainter extends CustomPainter {
  _ConcentricPainter({
    required this.rings,
    required this.maxRings,
    required this.ringColor,
    required this.trackColor,
  });

  final int rings;
  final int maxRings;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.42;
    final strokeWidth = size.width * 0.07;
    final gap = (maxRadius - strokeWidth) / maxRings;

    for (int i = 0; i < maxRings; i++) {
      final radius = gap * (i + 1);
      final isActive = i < rings;

      final paint = Paint()
        ..color = isActive
            ? ringColor.withValues(alpha: 0.3 + 0.7 * (i + 1) / maxRings)
            : trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, paint);
    }

    final dotPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.07, dotPaint);
  }

  @override
  bool shouldRepaint(_ConcentricPainter old) =>
      rings != old.rings || ringColor != old.ringColor;
}
