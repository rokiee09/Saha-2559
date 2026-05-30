import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/gorevlerim/izin/il_mesafe.dart';
import 'package:coderipple/src/features/gorevlerim/izin/izin_provider.dart';

void main() {
  group('il mesafe ve yol izni', () {
    test('Şırnak → Aydın uzak mesafe (>600 km) → 4 gün yol izni', () {
      final km = ilMesafeKm('Şırnak', 'Aydın');
      expect(km, greaterThan(600));
      expect(yolIzniGunu(km), 4);
    });

    test('yakın iller (≤600 km) → 2 gün yol izni', () {
      final km = ilMesafeKm('Aydın', 'İzmir');
      expect(km, lessThanOrEqualTo(600));
      expect(km, greaterThan(0));
      expect(yolIzniGunu(km), 2);
    });

    test('aynı il → 0 km, yol izni yok', () {
      expect(ilMesafeKm('Ankara', 'Ankara'), 0);
      expect(yolIzniGunu(0), 0);
    });
  });

  group('yillikIzinHakki sınır', () {
    test('9 yıl → 20 gün', () => expect(yillikIzinHakki(9), 20));
    test('10 yıl → 30 gün (10. yıla giren 30 alır)',
        () => expect(yillikIzinHakki(10), 30));
    test('11 yıl → 30 gün', () => expect(yillikIzinHakki(11), 30));
    test('0 yıl → 20 gün', () => expect(yillikIzinHakki(0), 20));
  });

  group('LeaveRecord işe başlama tarihi', () {
    test('31.05.2026 + 10 gün izin + 4 gün yol → işe başlama 14.06.2026', () {
      final start = DateTime(2026, 5, 31);
      final r = LeaveRecord(
        id: '1',
        type: LeaveType.yillik,
        days: 10,
        roadDays: 4,
        startMs: start.millisecondsSinceEpoch,
        dateMs: start.millisecondsSinceEpoch,
        fromCity: 'Şırnak',
        toCity: 'Aydın',
      );
      expect(r.totalOffDays, 14);
      expect(r.returnDate, DateTime(2026, 6, 14));
      expect(r.lastOffDay, DateTime(2026, 6, 13));
    });
  });

  group('computeYillikDurum (devir + yol)', () {
    LeaveRecord rec(DateTime start, int days, int road) => LeaveRecord(
          id: start.toIso8601String(),
          type: LeaveType.yillik,
          days: days,
          roadDays: road,
          startMs: start.millisecondsSinceEpoch,
          dateMs: start.millisecondsSinceEpoch,
        );

    test('0-10 yıl: 20 hak + 5 devir; 10 gün kullanım → 15 kalan', () {
      final durum = computeYillikDurum(
        records: [rec(DateTime(2026, 5, 31), 10, 4)],
        serviceYears: 3,
        devirYillik: 5,
        devirYol: 2,
        year: 2026,
      );
      expect(durum.hakYillik, 20);
      expect(durum.toplamYillik, 25);
      expect(durum.kullanilanYillik, 10);
      expect(durum.kalanYillik, 15);
      // Yol: 4 hak + 2 devir = 6; 4 kullanıldı → 2 kalan.
      expect(durum.toplamYol, kYolIzniYillik + 2);
      expect(durum.kullanilanYol, 4);
      expect(durum.kalanYol, 2);
    });

    test('başka yıldaki kayıt bu yılın kullanımına sayılmaz', () {
      final durum = computeYillikDurum(
        records: [rec(DateTime(2025, 7, 1), 8, 2)],
        serviceYears: 12, // >10 → 30 gün
        devirYillik: 0,
        devirYol: 0,
        year: 2026,
      );
      expect(durum.hakYillik, 30);
      expect(durum.kullanilanYillik, 0);
      expect(durum.kalanYillik, 30);
    });
  });
}
