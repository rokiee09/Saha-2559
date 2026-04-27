import 'package:flutter/material.dart';

import '../theme/police_colors.dart';

/// Çok hafif lacivert doku; kırmızı / parlak yok.
class PoliceFiligranLayer extends StatelessWidget {
  const PoliceFiligranLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _NavyFiligranPainter(isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _NavyFiligranPainter extends CustomPainter {
  _NavyFiligranPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = PoliceColors.navy;
    final g1 = RadialGradient(
      center: const Alignment(-0.9, -0.85),
      radius: 1.1,
      colors: [
        base.withValues(alpha: isDark ? 0.1 : 0.05),
        Colors.transparent,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = g1.createShader(rect));

    final g2 = RadialGradient(
      center: const Alignment(0.85, 0.9),
      radius: 0.95,
      colors: [
        base.withValues(alpha: isDark ? 0.06 : 0.03),
        Colors.transparent,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = g2.createShader(rect));

    final line = Paint()
      ..color = base.withValues(alpha: isDark ? 0.04 : 0.02)
      ..strokeWidth = 1;
    const step = 80.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * 0.8, size.height), line);
    }
  }

  @override
  bool shouldRepaint(covariant _NavyFiligranPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
