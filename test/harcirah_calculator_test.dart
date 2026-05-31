import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/harcirah/harcirah_calculator.dart';

void main() {
  group('harcirahGunSayisi', () {
    test('1280 km → 21 gün', () {
      expect(harcirahGunSayisi(1280), 21);
    });

    test('0 km → 0 gün', () {
      expect(harcirahGunSayisi(0), 0);
    });
  });

  group('harcirahCocukGunSayisi', () {
    test('21 gün → 11 çocuk günü', () {
      expect(harcirahCocukGunSayisi(21), 11);
    });
  });

  group('hesaplaHarcirah — örnek rapor', () {
    test('Denizli–Diyarbakır örnek rapor tutarlı', () {
      final g = ornekHarcirahGirdi;
      final sonuc = hesaplaHarcirah(g);
      expect(sonuc.mesafeKm, greaterThan(1200));
      expect(sonuc.gunSayisi, (g.mesafeKm / 60).round());
      expect(sonuc.cocukGunSayisi, (sonuc.gunSayisi / 2).round());

      // Katsayı doğrulama: mesafe satırı = ücret × 0,05 × km
      final kendiMesafe = sonuc.satirlar.firstWhere(
        (s) => s.aciklama.contains('Kendisi') && s.aciklama.contains('Mesafe'),
      );
      expect(kendiMesafe.sonuc, closeTo(850 * 0.05 * g.mesafeKm, 0.5));

      // Toplam = satır toplamı
      final satirToplam =
          sonuc.satirlar.fold<double>(0, (a, s) => a + s.sonuc);
      expect(sonuc.toplam, closeTo(satirToplam, 0.01));
    });

    test('bekar — yalnızca kendisi satırları', () {
      final sonuc = hesaplaHarcirah(
        const HarcirahGirdi(
          nereden: 'Ankara',
          nereye: 'İzmir',
          mesafeKm: 600,
          bekar: true,
          esDurumu: HarcirahEsDurumu.calismiyor,
          cocukSayisi: 0,
          gunlukUcret: 850,
          otobusUcreti: 1000,
        ),
      );
      expect(sonuc.satirlar.every((s) => !s.aciklama.startsWith('Eşi')), isTrue);
      expect(sonuc.satirlar.any((s) => s.aciklama.contains('Kendisi')), isTrue);
    });

    test('eş memur mesafe katsayısı yarı', () {
      final g = ornekHarcirahGirdi;
      final sonuc = hesaplaHarcirah(g);
      final esMesafe = sonuc.satirlar.firstWhere(
        (s) => s.aciklama.contains('Mesafe Harcırah') && s.aciklama.contains('Memur'),
      );
      expect(esMesafe.katSayisi, kHarcirahEsMemurMesafeKatsayi);
      expect(esMesafe.sonuc, closeTo(850 * 0.025 * g.mesafeKm, 0.5));
    });
  });
}
