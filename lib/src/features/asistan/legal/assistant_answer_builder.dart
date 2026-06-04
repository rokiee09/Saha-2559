import 'assistant_legal_index.dart';
import 'assistant_legal_search_service.dart';
import 'assistant_query_classifier.dart';

const kLegalAssistantDisclaimer =
    'Bu bilgi bilgilendirme amaçlıdır. Resmi ve güncel uygulama için '
    'mevzuat.gov.tr ve kurum talimatları esas alınmalıdır.';

const kLegalNoMatchMessage =
    'Yerel mevzuat verisi içinde bu soruya net karşılık gelen bir madde bulunamadı.';

const kLegalOutOfScopeMessage =
    'Bu asistan mevzuat, yönetmelik, disiplin, izin, idari para cezaları ve '
    'polis çalışma süreçleriyle ilgili sorulara cevap vermek için tasarlanmıştır.';

/// Örnek soru önerileri (yalnızca chip).
const kLegalAsistanOrnekSorular = [
  'Refakat iznim kaç gün?',
  'Atış iznim kaç gün?',
  'İcram var disiplin cezam ne olabilir?',
  'İşe geç kaldım cezası nedir?',
  'Alkollü araç kullandım disiplin soruşturması açılır mı?',
  'Göreve gelmezsem ne olur?',
  'Mazeret izni kaç gün?',
  'Yıllık izin kaç gün?',
  'Kimlik vermeyen şahsa ne yapılır?',
  'Dilencilik cezası ne kadar?',
  'Zor kullanma hangi maddede?',
  'Üst araması hangi mevzuatta geçer?',
];

class LegalAssistantAnswer {
  const LegalAssistantAnswer({
    required this.query,
    required this.classification,
    required this.shortAnswer,
    required this.relatedLegislation,
    required this.explanation,
    required this.riskNote,
    required this.disclaimer,
    required this.topHits,
    this.noStrongMatch = false,
    this.outOfScope = false,
  });

  final String query;
  final LegalQueryClassification classification;
  final String shortAnswer;
  final String relatedLegislation;
  final String explanation;
  final String riskNote;
  final String disclaimer;
  final List<LegalSearchHit> topHits;
  final bool noStrongMatch;
  final bool outOfScope;

  LegalIndexRecord? get primaryRecord =>
      topHits.isEmpty ? null : topHits.first.record;
}

class AssistantAnswerBuilder {
  const AssistantAnswerBuilder();

  LegalAssistantAnswer build({
    required String query,
    required LegalQueryClassification classification,
    required List<LegalSearchHit> hits,
    required bool strongMatch,
  }) {
    if (!classification.isInLegalScope) {
      return LegalAssistantAnswer(
        query: query,
        classification: classification,
        shortAnswer: kLegalOutOfScopeMessage,
        relatedLegislation: '',
        explanation: '',
        riskNote: '',
        disclaimer: kLegalAssistantDisclaimer,
        topHits: const [],
        outOfScope: true,
      );
    }

    if (!strongMatch || hits.isEmpty) {
      return LegalAssistantAnswer(
        query: query,
        classification: classification,
        shortAnswer: kLegalNoMatchMessage,
        relatedLegislation: '',
        explanation:
            'Sorunuzu farklı kelimelerle (ör. kanun adı, fiil, izin türü) '
            'yeniden yazabilir veya Mevzuat sekmesinden tam metne bakabilirsiniz.',
        riskNote: '',
        disclaimer: kLegalAssistantDisclaimer,
        topHits: hits,
        noStrongMatch: true,
      );
    }

    final primary = hits.first.record;

    final shortAnswer = _buildShortAnswer(primary, query);
    final related =
        '${primary.sourceName} · ${primary.articleNo} (${primary.sourceType.label})';
    final explanation = primary.explanation.isNotEmpty
        ? primary.explanation
        : primary.summary;
    final risk = primary.riskNote;

    return LegalAssistantAnswer(
      query: query,
      classification: classification,
      shortAnswer: shortAnswer,
      relatedLegislation: related,
      explanation: explanation,
      riskNote: risk,
      disclaimer: kLegalAssistantDisclaimer,
      topHits: hits,
    );
  }

  String _buildShortAnswer(LegalIndexRecord record, String query) {
    final base = record.summary.trim();
    if (base.isEmpty) {
      return 'İlgili mevzuata göre ${record.title} konusunda '
          '${record.sourceName} hükümleri uygulanır.';
    }
    if (base.length > 320) {
      return '${base.substring(0, 317).trimRight()}…';
    }
    return base;
  }
}
