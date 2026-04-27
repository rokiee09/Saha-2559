import 'dart:math' as math;

import 'package:flutter/material.dart';

/// `assets/images/Flag_of_Turkey.svg.png` varsa; yoksa [TurkishFlagCircleIcon] (çizim).
class TurkishFlagAssetCircleIcon extends StatelessWidget {
  const TurkishFlagAssetCircleIcon({super.key, this.size = 40});

  final double size;

  static const kAssetPath = 'assets/images/Flag_of_Turkey.svg.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          kAssetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => TurkishFlagCircleIcon(size: size),
        ),
      ),
    );
  }
}

/// Kırmızı zemin, beyaz ay yıldız (şehit listesi gibi alanlarda yuvarlak rozet).
class TurkishFlagCircleIcon extends StatelessWidget {
  const TurkishFlagCircleIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
        painter: _TurkishFlagInCirclePainter(),
      ),
    );
  }
}

class _TurkishFlagInCirclePainter extends CustomPainter {
  const _TurkishFlagInCirclePainter();

  static const _red = Color(0xFFE30A17);
  static const _white = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    canvas.drawCircle(c, r, Paint()..color = _red);

    // Hilal: büyük beyaz daire, sağdan kırmızı ile kesişen küçük daire
    final moonR = r * 0.44;
    final mcx = c.dx - r * 0.1;
    final mcy = c.dy;
    canvas.drawCircle(Offset(mcx, mcy), moonR, Paint()..color = _white);
    canvas.drawCircle(
      Offset(mcx + r * 0.16, mcy),
      moonR * 0.86,
      Paint()..color = _red,
    );

    // Yıldız (beşgen)
    final starC = Offset(c.dx + r * 0.3, c.dy);
    _fillStar(
      canvas,
      center: starC,
      outerR: r * 0.15,
      paint: Paint()..color = _white,
    );

    canvas.restore();

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.02,
    );
  }

  void _fillStar(
    Canvas canvas, {
    required Offset center,
    required double outerR,
    required Paint paint,
  }) {
    const points = 5;
    const innerScale = 0.38;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final a = (i * math.pi / points) - math.pi / 2;
      final rad = i.isEven ? outerR : outerR * innerScale;
      final p = Offset(
        center.dx + rad * math.cos(a),
        center.dy + rad * math.sin(a),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
