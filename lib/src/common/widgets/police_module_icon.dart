import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/police_colors.dart';

/// Menü modülü: Phosphor ikon + renkli rozet (emoji yerine).
///
/// [icon] için [IconData] (Regular/Bold/Fill) veya iki katmanlı
/// [PhosphorDuotoneIconData] kullanılabilir. Duotone'da [color] çizgi,
/// [duotoneFillColor] iç dolgu (pasta dilimi vb.) rengidir.
class PoliceModuleStyle {
  const PoliceModuleStyle({
    required this.icon,
    required this.color,
    this.duotoneFillColor,
    this.duotoneFillOpacity = 0.42,
    this.dualPieSlices = false,
    this.pieSliceColor,
  });

  final Object icon;
  final Color color;
  final Color? duotoneFillColor;
  final double duotoneFillOpacity;

  /// Rozette iki renkli pasta (lacivert + kırmızı dilim).
  final bool dualPieSlices;
  final Color? pieSliceColor;

  bool get isDuotone => icon is PhosphorDuotoneIconData;
}

/// Uygulama genelinde tutarlı modül ikonları ve renkleri.
abstract final class PoliceModules {
  PoliceModules._();

  /// Rozet kenarlığı / çizgi rengi (çoğu modülde koyu ton).
  static const Color _lacivert = Color(0xFF1E3A6E);
  static const Color _kirmizi = Color(0xFFE53935);

  static const profilim = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.userCircle,
    color: Color(0xFF2563EB),
    duotoneFillColor: Color(0xFF93C5FD),
    duotoneFillOpacity: 0.7,
  );
  static const basari = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.trophy,
    color: Color(0xFFD97706),
    duotoneFillColor: Color(0xFFFDE68A),
    duotoneFillOpacity: 0.75,
  );
  static const ustunBasari = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.star,
    color: Color(0xFFEAB308),
    duotoneFillColor: Color(0xFFFEF08A),
    duotoneFillOpacity: 0.8,
  );
  static const egitim = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.graduationCap,
    color: Color(0xFF7C3AED),
    duotoneFillColor: Color(0xFFC4B5FD),
    duotoneFillOpacity: 0.65,
  );
  static const gorevGunlugu = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.clipboardText,
    color: Color(0xFF059669),
    duotoneFillColor: Color(0xFF6EE7B7),
    duotoneFillOpacity: 0.6,
  );
  static const atisTakip = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.target,
    color: _kirmizi,
    duotoneFillColor: Color(0xFFFCA5A5),
    duotoneFillOpacity: 0.7,
  );
  static const gazilik = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.medalMilitary,
    color: Color(0xFFBE123C),
    duotoneFillColor: Color(0xFFFDA4AF),
    duotoneFillOpacity: 0.72,
  );
  static const tayin = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.mapPin,
    color: Color(0xFF15803D),
    duotoneFillColor: Color(0xFF86EFAC),
    duotoneFillOpacity: 0.65,
  );
  static const maas = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.wallet,
    color: Color(0xFF047857),
    duotoneFillColor: Color(0xFF34D399),
    duotoneFillOpacity: 0.6,
  );
  static const izin = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.calendarCheck,
    color: Color(0xFF0284C7),
    duotoneFillColor: Color(0xFF7DD3FC),
    duotoneFillOpacity: 0.65,
  );
  static const vardiya = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.clockCountdown,
    color: _lacivert,
    duotoneFillColor: Color(0xFF818CF8),
    duotoneFillOpacity: 0.6,
  );
  static const lojman = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.house,
    color: Color(0xFFEA580C),
    duotoneFillColor: Color(0xFFFDBA74),
    duotoneFillOpacity: 0.68,
  );
  static const rehber = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.addressBook,
    color: Color(0xFF16A34A),
    duotoneFillColor: Color(0xFFBBF7D0),
    duotoneFillOpacity: 0.62,
  );
  static const tutanak = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.fileText,
    color: Color(0xFF38BDF8),
    duotoneFillColor: Color(0xFFE0F2FE),
    duotoneFillOpacity: 0.82,
  );
  static const o1Gider = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.receipt,
    color: Color(0xFFC2410C),
    duotoneFillColor: Color(0xFFFED7AA),
    duotoneFillOpacity: 0.7,
  );
  static const notlar = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.notebook,
    color: Color(0xFFCA8A04),
    duotoneFillColor: Color(0xFFFEF08A),
    duotoneFillOpacity: 0.72,
  );
  static const aramaKararlari = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.scales,
    color: Color(0xFFFBBF24),
    duotoneFillColor: _lacivert,
    duotoneFillOpacity: 0.88,
  );
  static const telsiz = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.broadcast,
    color: Color(0xFF1D4ED8),
    duotoneFillColor: Color(0xFF60A5FA),
    duotoneFillOpacity: 0.62,
  );
  /// Phosphor 1.0.0 paketinde `candle` yok; anma alevi için `flame` kullanılır.
  static const sehitler = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.flame,
    color: _kirmizi,
    duotoneFillColor: Color(0xFFFECACA),
    duotoneFillOpacity: 0.75,
  );
  static const onemliGunler = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.calendarStar,
    color: Color(0xFFDB2777),
    duotoneFillColor: Color(0xFFFBCFE8),
    duotoneFillOpacity: 0.68,
  );
  static const kultur = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.books,
    color: Color(0xFFC9A34E),
    duotoneFillColor: Color(0xFFFEF08A),
    duotoneFillOpacity: 0.85,
  );
  static const tesekkurVefa = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.handsPraying,
    color: Color(0xFFBE185D),
    duotoneFillColor: Color(0xFFF9A8D4),
    duotoneFillOpacity: 0.65,
  );
  static const disiplin = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.gavel,
    color: Color(0xFF64748B),
    duotoneFillColor: Color(0xFFE2E8F0),
    duotoneFillOpacity: 0.5,
  );
  static const kariyerOzet = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.chartLineUp,
    color: Color(0xFF0D9488),
    duotoneFillColor: Color(0xFF5EEAD4),
    duotoneFillOpacity: 0.65,
  );
  /// Rozette lacivert + kırmızı iki dilimli pasta.
  static const emeklilik = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.chartPie,
    color: PoliceColors.emeklilikSliceNavy,
    duotoneFillColor: PoliceColors.emeklilikSliceRed,
    dualPieSlices: true,
    pieSliceColor: PoliceColors.emeklilikSliceRed,
  );
  static const saglik = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.heart,
    color: Color(0xFFE11D48),
    duotoneFillColor: Color(0xFFFDA4AF),
    duotoneFillOpacity: 0.78,
  );
  static const asistan = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.brain,
    color: Color(0xFF0369A1),
    duotoneFillColor: Color(0xFF7DD3FC),
    duotoneFillOpacity: 0.62,
  );
  static const mevzuat = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.books,
    color: _lacivert,
    duotoneFillColor: Color(0xFFBFDBFE),
    duotoneFillOpacity: 0.58,
  );
  static const araclar = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.wrench,
    color: Color(0xFF334155),
    duotoneFillColor: Color(0xFF94A3B8),
    duotoneFillOpacity: 0.55,
  );
  static const teskilat = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.buildings,
    color: Color(0xFF94A3B8),
    duotoneFillColor: Color(0xFF2D7EFF),
    duotoneFillOpacity: 0.78,
  );
  static const harcirah = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.airplaneTilt,
    color: Color(0xFF0891B2),
    duotoneFillColor: Color(0xFF67E8F9),
    duotoneFillOpacity: 0.68,
  );
  static const sifre = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.password,
    color: Color(0xFF65A30D),
    duotoneFillColor: Color(0xFFBEF264),
    duotoneFillOpacity: 0.7,
  );
  static const sifreKasa = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.vault,
    color: Color(0xFF15803D),
    duotoneFillColor: Color(0xFF86EFAC),
    duotoneFillOpacity: 0.6,
  );
  static const kriz = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.lifebuoy,
    color: Color(0xFFDB2777),
    duotoneFillColor: Color(0xFFF9A8D4),
    duotoneFillOpacity: 0.65,
  );
  static const ingilizce = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.translate,
    color: Color(0xFF0E7490),
    duotoneFillColor: Color(0xFFA5F3FC),
    duotoneFillOpacity: 0.68,
  );
  static const trafikRehberi = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.trafficSign,
    color: Color(0xFFEA580C),
    duotoneFillColor: Color(0xFFFDBA74),
    duotoneFillOpacity: 0.78,
  );
  static const idariParaCeza = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.coins,
    color: Color(0xFFF59E0B),
    duotoneFillColor: Color(0xFFFEF3C7),
    duotoneFillOpacity: 0.88,
  );
  static const taltif = PoliceModuleStyle(
    icon: PhosphorIconsDuotone.wallet,
    color: Color(0xFF059669),
    duotoneFillColor: Color(0xFF6EE7B7),
    duotoneFillOpacity: 0.62,
  );

  static PoliceModuleStyle forSahaCategory(String id) => switch (id) {
        'notlar' => notlar,
        'o1_gider' => o1Gider,
        'izin' => izin,
        'tutanak' => tutanak,
        'arama_karari' => aramaKararlari,
        'gorev_gunlugu' => gorevGunlugu,
        'atis_takip' => atisTakip,
        _ => notlar,
      };
}

