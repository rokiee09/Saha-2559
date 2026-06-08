import '../assistant_sensitive_query.dart';
import '../legal/assistant_legal_index.dart';
import '../legal/assistant_query_classifier.dart';
import 'legal_clarification_service.dart';
import 'legal_knowledge_index.dart';
import 'legal_query_analyzer.dart';
import 'legal_search_service.dart';

const kLegalDecisionDisclaimer =
    'Bu bilgi bilgilendirme amaçlıdır. Resmi ve güncel uygulama için '
    'mevzuat.gov.tr, kurum talimatları ve ilgili adli/idari makam kararları '
    'esas alınmalıdır.';

/// Geriye dönük.
const kLegalAssistantDisclaimer = kLegalDecisionDisclaimer;

const kLegalNoMatchMessage =
    'Yerel mevzuat verisi içinde bu olaya net karşılık gelen bir madde bulunamadı.';

const kLegalOutOfScopeMessage =
    'Bu asistan mevzuat, yönetmelik, disiplin, izin, idari para cezaları ve '
    'polis çalışma süreçleriyle ilgili sorulara kaynaklı ön değerlendirme sunar.';

const kLegalAsistanOrnekSorular = [
  'Yedieminden araç çıkaracağız, başka il mahkeme kararı var. Savcı talimatı gerekir mi?',
  'Refakat iznim kaç gün?',
  'Aday memur başka kuruma KPSS ile atanabilir mi?',
  'İşe geç kaldım cezası nedir?',
  'Kimlik vermeyen şahsa ne yapılır?',
  'Dilencilik cezası ne kadar?',
  'Zor kullanma hangi maddede?',
  'Başarı belgesi kaç tane olursa üstün başarı olur?',
  'Atış izni kullandım nasıl kaydederim?',
];

enum LegalCertaintyLevel {
  low,
  medium,
  high,
}

extension LegalCertaintyLevelX on LegalCertaintyLevel {
  String get label => switch (this) {
        LegalCertaintyLevel.low => 'Düşük',
        LegalCertaintyLevel.medium => 'Orta',
        LegalCertaintyLevel.high => 'Yüksek',
      };
}

/// Kaynaklı mevzuat muhakeme cevabı.
class LegalDecisionAnswer {
  const LegalDecisionAnswer({
    required this.query,
    required this.analysis,
    required this.shortAnswer,
    required this.relatedLegislation,
    required this.evaluation,
    required this.missingInfoNote,
    required this.disclaimer,
    required this.topHits,
    required this.certaintyLevel,
    this.clarificationQuestions = const [],
    this.needsClarification = false,
    this.noStrongMatch = false,
    this.outOfScope = false,
    this.sensitiveBlocked = false,
    this.detectedTopics = const [],
    this.usedLlmSummary = false,
    this.llmModelLabel,
    this.llmFallbackNote,
  });

  final String query;
  final LegalQueryAnalysis analysis;
  final String shortAnswer;
  final String relatedLegislation;
  final String evaluation;
  final String missingInfoNote;
  final String disclaimer;
  final List<LegalSearchHit> topHits;
  final LegalCertaintyLevel certaintyLevel;
  final List<LegalClarificationQuestion> clarificationQuestions;
  final bool needsClarification;
  final bool noStrongMatch;
  final bool outOfScope;
  final bool sensitiveBlocked;
  final List<String> detectedTopics;
  final bool usedLlmSummary;
  final String? llmModelLabel;
  final String? llmFallbackNote;

  LegalKnowledgeRecord? get primaryRecord =>
      topHits.isEmpty ? null : topHits.first.record;

  LegalIndexRecord? get primaryIndexRecord => primaryRecord?.toIndexRecord();

  /// Geriye dönük uyumluluk.
  LegalQueryClassification get classification => analysis.classification;

  String get explanation => evaluation;

  String get riskNote => missingInfoNote;

  LegalDecisionAnswer copyWith({
    String? shortAnswer,
    String? relatedLegislation,
    String? evaluation,
    String? missingInfoNote,
    LegalCertaintyLevel? certaintyLevel,
    bool? usedLlmSummary,
    String? llmModelLabel,
    String? llmFallbackNote,
    bool clearLlmFallbackNote = false,
  }) {
    return LegalDecisionAnswer(
      query: query,
      analysis: analysis,
      shortAnswer: shortAnswer ?? this.shortAnswer,
      relatedLegislation: relatedLegislation ?? this.relatedLegislation,
      evaluation: evaluation ?? this.evaluation,
      missingInfoNote: missingInfoNote ?? this.missingInfoNote,
      disclaimer: disclaimer,
      topHits: topHits,
      certaintyLevel: certaintyLevel ?? this.certaintyLevel,
      clarificationQuestions: clarificationQuestions,
      needsClarification: needsClarification,
      noStrongMatch: noStrongMatch,
      outOfScope: outOfScope,
      sensitiveBlocked: sensitiveBlocked,
      detectedTopics: detectedTopics,
      usedLlmSummary: usedLlmSummary ?? this.usedLlmSummary,
      llmModelLabel: llmModelLabel ?? this.llmModelLabel,
      llmFallbackNote: clearLlmFallbackNote
          ? null
          : (llmFallbackNote ?? this.llmFallbackNote),
    );
  }
}

