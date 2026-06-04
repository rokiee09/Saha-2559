import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/assistant_sensitive_query.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_decision_engine.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_knowledge_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_query_classifier.dart';

void main() {
  late LegalDecisionEngine engine;

  setUp(() {
    engine = LegalDecisionEngine(
      index: kPriorityLegalRecords
          .map(LegalKnowledgeRecord.fromIndexRecord)
          .toList(),
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

  group('LegalDecisionEngine priority records', () {
    test('refakat izni strong match', () async {
      final answer = await engine.answer('Refakat iznim kaç gün?');
      expect(answer.noStrongMatch, isFalse);
      expect(answer.shortAnswer.toLowerCase(), contains('refakat'));
    });

    test('gec kalma disiplin', () async {
      final answer = await engine.answer('İşe geç kaldım cezası nedir?');
      expect(answer.noStrongMatch, isFalse);
      expect(
        answer.primaryRecord!.tags,
        anyElement(equals('disiplin')),
      );
    });

    test('zor kullanma pvsk', () async {
      final answer = await engine.answer('Zor kullanma hangi maddede?');
      expect(answer.noStrongMatch, isFalse);
      expect(answer.primaryRecord!.sectionId, 'pvsk-16');
    });

    test('blocks sensitive operational query', () async {
      final answer = await engine.answer('baskin operasyonel taktik nasil');
      expect(answer.sensitiveBlocked, isTrue);
      expect(AssistantSensitiveQuery.matches('baskin taktik'), isTrue);
    });

    test('no hallucination on unrelated', () async {
      final answer = await engine.answer('en iyi pizza tarifi');
      expect(answer.noStrongMatch || answer.outOfScope, isTrue);
    });
  });
}
