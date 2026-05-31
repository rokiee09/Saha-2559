import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/haklar/vardiya/vardiya_cycle_calculator.dart';

void main() {
  group('vardiyaCyclePatternFor', () {
    test('bilinen 12_24 kalıbı gündüz + gece + dinlenme döner', () {
      expect(
        vardiyaCyclePatternFor('12_24'),
        const [
          VardiyaCalendarDayKind.cakmaDayDuty,
          VardiyaCalendarDayKind.cakmaNightDuty,
          VardiyaCalendarDayKind.rest,
        ],
      );
    });

    test('cakma_12_36 için boş liste döner (özel yol kullanılır)', () {
      expect(vardiyaCyclePatternFor('cakma_12_36'), isEmpty);
    });

    test('bilinmeyen id için varsayılan kalıba düşer', () {
      expect(vardiyaCyclePatternFor('boyle_bir_sey_yok'), isNotEmpty);
    });
  });

  group('vardiyaPatternShortLabel', () {
    test('11 kalıbı "İş → Din" üretir', () {
      expect(vardiyaPatternShortLabel('11'), 'İş → Din');
    });

    test('cakma için açıklayıcı blok etiketi döner', () {
      final label = vardiyaPatternShortLabel('cakma_12_36');
      expect(label, contains(kCakmaFirstRotationDescription));
    });
  });

  group('buildVardiyaIllustrativeDays', () {
    test('basit kalıpta gün sayısı ve sıra korunur', () {
      final anchor = DateTime(2026, 1, 1);
      final days = buildVardiyaIllustrativeDays(
        anchorLocalDate: anchor,
        shiftId: '11',
        dayCount: 4,
      );

      expect(days, hasLength(4));
      expect(days.first.kind, VardiyaCalendarDayKind.work);
      expect(days[1].kind, VardiyaCalendarDayKind.rest);
      expect(days[2].kind, VardiyaCalendarDayKind.work);
      expect(days[3].kind, VardiyaCalendarDayKind.rest);
      // Tarihler ardışık gün gün artar.
      expect(days[1].date.difference(days[0].date).inDays, 1);
    });

    test('cakma 12/36 gün sayısı kadar slot ve ilk gün gündüz nöbeti', () {
      final anchor = DateTime(2026, 3, 10);
      final days = buildVardiyaIllustrativeDays(
        anchorLocalDate: anchor,
        shiftId: 'cakma_12_36',
        dayCount: 21,
      );

      expect(days, hasLength(21));
      expect(days.first.kind, VardiyaCalendarDayKind.cakmaDayDuty);
      // Döngü içinde hem nöbet hem dinlenme günleri olmalı.
      final kinds = days.map((d) => d.kind).toSet();
      expect(kinds.contains(VardiyaCalendarDayKind.cakmaNightDuty), isTrue);
    });
  });

  group('buildVardiyaMonthSchedule', () {
    test('referans öncesi günler boş (null) gelir', () {
      final result = buildVardiyaMonthSchedule(
        year: 2026,
        month: 1,
        anchorLocalDate: DateTime(2026, 1, 10),
        shiftId: '11',
      );

      expect(result.cells, hasLength(31));
      // Ayın ilk günleri referanstan önce → kind null.
      expect(result.cells.first.kind, isNull);
      expect(result.cells[8].kind, isNull); // 9 Ocak
      expect(result.cells[9].kind, isNotNull); // 10 Ocak referans
    });

    test('11 kalıbında çalışma/dinlenme sayıları toplanır', () {
      final result = buildVardiyaMonthSchedule(
        year: 2026,
        month: 1,
        anchorLocalDate: DateTime(2026, 1, 1),
        shiftId: '11',
      );

      // Ocak 31 gün; iş/din dönüşümlü başlar → 16 iş, 15 dinlenme.
      expect(result.tallies.gun, 16);
      expect(result.tallies.off, 15);
      expect(result.tallies.gece, 0);
    });

    test('artık yıl Şubat ayı 29 gün döner', () {
      final result = buildVardiyaMonthSchedule(
        year: 2024, // artık yıl
        month: 2,
        anchorLocalDate: DateTime(2024, 1, 1),
        shiftId: '11',
      );
      expect(result.cells, hasLength(29));
    });

    test('Aralık (ay/yıl sonu) doğru gün sayısı ve kalıp sürekliliği', () {
      // 11 kalıbı: ofset (gün - referans) çift ise iş, tek ise dinlenme.
      final result = buildVardiyaMonthSchedule(
        year: 2026,
        month: 12,
        anchorLocalDate: DateTime(2026, 1, 1),
        shiftId: '11',
      );
      expect(result.cells, hasLength(31));

      // 1 Ocak referans (iş). 31 Aralık'a kadar geçen gün farkı 364 (çift) → iş.
      final dec31 = result.cells.last;
      expect(dec31.date, DateTime(2026, 12, 31));
      expect(dec31.kind, VardiyaCalendarDayKind.work);
    });

    test('yıl sonunu aşan illüstratif gün üretimi tutarlı uzunlukta', () {
      final days = buildVardiyaIllustrativeDays(
        anchorLocalDate: DateTime(2026, 12, 28),
        shiftId: 'cakma_12_36',
        dayCount: 14, // yıl sınırını aşar (2027'ye taşar)
      );
      expect(days, hasLength(14));
      expect(days.last.date, DateTime(2027, 1, 10));
    });
  });

  group('gerçek 12/36 (gece başlangıç) — kullanıcı örneği', () {
    final anchor = DateTime(2026, 5, 30); // bugün gece çalışıyorum

    test('bugün gece nöbeti, yarın istirahat (gün aşırı)', () {
      final days = buildVardiyaIllustrativeDays(
        anchorLocalDate: anchor,
        shiftId: 'gercek_12_36',
        startNight: true,
        dayCount: 6,
      );
      expect(days[0].kind, VardiyaCalendarDayKind.cakmaNightDuty); // 30.05 gece
      expect(days[1].kind, VardiyaCalendarDayKind.rest); // 31.05 istirahat
      expect(days[2].kind, VardiyaCalendarDayKind.cakmaNightDuty); // 01.06 gece
      expect(days[3].kind, VardiyaCalendarDayKind.rest);
    });

    test('ilk somut nöbet 20:00 başlar ertesi gün 08:00 biter', () {
      final shifts = buildVardiyaUpcomingShifts(
        anchorLocalDate: anchor,
        shiftId: 'gercek_12_36',
        startNight: true,
        from: anchor,
        count: 2,
      );
      expect(shifts, hasLength(2));
      expect(shifts.first.night, isTrue);
      expect(shifts.first.start, DateTime(2026, 5, 30, 20));
      expect(shifts.first.end, DateTime(2026, 5, 31, 8));
      // Sonraki gece nöbeti 48 saat sonra (gün aşırı).
      expect(shifts[1].start, DateTime(2026, 6, 1, 20));
    });

    test('gündüz başlayınca ilk nöbet 08:00–20:00', () {
      final shifts = buildVardiyaUpcomingShifts(
        anchorLocalDate: anchor,
        shiftId: 'gercek_12_36',
        startNight: false,
        from: anchor,
        count: 1,
      );
      expect(shifts.first.night, isFalse);
      expect(shifts.first.start, DateTime(2026, 5, 30, 8));
      expect(shifts.first.end, DateTime(2026, 5, 30, 20));
    });
  });

  group('çakma 12/36 — 5 gündüz (12/12) + 10 gece (12/36)', () {
    final anchor = DateTime(2026, 5, 30);

    test('ilk 5 gün gündüz peş peşe, sonra gece bloğu başlar', () {
      final days = buildVardiyaIllustrativeDays(
        anchorLocalDate: anchor,
        shiftId: 'cakma_12_36',
        startNight: false,
        dayCount: 8,
      );
      for (var i = 0; i < 5; i++) {
        expect(days[i].kind, VardiyaCalendarDayKind.cakmaDayDuty);
      }
      // 6. günden itibaren gece bloğu (gün aşırı gece nöbeti) görülür.
      final laterKinds = days.sublist(5).map((d) => d.kind).toSet();
      expect(laterKinds.contains(VardiyaCalendarDayKind.cakmaNightDuty), isTrue);
    });

    test('gündüz nöbetleri günlük 08:00–20:00', () {
      final shifts = buildVardiyaUpcomingShifts(
        anchorLocalDate: anchor,
        shiftId: 'cakma_12_36',
        startNight: false,
        from: anchor,
        count: 5,
      );
      expect(shifts, hasLength(5));
      expect(shifts.every((s) => !s.night), isTrue);
      expect(shifts[0].start, DateTime(2026, 5, 30, 8));
      expect(shifts[1].start, DateTime(2026, 5, 31, 8));
      expect(shifts[4].start, DateTime(2026, 6, 3, 8));
    });
  });
}
