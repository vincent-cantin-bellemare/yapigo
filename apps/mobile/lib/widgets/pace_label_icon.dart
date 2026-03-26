import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/theme/app_theme.dart';

Widget intensityLevelIcon(IntensityLevel level, {double size = 24}) {
  final index = IntensityLevel.values.indexOf(level);
  return _SpeedometerIcon(
    level: index,
    total: IntensityLevel.values.length,
    size: size,
  );
}

class _SpeedometerIcon extends StatelessWidget {
  const _SpeedometerIcon({
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
        painter: _SpeedometerPainter(
          level: level,
          total: total,
          trackColor: AppTheme.slateGrey.withValues(alpha: 0.2),
          fillColor: _colorForLevel(level),
          needleColor: AppTheme.navy,
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

class _SpeedometerPainter extends CustomPainter {
  _SpeedometerPainter({
    required this.level,
    required this.total,
    required this.trackColor,
    required this.fillColor,
    required this.needleColor,
  });

  final int level;
  final int total;
  final Color trackColor;
  final Color fillColor;
  final Color needleColor;

  static const double _startAngle = 0.75 * math.pi;
  static const double _sweepAngle = 1.5 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    final strokeWidth = size.width * 0.12;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);

    final fillFraction = (level + 1) / total;
    final fillSweep = _sweepAngle * fillFraction;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _startAngle, fillSweep, false, fillPaint);

    final needleAngle = _startAngle + _sweepAngle * fillFraction;
    final needleLength = radius * 0.65;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    final dotPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.06, dotPaint);
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) =>
      level != old.level || fillColor != old.fillColor;
}
