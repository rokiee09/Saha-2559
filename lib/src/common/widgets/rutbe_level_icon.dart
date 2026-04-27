import 'package:flutter/material.dart';

/// Emniyet rütbe listesinde (en alttan en üste) gösterim için soyut çizgi ikonu.
/// Amblem veya rozet yerine, seviyeye göre artan yatay bant sayısı kullanılır.
class RutbeLevelIcon extends StatelessWidget {
  const RutbeLevelIcon({
    super.key,
    required this.levelIndex,
    this.size = 40,
  });

  /// 0 = en alt rütbe (Polis Memuru), 11 = en üst (Sınıf Üstü Emniyet Müdürü).
  final int levelIndex;

  final double size;

  /// Rütbe listesi için bant sayısı (hiyerarşi grupları).
  static int bandCountForLevel(int level) {
    const bands = <int>[
      1, 1, 1, // memur
      2, 2, 2, 2, // amir
      3, 3, 3, 3, // sınıf müdür
      4, // sınıf üstü
    ];
    if (level < 0 || level >= bands.length) return 3;
    return bands[level];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.primary;
    final bands = bandCountForLevel(levelIndex);
    return Semantics(
      label: 'Rütbe seviyesi $bands',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RutbeBandPainter(
            bands: bands,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _RutbeBandPainter extends CustomPainter {
  _RutbeBandPainter({required this.bands, required this.color});

  final int bands;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (bands <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const padX = 3.0;
    const padY = 3.0;
    final w = size.width - 2 * padX;
    final h = size.height - 2 * padY;
    for (var i = 0; i < bands; i++) {
      final t = (i + 1) / (bands + 1);
      final y = padY + h * t;
      final lineFrac = 0.42 + 0.58 * (i + 1) / bands;
      final lineW = w * lineFrac;
      final x0 = padX + (w - lineW) / 2;
      canvas.drawLine(
        Offset(x0, y),
        Offset(x0 + lineW, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RutbeBandPainter oldDelegate) {
    return oldDelegate.bands != bands || oldDelegate.color != color;
  }
}

/// EGM rozet görselleri; yoksa [RutbeLevelIcon] (bant çizgisi) kullanılır.
class RutbeRankIcon extends StatelessWidget {
  const RutbeRankIcon({super.key, required this.levelIndex, this.size = 40});

  final int levelIndex;
  final double size;

  /// [RutbeTeskilatPage] sırası ile `assets/images/*.png` eşlemesi.
  static const _assetByLevel = <String?>[
    'assets/images/polis_memuru.png',
    'assets/images/baspolis_memuru.png',
    'assets/images/kidemli_baspolis_memuru.png',
    'assets/images/komiser_yardimcisi.png',
    'assets/images/komiser.png',
    'assets/images/baskomiser.png',
    'assets/images/emniyet_amiri.png',
    'assets/images/4sinif_emniyet_muduru.png',
    'assets/images/3sinif_emniyet_muduru.png',
    'assets/images/2sinif_emniyet_muduru.png',
    'assets/images/1-1sinif_emniyet_muduru.png', // 1. sınıf
    'assets/images/1-2sinif_emniyet_muduru.png', // sınıf üstü
  ];

  @override
  Widget build(BuildContext context) {
    final path = (levelIndex >= 0 && levelIndex < _assetByLevel.length)
        ? _assetByLevel[levelIndex]
        : null;
    if (path == null) {
      return RutbeLevelIcon(levelIndex: levelIndex, size: size);
    }
    return Semantics(
      label: 'Rütbe rozet',
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              RutbeLevelIcon(levelIndex: levelIndex, size: size),
        ),
      ),
    );
  }
}
