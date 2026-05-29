import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/haklar/vardiya/vardiya_cycle_calculator.dart';

void main() {
  group('vardiyaCyclePatternFor', () {
    test('bilinen 12_24 kalıbı iş + 2 dinlenme döner', () {
      expect(
        vardiyaCyclePatternFor('12_24'),
        const [
          VardiyaCalendarDayKind.work,
          VardiyaCalendarDayKind.rest,
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
  });
}
