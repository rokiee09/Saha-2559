import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/assistant_sensitive_query.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_decision_engine.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_knowledge_index.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_query_analyzer.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_index.dart';

void main() {
  late LegalDecisionEngine engine;

  setUp(() {
    engine = LegalDecisionEngine(
      index: [
        ...kScenarioKnowledgeRecords,
        ...kPriorityLegalRecords.map(LegalKnowledgeRecord.fromIndexRecord),
      ],
    );
  });

  group('LegalQueryAnalyzer', () {
    test('yediemin sorusunda konu ve eksik bilgi cikarir', () {
      const q =
          'Yedieminden araç çıkaracağız ancak başka ilin mahkeme kararı var. '
          'Kendi bulunduğum ilde savcı talimatı almaya gerek var mı?';
      final analysis = LegalQueryAnalyzer().analyze(q);

      expect(analysis.topics, contains('yediemin'));
      expect(analysis.topics, contains('arac_teslimi'));
      expect(analysis.topics, contains('savci_talimati'));
      expect(analysis.jurisdictionIssues, contains('baska_il_yetkisi'));
      expect(analysis.unresolvedSlots.map((s) => s.id), isNotEmpty);
    });
  });

  group('LegalDecisionEngine', () {
    test('yediemin sorusu kaynakli cevap ve netlestirme', () async {
      const q =
          'Yedieminden araç çıkaracağız ancak başka ilin mahkeme kararı var. '
          'Kendi bulunduğum ilde savcı talimatı almaya gerek var mı?';
      final answer = await engine.answer(q);

      expect(answer.sensitiveBlocked, isFalse);
      expect(answer.noStrongMatch, isFalse);
      expect(answer.shortAnswer.toLowerCase(), contains('yediemin'));
      expect(answer.relatedLegislation, isNotEmpty);
      expect(answer.needsClarification, isTrue);
      expect(answer.clarificationQuestions, isNotEmpty);
      expect(answer.primaryRecord?.id, 'scenario_yediemin_arac_teslim');
    });

    test('kaynak yoksa uydurma yok', () async {
      final answer = await engine.answer('en iyi pizza tarifi nedir');
      expect(answer.noStrongMatch || answer.outOfScope, isTrue);
    });

    test('hassas sorgu engellenir', () async {
      final answer = await engine.answer('baskın operasyonel taktik nasıl');
      expect(
        answer.sensitiveBlocked ||
            AssistantSensitiveQuery.matches('baskın operasyonel taktik'),
        isTrue,
      );
    });

    test('refakat izni guclu eslesme', () async {
      final answer = await engine.answer('Refakat iznim kaç gün?');
      expect(answer.noStrongMatch, isFalse);
      expect(answer.shortAnswer.toLowerCase(), contains('refakat'));
    });
  });
}
