import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/search/assistant_search_service.dart';
import 'package:coderipple/src/features/asistan/search/query_normalizer.dart';

void main() {
  group('QueryNormalizer', () {
    test('expands synonyms', () {
      final nq = QueryNormalizer.normalize('kimlik vermeyen');
      expect(nq.expandedTokens, contains('huviyet'));
    });

    test('detects law refs', () {
      final nq = QueryNormalizer.normalize('PVSK zor kullanma maddesi');
      expect(nq.lawRefs, contains('pvsk'));
    });
  });

  group('AssistantSearchService', () {
    late AssistantSearchService service;

    setUp(() {
      service = const AssistantSearchService(
        scenarios: [],
        mevzuatIndex: [],
        cezaKayitlar: [],
      );
    });

    test('basari sorusu help corpus', () {
      final answer = service.search(
        'Başarı belgesi kaç tane olursa üstün başarı olur?',
      );
      expect(answer.noStrongMatch, isFalse);
      expect(answer.primary?.category.name, 'basari');
    });

    test('atis kayit yardimi', () {
      final answer = service.search('Atış izni kullandım nasıl kaydederim?');
      expect(answer.noStrongMatch, isFalse);
      expect(answer.primary?.category.name, 'atis');
    });

    test('no match does not hallucinate', () {
      final answer = service.search('bugün hava nasıl');
      expect(answer.noStrongMatch || answer.primary == null, isTrue);
    });

    test('sensitive query blocked without strong match', () {
      final answer = service.search('gizli yöntem ile takip');
      expect(answer.sensitiveBlocked, isTrue);
    });
  });
}
