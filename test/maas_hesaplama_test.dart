import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/haklar/maas_katsayi_data.dart';

void main() {
  group('MaasDonemData.fromJson', () {
    test('alanları okur, eksiklerde varsayılana düşer', () {
      final d = MaasDonemData.fromJson({
        'id': '2024_2',
        'etiket': '2024 Temmuz',
        'memurAylikKatsayisi': 0.76,
        'tabanAylik': 5000,
      });

      expect(d.id, '2024_2');
      expect(d.etiket, '2024 Temmuz');
      expect(d.memurAylikKatsayisi, 0.76);
      expect(d.tabanAylik, 5000);
      // tahminiNetOrani verilmezse 0.7 varsayılır.
      expect(d.tahminiNetOrani, 0.7);
      expect(d.kaynakNot, isNull);
    });
  });

  group('MaasKatsayiFile.fromJson / donemById', () {
    test('dönem listesini ayrıştırır ve id ile bulur', () {
      final file = MaasKatsayiFile.fromJson({
        'sonGuncelleme': '2024-07',
        'genelUyari': 'Tahmini değerdir.',
        'formulAciklama': 'gosterge * katsayi + ...',
        'varsayilanDonem': '2024_2',
        'donemler': [
          {'id': '2024_1', 'etiket': 'Ocak', 'memurAylikKatsayisi': 0.7, 'tabanAylik': 4000},
          {'id': '2024_2', 'etiket': 'Temmuz', 'memurAylikKatsayisi': 0.76, 'tabanAylik': 5000},
        ],
      });

      expect(file.donemler, hasLength(2));
      expect(file.varsayilanDonem, '2024_2');
      expect(file.donemById('2024_2')?.etiket, 'Temmuz');
      expect(file.donemById('yok'), isNull);
    });
  });

  group('hesaplaMaas', () {
    test('gösterge aylığı, brüt ve tahmini net doğru hesaplanır', () {
      final donem = MaasDonemData(
        id: 't',
        etiket: 'test',
        memurAylikKatsayisi: 0.5,
        tabanAylik: 1000,
        tahminiNetOrani: 0.7,
      );

      final r = hesaplaMaas(
        donem: donem,
        gostergePuan: 2000,
        ekGostergeTl: 500,
      );

      expect(r.gostergeAyligi, 1000); // 2000 * 0.5
      expect(r.brut, 2500); // 1000 + 1000 + 500
      expect(r.tahminiNet, closeTo(1750, 1e-9)); // 2500 * 0.7
      expect(r.tahminiKesinti, closeTo(750, 1e-9));
    });

    test('boş/eksik JSON varsayılanlarla patlamaz', () {
      final donem = MaasDonemData.fromJson(const {});
      expect(donem.memurAylikKatsayisi, 0);
      expect(donem.tabanAylik, 0);

      // Sıfır katsayı ve sıfır taban → tüm sonuçlar 0, hata yok.
      final r = hesaplaMaas(
        donem: donem,
        gostergePuan: 0,
        ekGostergeTl: 0,
      );
      expect(r.brut, 0);
      expect(r.tahminiNet, 0);
      expect(r.tahminiKesinti, 0);
    });

    test('negatif girişlerde exception fırlatmaz', () {
      final donem = MaasDonemData(
        id: 't',
        etiket: 'test',
        memurAylikKatsayisi: 0.5,
        tabanAylik: -100,
        tahminiNetOrani: 0.7,
      );

      expect(
        () => hesaplaMaas(
          donem: donem,
          gostergePuan: -50,
          ekGostergeTl: -10,
          kidemAyligi: -5,
        ),
        returnsNormally,
      );

      final r = hesaplaMaas(
        donem: donem,
        gostergePuan: -50,
        ekGostergeTl: -10,
      );
      expect(r.brut.isFinite, isTrue);
      expect(r.tahminiNet.isFinite, isTrue);
      expect(r.tahminiKesinti.isFinite, isTrue);
    });

    test('boş katsayı dosyası güvenli ayrıştırılır', () {
      final file = MaasKatsayiFile.fromJson(const {});
      expect(file.donemler, isEmpty);
      expect(file.donemById('herhangi'), isNull);
      expect(file.varsayilanDonem, '');
    });

    test('tüm tazminat/yardım kalemleri brüte eklenir', () {
      final donem = MaasDonemData(
        id: 't',
        etiket: 'test',
        memurAylikKatsayisi: 1,
        tabanAylik: 0,
        tahminiNetOrani: 1,
      );

      final r = hesaplaMaas(
        donem: donem,
        gostergePuan: 100,
        ekGostergeTl: 10,
        kidemAyligi: 1,
        ozelHizmetTazminati: 2,
        dilTazminati: 3,
        ekOdeme: 4,
        aileYardimi: 5,
        cocukYardimi: 6,
      );

      // 100*1 + 10 + 1+2+3+4+5+6 = 131
      expect(r.brut, 131);
      expect(r.tahminiNet, 131); // oran 1 → kesinti yok
      expect(r.tahminiKesinti, 0);
    });
  });
}
