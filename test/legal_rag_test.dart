import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/asistan/decision_support/legal_decision_engine.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_knowledge_index.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_llm_config.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_query_analyzer.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_rag_context.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_search_service.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_legal_index.dart';

void main() {
  test('LegalRagContext packs sources from hits', () {
    const record = LegalKnowledgeRecord(
      id: 'test_1',
      sourceName: 'Test Kanun',
      articleNo: 'm. 1',
      title: 'Test madde',
      summary: 'Özet metin',
      fullText: 'Tam metin',
      keywords: ['test'],
      tags: ['test'],
    );
    final analysis = LegalQueryAnalyzer().analyze('test sorusu');
    final hits = [
      LegalSearchHit(record: record, score: 80, matchedFields: ['title']),
    ];
    final ctx = LegalRagContext.fromSearch(
      query: 'test sorusu',
      analysis: analysis,
      hits: hits,
    );
    expect(ctx.sources.length, 1);
    expect(ctx.toPromptBlock(), contains('[KAYNAK-1]'));
    expect(ctx.toPromptBlock(), contains('Test Kanun'));
  });

  test('RAG enhance skips when LLM disabled', () async {
    final engine = LegalDecisionEngine(
      index: kPriorityLegalRecords
          .map(LegalKnowledgeRecord.fromIndexRecord)
          .toList(),
      llmConfig: const LegalLlmConfig(enabled: false),
    );
    final answer = await engine.answer('Refakat iznim kaç gün?');
    expect(answer.usedLlmSummary, isFalse);
  });
}
