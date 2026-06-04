import 'legal_query_analyzer.dart';
import 'legal_search_service.dart';

/// Netleştirme sorusu (kullanıcıya gösterilir).
class LegalClarificationQuestion {
  const LegalClarificationQuestion({
    required this.slotId,
    required this.label,
    required this.question,
  });

  final String slotId;
  final String label;
  final String question;
}

class LegalClarificationResult {
  const LegalClarificationResult({
    required this.needsClarification,
    required this.questions,
    required this.reason,
  });

  final bool needsClarification;
  final List<LegalClarificationQuestion> questions;
  final String reason;
}

/// Eksik olay bilgisi varsa önce netleştirici soru üretir.
class LegalClarificationService {
  const LegalClarificationService({
    this.minUnresolvedToAsk = 1,
    this.maxQuestions = 4,
  });

  final int minUnresolvedToAsk;
  final int maxQuestions;

  LegalClarificationResult evaluate({
    required LegalQueryAnalysis analysis,
    required List<LegalSearchHit> hits,
    required bool strongMatch,
  }) {
    if (!analysis.isInScope || !strongMatch || hits.isEmpty) {
      return const LegalClarificationResult(
        needsClarification: false,
        questions: [],
        reason: '',
      );
    }

    final unresolved = analysis.unresolvedSlots;
    if (unresolved.length < minUnresolvedToAsk) {
      return const LegalClarificationResult(
        needsClarification: false,
        questions: [],
        reason: '',
      );
    }

    final isComplexEvent = analysis.topics.length >= 2 ||
        analysis.processTypes.isNotEmpty ||
        analysis.rawQuery.length >= 40;

    if (!isComplexEvent && unresolved.length < 2) {
      return const LegalClarificationResult(
        needsClarification: false,
        questions: [],
        reason: '',
      );
    }

    final questions = unresolved
        .take(maxQuestions)
        .map(
          (s) => LegalClarificationQuestion(
            slotId: s.id,
            label: s.label,
            question: s.question,
          ),
        )
        .toList();

    return LegalClarificationResult(
      needsClarification: true,
      questions: questions,
      reason:
          'Olayın doğru mevzuatla eşleşmesi için aşağıdaki bilgiler netleştirilmelidir.',
    );
  }
}
