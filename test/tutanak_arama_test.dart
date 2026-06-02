import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/arama/arama_rehberi_data.dart';
import 'package:coderipple/src/features/araclar/tutanak/tutanak_checker.dart';

void main() {
  group('TutanakChecker', () {
    test('flags missing date time place', () {
      final issues = TutanakChecker.check(
        values: {'tarih': '', 'saat': '', 'yer': ''},
        draft: '.....',
      );
      expect(
        issues.any((i) => i.message.contains('Tarih')),
        isTrue,
      );
      expect(
        issues.any((i) => i.message.contains('Saat')),
        isTrue,
      );
      expect(
        issues.any((i) => i.message.contains('Yer')),
        isTrue,
      );
    });
  });

  group('aramaSenaryoEslestir', () {
    test('matches uyuşturucu in vehicle', () {
      final hits = aramaSenaryoEslestir('Araçta uyuşturucu şüphesi var');
      expect(hits, isNotEmpty);
      expect(hits.first.id, 'arac_uyusturucu');
    });
  });
}
