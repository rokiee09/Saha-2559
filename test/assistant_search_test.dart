import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/assistant_sensitive_query.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_decision_engine.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_knowledge_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_app_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_index.dart';
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

  group('LegalDecisionEngine app guide', () {
    late LegalDecisionEngine engine;

    setUp(() {
      engine = LegalDecisionEngine(
        index: [
          ...kPriorityLegalRecords.map(LegalKnowledgeRecord.fromIndexRecord),
          ...legalIndexFromHelpCorpus()
              .map(LegalKnowledgeRecord.fromIndexRecord),
        ],
      );
    });

    test('basari sorusu help corpus', () async {
      final answer = await engine.answer(
        'Başarı belgesi kaç tane olursa üstün başarı olur?',
      );
      expect(answer.noStrongMatch, isFalse);
      expect(answer.detectedTopics, contains('personel_haklari'));
    });

    test('atis kayit yardimi', () async {
      final answer = await engine.answer('Atış izni kullandım nasıl kaydederim?');
      expect(answer.noStrongMatch, isFalse);
      expect(
        answer.topHits.any((h) => h.record.moduleRoute == 'atis_takip'),
        isTrue,
      );
    });

    test('no match does not hallucinate', () async {
      final answer = await engine.answer('bugün hava nasıl');
      expect(answer.noStrongMatch || answer.outOfScope, isTrue);
    });

    test('sensitive query blocked without strong match', () async {
      final answer = await engine.answer('gizli yöntem ile takip');
      expect(
        answer.sensitiveBlocked ||
            AssistantSensitiveQuery.matches('gizli yöntem ile takip'),
        isTrue,
      );
    });
  });
}
