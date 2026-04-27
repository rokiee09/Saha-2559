import 'package:flutter/material.dart';

/// Ciddi, sade hukuk uygulaması: koyu lacivert, çok sınırlı altın, kırmızı yok denecek kadar az.
abstract final class PoliceColors {
  PoliceColors._();

  /// Ana kurumsal lacivert
  static const Color navy = Color(0xFF0A1F44);

  /// Neredeyse siyah, göz yormayan koyu mavi-gri
  static const Color backgroundDark = Color(0xFF0E1320);

  static const Color surfaceDark = Color(0xFF151B2A);
  static const Color surfaceDarkElevated = Color(0xFF1B2235);

  /// Vurgu: çok sınırlı kullanım (~%5; aktif çizgi, madde no, tek ikon)
  static const Color gold = Color(0xFFC9A34E);

  /// Mevzuat okuma ekranı (sade, koyu)
  static const Color mevzuatScreenBackground = backgroundDark;
  static const Color mevzuatBodyText = Color(0xFFF5F6F8);
  static const Color mevzuatTitleGrey = Color(0xFFBBC5D3);
  static const Color mevzuatMetaGrey = Color(0xFF8B95A5);
  /// Madde / numara: hafif altın
  static const Color mevzuatNumberGold = Color(0xFFD1B45C);
  static const Color mevzuatListCard = Color(0xFF151B2A);
  static const Color mevzuatListBorder = Color(0xFF2A3347);

  /// Alt sekmeler: pasif gri; aktif lacivert tonu (koyu zeminde okunur)
  static const Color navBarBackground = Color(0xFF0A0E18);
  static const Color navInactive = Color(0xFF6B7485);
  static const Color navActive = Color(0xFF8EA4CC);
  static const Color navTopDivider = Color(0xFF1E2638);

  /// Açık mod (daha az baskın; tercih koyu temada)
  static const Color surfaceLight = Color(0xFFEFF2F7);
  static const Color onSurfaceLight = Color(0xFF1A1D23);

  static const Color outlineMuted = Color(0xFF3D475C);
  static const Color onDarkMuted = Color(0xFFB8C0D0);
}
