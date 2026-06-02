import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../common/theme/police_colors.dart';

/// Emeklilik ilerlemesi için halka (pasta) grafik.
class EmeklilikDonutChart extends StatelessWidget {
  const EmeklilikDonutChart({
    super.key,
    required this.progress,
    required this.color,
    this.size = 128,
    this.strokeWidth = 14,
    this.centerLabel,
    this.centerSubLabel,
  });

  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
  final String? centerLabel;
  final String? centerSubLabel;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          progress: p,
          color: color,
          trackColor: PoliceColors.outlineMuted.withValues(alpha: 0.35),
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(strokeWidth + 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (centerLabel != null)
                  Text(
                    centerLabel!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                if (centerSubLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    centerSubLabel!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 10.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
