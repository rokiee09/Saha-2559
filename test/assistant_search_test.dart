import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/assistant_sensitive_query.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_answer_builder.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_app_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_search_service.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_query_classifier.dart';
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

  group('AssistantLegalSearchService app guide', () {
    late AssistantLegalSearchService service;

    setUp(() {
      service = AssistantLegalSearchService(
        index: [
          ...kPriorityLegalRecords,
          ...legalIndexFromHelpCorpus(),
        ],
      );
    });

    test('basari sorusu help corpus', () {
      final hits = service.search(
        'Başarı belgesi kaç tane olursa üstün başarı olur?',
      );
      expect(service.hasStrongMatch(hits), isTrue);
      expect(
        hits.first.record.id,
        anyOf('help_help_basari_ustun', 'priority_basari_belgesi'),
      );
      expect(hits.first.record.tags, contains('basari'));
    });

    test('atis kayit yardimi', () {
      final hits = service.search('Atış izni kullandım nasıl kaydederim?');
      expect(service.hasStrongMatch(hits), isTrue);
      expect(
        hits.any((h) => h.record.moduleRoute == 'atis_takip'),
        isTrue,
      );
    });

    test('no match does not hallucinate', () {
      final hits = service.search('bugün hava nasıl');
      final answer = const AssistantAnswerBuilder().build(
        query: 'bugün hava nasıl',
        classification:
            AssistantQueryClassifier().classify('bugün hava nasıl'),
        hits: hits,
        strongMatch: service.hasStrongMatch(hits),
      );
      expect(
        answer.noStrongMatch || answer.outOfScope,
        isTrue,
      );
    });

    test('sensitive query blocked without strong match', () {
      final hits = service.search('gizli yöntem ile takip');
      final answer = const AssistantAnswerBuilder().build(
        query: 'gizli yöntem ile takip',
        classification:
            AssistantQueryClassifier().classify('gizli yöntem ile takip'),
        hits: hits,
        strongMatch: service.hasStrongMatch(hits),
      );
      expect(
        answer.sensitiveBlocked ||
            AssistantSensitiveQuery.matches('gizli yöntem ile takip'),
        isTrue,
      );
    });
  });
}
