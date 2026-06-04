import 'package:flutter/material.dart';

import '../widgets/police_module_icon.dart';

/// Ana uygulama alanları — mağaza ve navigasyon için tutarlı renk/ikon.
enum SahaModuleArea {
  mevzuat,
  asistan,
  gorevlerim,
  araclar,
  vardiya,
  vault,
  martyrs,
  kultur,
}

extension SahaModuleAreaX on SahaModuleArea {
  String get label => switch (this) {
        SahaModuleArea.mevzuat => 'Mevzuat',
        SahaModuleArea.asistan => 'Mevzuat Asistanı',
        SahaModuleArea.gorevlerim => 'Profilim',
        SahaModuleArea.araclar => 'Araçlar',
        SahaModuleArea.vardiya => 'Vardiya',
        SahaModuleArea.vault => 'Güvenli kasa',
        SahaModuleArea.martyrs => 'Şehitler',
        SahaModuleArea.kultur => 'Kültür',
      };

  PoliceModuleStyle get style => switch (this) {
        SahaModuleArea.mevzuat => PoliceModules.mevzuat,
        SahaModuleArea.asistan => PoliceModules.asistan,
        SahaModuleArea.gorevlerim => PoliceModules.profilim,
        SahaModuleArea.araclar => PoliceModules.araclar,
        SahaModuleArea.vardiya => PoliceModules.vardiya,
        SahaModuleArea.vault => PoliceModules.sifreKasa,
        SahaModuleArea.martyrs => PoliceModules.sehitler,
        SahaModuleArea.kultur => PoliceModules.kultur,
      };
}

/// Modül kartı görsel teması (kenarlık ve rozet rengi).
class SahaModuleTheme {
  const SahaModuleTheme({
    required this.style,
    this.accentLabel,
  });

  final PoliceModuleStyle style;
  final String? accentLabel;

  Color get accentColor => style.color;

  Color get borderColor => style.color.withValues(alpha: 0.32);

  Color get surfaceTint => style.color.withValues(alpha: 0.08);

  factory SahaModuleTheme.fromStyle(PoliceModuleStyle style, {String? label}) {
    return SahaModuleTheme(style: style, accentLabel: label);
  }

  factory SahaModuleTheme.forArea(SahaModuleArea area) {
    return SahaModuleTheme(style: area.style, accentLabel: area.label);
  }

  factory SahaModuleTheme.forSahaCategory(String categoryId) {
    return SahaModuleTheme.fromStyle(
      PoliceModules.forSahaCategory(categoryId),
    );
  }
}
