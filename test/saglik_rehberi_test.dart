import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/saglik/saglik_rehberi_data.dart';

void main() {
  group('saglikSenaryoEslestir', () {
    test('matches bel fıtığı ameliyatı', () {
      final hits = saglikSenaryoEslestir('Bel fıtığı ameliyatı oldum');
      expect(hits, isNotEmpty);
      expect(hits.first.id, 'bel_fitigi');
    });

    test('matches heyet sevk', () {
      final hits = saglikSenaryoEslestir('Heyete sevk süreci nasıl');
      expect(hits.any((h) => h.id == 'heyet_sevk'), isTrue);
    });

    test('returns empty for short query', () {
      expect(saglikSenaryoEslestir('ab'), isEmpty);
    });
  });

  group('rehberIcerik', () {
    test('all topics have steps', () {
      for (final k in SaglikRehberKonu.values) {
        final i = rehberIcerik(k);
        expect(i.adimlar, isNotEmpty);
        expect(i.ozet, contains('İlgili mevzuata göre'));
      }
    });
  });
}
