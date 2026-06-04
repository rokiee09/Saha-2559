/// EGM görev puanı cetveli kesit ve yıl seçimi (31.12.2025 / 01.01.2026).
final gorevPuanCetvelKesit = DateTime(2026, 1, 1);

/// Görev dönemi için hangi yıl cetveli esas alınır.
int gorevPuanCetvelYili(DateTime baslangic, DateTime bitis) {
  if (bitis.isBefore(gorevPuanCetvelKesit)) return 2025;
  if (!baslangic.isBefore(gorevPuanCetvelKesit)) return 2026;
  // Kesit geçen dönemlerde başlama tarihi esas (şark/ilçe seçimi ile uyumlu).
  return baslangic.isBefore(gorevPuanCetvelKesit) ? 2025 : 2026;
}

/// Şark hizmeti başladıktan sonraki görev dönemleri için cetvel yılı.
/// [sarkBaslangic] yoksa yalnızca kesit tarihine göre karar verilir.
int gorevPuanCetvelYiliSarkIle({
  required DateTime baslangic,
  required DateTime bitis,
  DateTime? sarkBaslangic,
}) {
  if (sarkBaslangic != null &&
      !bitis.isBefore(sarkBaslangic) &&
      !baslangic.isBefore(sarkBaslangic)) {
    // Şark dönemindeki görevler 2026 kesitinden sonra 2026 cetveli kullanılır.
    if (!baslangic.isBefore(gorevPuanCetvelKesit)) return 2026;
    if (bitis.isBefore(gorevPuanCetvelKesit)) return 2025;
    return gorevPuanCetvelYili(baslangic, bitis);
  }
  return gorevPuanCetvelYili(baslangic, bitis);
}

bool gorevDonemiSarkKapsaminda({
  required DateTime baslangic,
  required DateTime bitis,
  required DateTime sarkBaslangic,
}) {
  return !bitis.isBefore(sarkBaslangic) && !baslangic.isBefore(sarkBaslangic);
}

String gorevPuanCetvelYilAciklama(int yil) {
  if (yil == 2025) {
    return '31.12.2025\'e kadar olan çalışmalar bu cetvelden hesaplanır.';
  }
  return '01.01.2026\'dan sonraki çalışmalar bu cetvelden hesaplanır.';
}