/// Geriye dönük alias.
typedef LegalAssistantAnswer = LegalDecisionAnswer;

class LegalAnswerBuilder {
  const LegalAnswerBuilder({
    this.clarificationService = const LegalClarificationService(),
  });

  final LegalClarificationService clarificationService;

  LegalDecisionAnswer build({
    required LegalQueryAnalysis analysis,
    required List<LegalSearchHit> hits,
    required bool strongMatch,
  }) {
    final query = analysis.rawQuery;

    if (AssistantSensitiveQuery.matches(query)) {
      return LegalDecisionAnswer(
        query: query,
        analysis: analysis,
        shortAnswer: AssistantSensitiveQuery.message,
        relatedLegislation: '',
        evaluation: '',
        missingInfoNote: '',
        disclaimer: kLegalDecisionDisclaimer,
        topHits: const [],
        certaintyLevel: LegalCertaintyLevel.low,
        sensitiveBlocked: true,
      );
    }

    if (!analysis.isInScope) {
      return LegalDecisionAnswer(
        query: query,
        analysis: analysis,
        shortAnswer: kLegalOutOfScopeMessage,
        relatedLegislation: '',
        evaluation: '',
        missingInfoNote: '',
        disclaimer: kLegalDecisionDisclaimer,
        topHits: const [],
        certaintyLevel: LegalCertaintyLevel.low,
        outOfScope: true,
      );
    }

    if (!strongMatch || hits.isEmpty) {
      return LegalDecisionAnswer(
        query: query,
        analysis: analysis,
        shortAnswer: kLegalNoMatchMessage,
        relatedLegislation: '',
        evaluation:
            'Sorunuzu olayın türü, tarih, belge ve yetki unsurlarını ekleyerek '
            'yeniden yazabilir veya Mevzuat sekmesinden tam metne bakabilirsiniz.',
        missingInfoNote: _unresolvedSummary(analysis),
        disclaimer: kLegalDecisionDisclaimer,
        topHits: hits,
        certaintyLevel: LegalCertaintyLevel.low,
        noStrongMatch: true,
        detectedTopics: analysis.topics,
      );
    }

    final clarification = clarificationService.evaluate(
      analysis: analysis,
      hits: hits,
      strongMatch: strongMatch,
    );

    final primary = hits.first.record;
    final related = _formatRelatedLegislation(hits);
    final certainty = _certainty(analysis, hits, clarification.needsClarification);

    if (clarification.needsClarification) {
      return LegalDecisionAnswer(
        query: query,
        analysis: analysis,
        shortAnswer: _partialShortAnswer(primary, analysis),
        relatedLegislation: related,
        evaluation:
            'Mevcut bilgilerle ön değerlendirme yapılabilir; kesin uygulama '
            'için aşağıdaki hususların netleştirilmesi gerekir.',
        missingInfoNote: _formatClarificationNote(clarification, analysis),
        disclaimer: kLegalDecisionDisclaimer,
        topHits: hits,
        certaintyLevel: certainty,
        clarificationQuestions: clarification.questions,
        needsClarification: true,
        detectedTopics: analysis.topics,
      );
    }

    return LegalDecisionAnswer(
      query: query,
      analysis: analysis,
      shortAnswer: _buildShortAnswer(primary, analysis),
      relatedLegislation: related,
      evaluation: _buildEvaluation(primary, analysis, hits),
      missingInfoNote: _buildMissingInfoNote(primary, analysis),
      disclaimer: kLegalDecisionDisclaimer,
      topHits: hits,
      certaintyLevel: certainty,
      detectedTopics: analysis.topics,
    );
  }

  String _partialShortAnswer(
    LegalKnowledgeRecord record,
    LegalQueryAnalysis analysis,
  ) {
    final topic = analysis.topicSummary;
    return 'Konu: $topic. ${record.summary}';
  }

