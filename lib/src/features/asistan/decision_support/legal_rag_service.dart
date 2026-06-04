import 'legal_answer_builder.dart';
import 'legal_llm_config.dart';
import 'legal_llm_summarizer.dart';
import 'legal_query_analyzer.dart';
import 'legal_rag_context.dart';
import 'legal_search_service.dart';

/// Yerel arama sonrası isteğe bağlı LLM özeti (RAG).
class LegalRagService {
  LegalRagService({
    LegalLlmSummarizer? summarizer,
  }) : _summarizer = summarizer ?? LegalLlmSummarizer();

  final LegalLlmSummarizer _summarizer;

  Future<LegalDecisionAnswer> enhance({
    required LegalDecisionAnswer base,
    required LegalQueryAnalysis analysis,
    required LegalLlmConfig config,
  }) async {
    if (!config.isReady) return base;
    if (base.sensitiveBlocked ||
        base.outOfScope ||
        base.noStrongMatch ||
        base.topHits.isEmpty) {
      return base;
    }

    final context = LegalRagContext.fromSearch(
      query: base.query,
      analysis: analysis,
      hits: base.topHits,
    );

    try {
      final llm = await _summarizer.summarize(
        context: context,
        config: config,
      );
      if (llm == null) {
        return base.copyWith(
          llmFallbackNote:
              'AI özeti üretilemedi; yerel kaynak özeti gösteriliyor.',
        );
      }

      return base.copyWith(
        shortAnswer: llm.shortAnswer,
        evaluation: llm.evaluation.isNotEmpty ? llm.evaluation : base.evaluation,
        missingInfoNote: llm.missingInfoNote.isNotEmpty
            ? llm.missingInfoNote
            : base.missingInfoNote,
        certaintyLevel: _mapCertainty(llm.certainty, base.certaintyLevel),
        usedLlmSummary: true,
        llmModelLabel: config.model,
        llmFallbackNote: null,
      );
    } on LegalLlmException catch (e) {
      return base.copyWith(
        llmFallbackNote: 'AI özeti alınamadı: ${e.message}',
      );
    } catch (_) {
      return base.copyWith(
        llmFallbackNote:
            'AI özeti alınamadı (ağ veya zaman aşımı). Yerel özet kullanılıyor.',
      );
    }
  }

  LegalCertaintyLevel _mapCertainty(
    String raw,
    LegalCertaintyLevel fallback,
  ) {
    return switch (raw) {
      'high' => LegalCertaintyLevel.high,
      'low' => LegalCertaintyLevel.low,
      'medium' => LegalCertaintyLevel.medium,
      _ => fallback,
    };
  }
}
