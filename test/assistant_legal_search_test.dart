import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/assistant_sensitive_query.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_answer_builder.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_search_service.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_query_classifier.dart';

void main() {
  late AssistantLegalSearchService service;

  setUp(() {
    service = AssistantLegalSearchService(
      index: kPriorityLegalRecords,
    );
  });

  group('AssistantQueryClassifier', () {
    test('classifies refakat izni', () {
      final c = AssistantQueryClassifier().classify('Refakat iznim kaç gün?');
      expect(c.isInLegalScope, isTrue);
      expect(c.primary, LegalQueryCategory.izinler);
    });

    test('out of scope small talk', () {
      final c = AssistantQueryClassifier().classify('bugün hava nasıl');
      expect(c.isInLegalScope, isFalse);
    });
  });

  group('AssistantLegalSearchService', () {
    test('refakat izni strong match', () {
      final hits = service.search('Refakat iznim kaç gün?');
      expect(hits, isNotEmpty);
      expect(service.hasStrongMatch(hits), isTrue);
      expect(hits.first.record.title.toLowerCase(), contains('refakat'));
    });

    test('gec kalma disiplin', () {
      final hits = service.search('İşe geç kaldım cezası nedir?');
      expect(service.hasStrongMatch(hits), isTrue);
      expect(
        hits.first.record.tags,
        anyElement(equals('disiplin')),
      );
    });

    test('zor kullanma pvsk', () {
      final hits = service.search('Zor kullanma hangi maddede?');
      expect(service.hasStrongMatch(hits), isTrue);
      expect(hits.first.record.sectionId, 'pvsk-16');
    });

    test('blocks sensitive operational query', () {
      final answer = const AssistantAnswerBuilder().build(
        query: 'baskin operasyonel taktik nasil',
        classification: AssistantQueryClassifier()
            .classify('baskin operasyonel taktik nasil'),
        hits: const [],
        strongMatch: false,
      );
      expect(answer.sensitiveBlocked, isTrue);
      expect(AssistantSensitiveQuery.matches('baskin taktik'), isTrue);
    });

    test('no hallucination on unrelated', () {
      final hits = service.search('en iyi pizza tarifi');
      final answer = const AssistantAnswerBuilder().build(
        query: 'en iyi pizza tarifi',
        classification:
            AssistantQueryClassifier().classify('en iyi pizza tarifi'),
        hits: hits,
        strongMatch: service.hasStrongMatch(hits),
      );
      expect(
        answer.noStrongMatch || answer.outOfScope,
        isTrue,
      );
    });
  });
}
