// EGM görev (hizmet) puanı hesabı — Mart 2025 yönetmeliği.
//
// Resmî formül: Görev Puanı = Günlük Görev Yeri Puanı × çalışılan gün sayısı
// (İçişleri Bakanlığı / EGM duyuruları; blog basitleştirmesi yıl×katsayı değildir.)
//
// Günlük görev yeri puanı; SEGE, il tercih edilme, iş yükü ve ek puan (İstanbul /
// şark) kriterlerinin toplamından oluşur — 2025 cetveli bu değerleri içerir.

/// Başlangıç ve bitiş dahil çalışılan gün sayısı.
int gorevPuaniGunSayisi(DateTime baslangic, DateTime bitis) {
  final bas = DateTime(baslangic.year, baslangic.month, baslangic.day);
  final bit = DateTime(bitis.year, bitis.month, bitis.day);
  if (bit.isBefore(bas)) return 0;
  return bit.difference(bas).inDays + 1;
}

/// Tek dönem görev puanı.
double gorevPuaniToplam(double gunlukGorevYeriPuani, int gunSayisi) {
  if (gunSayisi <= 0 || gunlukGorevYeriPuani <= 0) return 0;
  return gunlukGorevYeriPuani * gunSayisi;
}

/// Kayıtlı tüm görev dönemlerinin güncel toplamı.
double gorevPuaniGenelToplam(
  Iterable<double> donemPuanlari,
) =>
    donemPuanlari.fold(0.0, (a, b) => a + b);

/// Yaklaşık görev süresi (yıl) — bilgilendirme amaçlı.
double gorevPuaniYilKarsiligi(int gunSayisi) {
  if (gunSayisi <= 0) return 0;
  return gunSayisi / 365;
}

/// Gün sayısını okunaklı süre metnine çevirir.
String gorevPuaniSureMetni(int gunSayisi) {
  if (gunSayisi <= 0) return '';
  final yil = gunSayisi / 365;
  if (gunSayisi < 365) return '$gunSayisi gün';
  if (gunSayisi % 365 == 0) {
    final tamYil = gunSayisi ~/ 365;
    return '$gunSayisi gün (yaklaşık $tamYil yıl)';
  }
  return '$gunSayisi gün (yaklaşık ${yil.toStringAsFixed(1)} yıl)';
}