/// Liste satırında renkli ikon rozeti.
class PoliceModuleIconBadge extends StatelessWidget {
  const PoliceModuleIconBadge({
    super.key,
    required this.style,
    this.size = 26,
    this.padding = 10,
    this.borderRadius = 12,
  });

  final PoliceModuleStyle style;
  final double size;
  final double padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: style.color.withValues(alpha: 0.35),
        ),
      ),
      child: style.dualPieSlices
          ? CustomPaint(
              size: Size(size, size),
              painter: _DualPieIconPainter(
                sliceNavy: style.color,
                sliceRed: style.pieSliceColor ?? PoliceColors.emeklilikSliceRed,
              ),
            )
          : PhosphorIcon(
              style.icon,
              color: style.color,
              size: size,
              duotoneSecondaryColor: style.duotoneFillColor ?? style.color,
              duotoneSecondaryOpacity: style.duotoneFillOpacity,
            ),
    );
  }
}

/// İki dilimli mini pasta (emeklilik rozeti).
class _DualPieIconPainter extends CustomPainter {
  const _DualPieIconPainter({
    required this.sliceNavy,
    required this.sliceRed,
  });

  final Color sliceNavy;
  final Color sliceRed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    const navySweep = math.pi * 1.15;
    const redSweep = math.pi * 2 - navySweep;

    canvas.drawArc(
      rect,
      start,
      navySweep,
      true,
      Paint()..color = sliceNavy,
    );
    canvas.drawArc(
      rect,
      start + navySweep,
      redSweep,
      true,
      Paint()..color = sliceRed,
    );
    canvas.drawCircle(
      center,
      radius * 0.38,
      Paint()..color = const Color(0xFF1A1F2B),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DualPieIconPainter oldDelegate) =>
      oldDelegate.sliceNavy != sliceNavy || oldDelegate.sliceRed != sliceRed;
}
