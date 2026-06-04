import '../assistant_sensitive_query.dart';
import 'legal_answer_builder.dart';
import 'legal_knowledge_index.dart';
import 'legal_llm_config.dart';
import 'legal_query_analyzer.dart';
import 'legal_rag_service.dart';
import 'legal_search_service.dart';

export 'legal_llm_config.dart';
export 'legal_rag_service.dart';

/// Kaynaklı mevzuat muhakeme asistanı — yerel indeks + isteğe bağlı RAG/LLM.
class LegalDecisionEngine {
  LegalDecisionEngine({
    required List<LegalKnowledgeRecord> index,
    LegalQueryAnalyzer? analyzer,
    LegalSearchService? search,
    LegalAnswerBuilder? answerBuilder,
    LegalRagService? ragService,
    LegalLlmConfig? llmConfig,
  })  : _analyzer = analyzer ?? LegalQueryAnalyzer(),
        _search = search ?? LegalSearchService(index: index),
        _answerBuilder = answerBuilder ?? const LegalAnswerBuilder(),
        _ragService = ragService ?? LegalRagService(),
        _llmConfig = llmConfig ?? const LegalLlmConfig();

  final LegalQueryAnalyzer _analyzer;
  final LegalSearchService _search;
  final LegalAnswerBuilder _answerBuilder;
  final LegalRagService _ragService;
  final LegalLlmConfig _llmConfig;

  /// Yerel arama + (açıksa) kaynaklı LLM özeti.
  Future<LegalDecisionAnswer> answer(String rawQuery) async {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(rawQuery, 'rawQuery', 'cannot be empty');
    }

    final analysis = _analyzer.analyze(trimmed);
    final hits = AssistantSensitiveQuery.matches(trimmed)
        ? const <LegalSearchHit>[]
        : _search.search(analysis);
    final strong =
        !AssistantSensitiveQuery.matches(trimmed) && _search.hasStrongMatch(hits);

    final base = _answerBuilder.build(
      analysis: analysis,
      hits: hits,
      strongMatch: strong,
    );

    return _ragService.enhance(
      base: base,
      analysis: analysis,
      config: _llmConfig,
    );
  }
}
