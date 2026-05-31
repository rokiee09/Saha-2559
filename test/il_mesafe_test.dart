import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/gorevlerim/izin/il_mesafe.dart';

void main() {
  group('ilMesafeKm kalibrasyon', () {
    int yuzdeSapma(int hesap, int referans) =>
        ((hesap - referans).abs() * 100 / referans).round();

    test('Ankara–İstanbul ~452 km (%8 marj içinde)', () {
      final km = ilMesafeKm('Ankara', 'İstanbul');
      expect(yuzdeSapma(km, 452), lessThanOrEqualTo(8));
    });

    test('Ankara–İzmir ~580 km (%8 marj içinde)', () {
      final km = ilMesafeKm('Ankara', 'İzmir');
      expect(yuzdeSapma(km, 580), lessThanOrEqualTo(8));
    });

    test('Denizli–Diyarbakır ~1243 km (%5 marj içinde)', () {
      final km = ilMesafeKm('Denizli', 'Diyarbakır');
      expect(yuzdeSapma(km, 1243), lessThanOrEqualTo(5));
    });

    test('Ankara–Antalya cetvel değeri', () {
      expect(ilMesafeKm('Ankara', 'Antalya'), 482);
    });

    test('İstanbul–İzmir cetvel değeri', () {
      expect(ilMesafeKm('İstanbul', 'İzmir'), 480);
    });

    test('aynı il → 0 km', () {
      expect(ilMesafeKm('Ankara', 'Ankara'), 0);
    });
  });
}