  String _buildShortAnswer(
    LegalKnowledgeRecord record,
    LegalQueryAnalysis analysis,
  ) {
    final base = record.summary.trim();
    if (base.isEmpty) {
      return 'İlgili mevzuata göre ${record.title} konusunda '
          '${record.sourceName} hükümleri çerçevesinde ön değerlendirme yapılır.';
    }
    if (record.tags.contains('mutalaa_ozel')) {
      return base.isNotEmpty
          ? base
          : 'İlgili konuda DPB Mütalaalar Özel Bülteni görüşü bulunmaktadır.';
    }
    if (analysis.jurisdictionIssues.contains('baska_il_yetkisi') &&
        record.topics.contains('yediemin')) {
      return '${base.split('.').first.trim()}. Başka il mahkeme kararının infazında '
          'yazışma ve kararın infaza elverişliliği esastır; savcı talimatı her '
          'olayda otomatik şart sayılmamalıdır.';
    }
    if (base.length > 360) {
      return '${base.substring(0, 357).trimRight()}…';
    }
    return base;
  }

  String _buildEvaluation(
    LegalKnowledgeRecord primary,
    LegalQueryAnalysis analysis,
    List<LegalSearchHit> hits,
  ) {
    final buf = StringBuffer();
    if (primary.tags.contains('mutalaa_ozel')) {
      buf.writeln(
        'Kaynak Devlet Personel Başkanlığı görüş özetidir; bağlayıcı '
        'mahkeme kararı veya güncel mevzuat hükmü değildir.',
      );
    }
    final expl = primary.explanation.trim();
    if (expl.isNotEmpty) {
      buf.writeln(expl);
    } else {
      buf.writeln(
        'Tespit edilen olay unsurları (${analysis.topicSummary}) ile '
        'eşleşen kayıtlar yerel indeksten getirilmiştir.',
      );
    }

    if (analysis.processTypes.isNotEmpty) {
      buf.writeln(
        'İşlem türü: ${analysis.processTypes.join(', ')}.',
      );
    }
    if (hits.length > 1) {
      buf.writeln(
        'Ek kaynak: ${hits.skip(1).take(2).map((h) => h.record.title).join('; ')}.',
      );
    }
    buf.writeln(
      'Kesin hukuki sonuç için dosya safahati, karar metni ve yetkili '
      'mercii görüşü esas alınmalıdır.',
    );
    return buf.toString().trim();
  }

  String _buildMissingInfoNote(
    LegalKnowledgeRecord record,
    LegalQueryAnalysis analysis,
  ) {
    final parts = <String>[];
    if (record.riskNote.trim().isNotEmpty) {
      parts.add(record.riskNote.trim());
    }
    final unresolved = analysis.unresolvedSlots;
    if (unresolved.isNotEmpty) {
      parts.add(
        'Netleştirilmesi faydalı hususlar: '
        '${unresolved.map((s) => s.label).join(', ')}.',
      );
    }
    if (record.riskLevel.index >= LegalRiskLevel.high.index) {
      parts.add(
        'Risk seviyesi: ${record.riskLevel.label}. İşlem öncesi belge ve yetki kontrolü yapın.',
      );
    }
    return parts.join('\n\n');
  }

  String _formatRelatedLegislation(List<LegalSearchHit> hits) {
    return hits
        .take(5)
        .map(
          (h) =>
              '• ${h.record.sourceName} · ${h.record.articleNo} — ${h.record.title}',
        )
        .join('\n');
  }

  String _formatClarificationNote(
    LegalClarificationResult clarification,
    LegalQueryAnalysis analysis,
  ) {
    final buf = StringBuffer(clarification.reason);
    if (analysis.unresolvedSlots.isNotEmpty) {
      buf.writeln();
      buf.writeln(
        'Eksik bilgi alanları: '
        '${analysis.unresolvedSlots.map((s) => s.label).join(', ')}.',
      );
    }
    return buf.toString().trim();
  }

  String _unresolvedSummary(LegalQueryAnalysis analysis) {
    if (analysis.unresolvedSlots.isEmpty) return '';
    return 'Olayı netleştirmek için: '
        '${analysis.unresolvedSlots.map((s) => s.label).join(', ')}.';
  }

  LegalCertaintyLevel _certainty(
    LegalQueryAnalysis analysis,
    List<LegalSearchHit> hits,
    bool needsClarification,
  ) {
    if (needsClarification) return LegalCertaintyLevel.medium;
    final top = hits.first.score;
    if (top >= 90 && analysis.unresolvedSlots.isEmpty) {
      return LegalCertaintyLevel.high;
    }
    if (top >= 60) return LegalCertaintyLevel.medium;
    return LegalCertaintyLevel.low;
  }
}
