import 'package:flutter/material.dart';

/// Renk dili: koyu zemin ve mavi birincil vurgu (dashboard / mevzuat odaklı).
abstract final class PoliceColors {
  PoliceColors._();

  /// Derin arka plan
  static const Color backgroundDark = Color(0xFF0D0F14);

  /// Kart / yüzey
  static const Color surfaceDark = Color(0xFF1A1F2B);
  static const Color surfaceDarkElevated = Color(0xFF232A38);

  /// Birincil mavi (butonlar, aktif sekme)
  static const Color primaryBlue = Color(0xFF2D7EFF);

  /// Emeklilik / yaş haddi vurgusu (metin vurgusu)
  static const Color emeklilikAccent = Color(0xFF8B5CF6);

  /// Emeklilik pasta — zorunlu hizmet / ikon dilimleri
  static const Color emeklilikSliceNavy = Color(0xFF1E3A6E);
  static const Color emeklilikSliceRed = Color(0xFFE53935);

  /// Sağlık ve sosyal haklar vurgusu
  static const Color saglikAccent = Color(0xFFFB7185);

  /// Şehit yıldönümü / anma bandı
  static const Color sehitAccent = Color(0xFFF87171);

  /// Başlık (açık metin)
  static const Color titleOnDark = Color(0xFFFFFFFF);

  /// Gövde / açıklama gri
  static const Color textMuted = Color(0xFF9CA3AF);

  /// AppBar / derin başlık çubuğu
  static const Color navy = Color(0xFF12151C);

  /// Altın tonu: mevzuat numarası vb. sınırlı vurgu (klasik okuma ekranı)
  static const Color gold = Color(0xFFC9A34E);

  /// Mevzuat okuma ekranı
  static const Color mevzuatScreenBackground = backgroundDark;
  static const Color mevzuatBodyText = Color(0xFFF5F6F8);
  static const Color mevzuatTitleGrey = Color(0xFFE5E7EB);
  static const Color mevzuatMetaGrey = textMuted;
  static const Color mevzuatNumberGold = Color(0xFF6BA8FF);
  static const Color mevzuatListCard = surfaceDark;
  static const Color mevzuatListBorder = Color(0xFF2D3548);

  static const Color navBarBackground = Color(0xFF0A0C10);
  static const Color navInactive = Color(0xFF6B7280);
  static const Color navActive = primaryBlue;
  static const Color navTopDivider = Color(0xFF1F2937);

  static const Color surfaceLight = Color(0xFFEFF2F7);
  static const Color onSurfaceLight = Color(0xFF1A1D23);

  static const Color outlineMuted = Color(0xFF3D475C);
  static const Color onDarkMuted = textMuted;

  /// Arama / metin içi vurgu (sarı)
  static const Color searchHighlightBg = Color(0xFFEAB308);

  /// Detay okuma — ekstra koyu gece zemini
  static const Color readerNightBackground = Color(0xFF060708);
  static const Color readerNightSurface = Color(0xFF0E121A);

  /// `t`: 0=grı çizgi, 1=birincil mavi karışımı
  static Color accentMix(double t) =>
      Color.lerp(outlineMuted, primaryBlue, t.clamp(0.0, 1.0))!;
}
