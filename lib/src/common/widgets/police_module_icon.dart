import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Menü modülü: Phosphor ikon + renkli rozet (emoji yerine).
class PoliceModuleStyle {
  const PoliceModuleStyle({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

/// Uygulama genelinde tutarlı modül ikonları ve renkleri.
abstract final class PoliceModules {
  PoliceModules._();

  static const profilim = PoliceModuleStyle(
    icon: PhosphorIconsRegular.userCircle,
    color: Color(0xFF60A5FA),
  );
  static const basari = PoliceModuleStyle(
    icon: PhosphorIconsRegular.trophy,
    color: Color(0xFFF59E0B),
  );
  static const ustunBasari = PoliceModuleStyle(
    icon: PhosphorIconsRegular.star,
    color: Color(0xFFFBBF24),
  );
  static const egitim = PoliceModuleStyle(
    icon: PhosphorIconsRegular.graduationCap,
    color: Color(0xFFA78BFA),
  );
  static const gorevGunlugu = PoliceModuleStyle(
    icon: PhosphorIconsRegular.clipboardText,
    color: Color(0xFF34D399),
  );
  static const atisTakip = PoliceModuleStyle(
    icon: PhosphorIconsRegular.target,
    color: Color(0xFFEF4444),
  );
  static const gazilik = PoliceModuleStyle(
    icon: PhosphorIconsRegular.medalMilitary,
    color: Color(0xFFE11D48),
  );
  static const tayin = PoliceModuleStyle(
    icon: PhosphorIconsRegular.mapPin,
    color: Color(0xFF22C55E),
  );
  static const maas = PoliceModuleStyle(
    icon: PhosphorIconsRegular.wallet,
    color: Color(0xFF10B981),
  );
  static const izin = PoliceModuleStyle(
    icon: PhosphorIconsRegular.calendarCheck,
    color: Color(0xFF38BDF8),
  );
  static const vardiya = PoliceModuleStyle(
    icon: PhosphorIconsRegular.clockCountdown,
    color: Color(0xFF6366F1),
  );
  static const lojman = PoliceModuleStyle(
    icon: PhosphorIconsRegular.house,
    color: Color(0xFFFB923C),
  );
  static const rehber = PoliceModuleStyle(
    icon: PhosphorIconsRegular.addressBook,
    color: Color(0xFF4ADE80),
  );
  static const tutanak = PoliceModuleStyle(
    icon: PhosphorIconsRegular.fileText,
    color: Color(0xFF94A3B8),
  );
  static const o1Gider = PoliceModuleStyle(
    icon: PhosphorIconsRegular.receipt,
    color: Color(0xFFF97316),
  );
  static const notlar = PoliceModuleStyle(
    icon: PhosphorIconsRegular.notebook,
    color: Color(0xFFFACC15),
  );
  static const aramaKararlari = PoliceModuleStyle(
    icon: PhosphorIconsRegular.scales,
    color: Color(0xFF818CF8),
  );
  static const telsiz = PoliceModuleStyle(
    icon: PhosphorIconsRegular.broadcast,
    color: Color(0xFF3B82F6),
  );
  /// Phosphor 1.0.0 paketinde `candle` yok; anma alevi için `flame` kullanılır.
  static const sehitler = PoliceModuleStyle(
    icon: PhosphorIconsRegular.flame,
    color: Color(0xFFF87171),
  );
  static const onemliGunler = PoliceModuleStyle(
    icon: PhosphorIconsRegular.calendarStar,
    color: Color(0xFFF472B6),
  );
  static const kultur = PoliceModuleStyle(
    icon: PhosphorIconsRegular.books,
    color: Color(0xFFEAB308),
  );
  static const tesekkurVefa = PoliceModuleStyle(
    icon: PhosphorIconsRegular.handsPraying,
    color: Color(0xFFFB7185),
  );
  static const disiplin = PoliceModuleStyle(
    icon: PhosphorIconsRegular.gavel,
    color: Color(0xFFCBD5E1),
  );
  static const kariyerOzet = PoliceModuleStyle(
    icon: PhosphorIconsRegular.chartLineUp,
    color: Color(0xFF2DD4BF),
  );
  static const asistan = PoliceModuleStyle(
    icon: PhosphorIconsRegular.brain,
    color: Color(0xFF38BDF8),
  );
  static const mevzuat = PoliceModuleStyle(
    icon: PhosphorIconsRegular.books,
    color: Color(0xFF93C5FD),
  );
  static const araclar = PoliceModuleStyle(
    icon: PhosphorIconsRegular.wrench,
    color: Color(0xFF94A3B8),
  );
  static const teskilat = PoliceModuleStyle(
    icon: PhosphorIconsRegular.buildings,
    color: Color(0xFF64748B),
  );
  static const harcirah = PoliceModuleStyle(
    icon: PhosphorIconsRegular.airplaneTilt,
    color: Color(0xFF22D3EE),
  );
  static const sifre = PoliceModuleStyle(
    icon: PhosphorIconsRegular.password,
    color: Color(0xFFA3E635),
  );
  static const sifreKasa = PoliceModuleStyle(
    icon: PhosphorIconsRegular.vault,
    color: Color(0xFF86EFAC),
  );
  static const kriz = PoliceModuleStyle(
    icon: PhosphorIconsRegular.lifebuoy,
    color: Color(0xFFF472B6),
  );
  static const ingilizce = PoliceModuleStyle(
    icon: PhosphorIconsRegular.translate,
    color: Color(0xFF67E8F9),
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
      child: PhosphorIcon(
        style.icon,
        color: style.color,
        size: size,
      ),
    );
  }
}
