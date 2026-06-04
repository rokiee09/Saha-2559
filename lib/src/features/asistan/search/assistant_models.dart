/// Asistan arama kategorileri.
enum AssistantCategory {
  mevzuat,
  idariParaCeza,
  tutanak,
  kariyer,
  atis,
  basari,
  egitim,
  saglik,
  uygulamaYardim,
}

extension AssistantCategoryX on AssistantCategory {
  String get label => switch (this) {
        AssistantCategory.mevzuat => 'Mevzuat',
        AssistantCategory.idariParaCeza => 'İdari Para Cezası',
        AssistantCategory.tutanak => 'Tutanak / Evrak',
        AssistantCategory.kariyer => 'Kariyer',
        AssistantCategory.atis => 'Atış',
        AssistantCategory.basari => 'Başarı Belgesi',
        AssistantCategory.egitim => 'Eğitim / Sertifika',
        AssistantCategory.saglik => 'Sağlık ve Sosyal Haklar',
        AssistantCategory.uygulamaYardim => 'Uygulama içi yardım',
      };
}

/// Detay ekranına yönlendirme bilgisi.
class SearchResultNav {
  const SearchResultNav({
    this.mevzuatEntryId,
    this.mevzuatSectionId,
    this.moduleRoute,
    this.moduleQuery,
    this.tutanakTemplateId,
    this.saglikKonuId,
  });

  final String? mevzuatEntryId;
  final String? mevzuatSectionId;
  final String? moduleRoute;
  final String? moduleQuery;
  final String? tutanakTemplateId;
  final String? saglikKonuId;
}

/// Birleşik arama sonucu.
class SearchResult {
  const SearchResult({
    required this.id,
    required this.category,
    required this.title,
    required this.shortAnswer,
    required this.source,
    required this.appContext,
    required this.relevanceScore,
    this.nav,
    this.isMevzuatBacked = false,
  });

  final String id;
  final AssistantCategory category;
  final String title;
  final String shortAnswer;
  final String source;
  final String appContext;
  final double relevanceScore;
  final SearchResultNav? nav;
  final bool isMevzuatBacked;
}

/// Asistan cevap paketi.
class AssistantAnswer {
  const AssistantAnswer({
    required this.query,
    required this.primaryCategory,
    required this.primary,
    required this.topResults,
    this.sensitiveBlocked = false,
    this.noStrongMatch = false,
  });

  final String query;
  final AssistantCategory? primaryCategory;
  final SearchResult? primary;
  final List<SearchResult> topResults;
  final bool sensitiveBlocked;
  final bool noStrongMatch;

  static const warning =
      'Bu bilgi bilgilendirme amaçlıdır. Resmi ve güncel uygulama için '
      'mevzuat.gov.tr ve kurum talimatları esas alınmalıdır.';

  static const noMatchMessage =
      'Bu konuda yerel veri içinde net bir sonuç bulamadım. İstersen '
      'mevzuat, idari para cezası veya tutanaklar içinde ayrı ayrı arama yapabilirim.';

  static const sensitiveMessage =
      'Bu konu operasyonel/hassas nitelikte olabilir. Uygulama yalnızca '
      'genel mevzuat ve bilgilendirme desteği sunar.';

  factory AssistantAnswer.sensitive(String query) => AssistantAnswer(
        query: query,
        primaryCategory: null,
        primary: null,
        topResults: const [],
        sensitiveBlocked: true,
      );

  factory AssistantAnswer.empty(String query) => AssistantAnswer(
        query: query,
        primaryCategory: null,
        primary: null,
        topResults: const [],
        noStrongMatch: true,
      );
}

/// Güçlü eşleşme eşiği.
const kAssistantMinRelevanceScore = 28.0;
