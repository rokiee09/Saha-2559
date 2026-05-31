import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/gorev_puanlari/gorev_puani_calculator.dart';
import 'package:coderipple/src/features/araclar/gorev_puanlari/gorev_puanlari_data.dart';

void main() {
  group('gorevPuaniGunSayisi', () {
    test('same day = 1', () {
      final d = DateTime(2025, 3, 1);
      expect(gorevPuaniGunSayisi(d, d), 1);
    });

    test('inclusive range', () {
      final bas = DateTime(2025, 1, 1);
      final bit = DateTime(2025, 1, 10);
      expect(gorevPuaniGunSayisi(bas, bit), 10);
    });

    test('bitis before bas = 0', () {
      expect(
        gorevPuaniGunSayisi(
          DateTime(2025, 5, 10),
          DateTime(2025, 5, 1),
        ),
        0,
      );
    });
  });

  group('gorevPuaniToplam', () {
    test('Ankara Çankaya 365 gün', () {
      final toplam = gorevPuaniToplam(1.52, 365);
      expect(formatGorevPuani(toplam), '554.800');
    });

    test('10 gün Denizli merkez', () {
      final toplam = gorevPuaniToplam(1.328, 10);
      expect(formatGorevPuani(toplam), '13.280');
    });

    test('100 puan × 365 gün = 36.500 (yönetmelik örneği)', () {
      final toplam = gorevPuaniToplam(0.1, 365);
      expect(formatGorevPuani(toplam), '36.500');
    });
  });

  group('gorevPuaniGenelToplam', () {
    test('sums multiple periods', () {
      final t = gorevPuaniGenelToplam([13.28, 554.8]);
      expect(formatGorevPuani(t), '568.080');
    });
  });

  group('gorevPuaniSureMetni', () {
    test('shows year for 365 days', () {
      expect(gorevPuaniSureMetni(365), '365 gün (yaklaşık 1 yıl)');
    });
  });
}
