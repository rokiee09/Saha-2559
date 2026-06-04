import '../../../common/text/tr_text.dart';
import '../legal/assistant_query_classifier.dart';
import 'legal_synonym_dictionary.dart';

/// Eksik bilgi alanı — netleştirme sorusu üretilir.
class LegalMissingInfoSlot {
  const LegalMissingInfoSlot({
    required this.id,
    required this.label,
    required this.question,
    required this.resolveHints,
  });

  final String id;
  final String label;
  final String question;
  final List<String> resolveHints;

  bool isResolvedIn(String foldedQuery) {
    return resolveHints.any(
      (h) => h.length >= 3 && foldedQuery.contains(trFold(h)),
    );
  }
}

/// Olay analizi çıktısı.
class LegalQueryAnalysis {
  const LegalQueryAnalysis({
    required this.rawQuery,
    required this.normalizedQuery,
    required this.foldedQuery,
    required this.expandedTerms,
    required this.topics,
    required this.subtopics,
    required this.processTypes,
    required this.jurisdictionIssues,
    required this.missingSlots,
    required this.unresolvedSlots,
    required this.classification,
  });

  final String rawQuery;
  final String normalizedQuery;
  final String foldedQuery;
  final List<String> expandedTerms;
  final List<String> topics;
  final List<String> subtopics;
  final List<String> processTypes;
  final List<String> jurisdictionIssues;
  final List<LegalMissingInfoSlot> missingSlots;
  final List<LegalMissingInfoSlot> unresolvedSlots;
  final LegalQueryClassification classification;

  bool get isInScope =>
      classification.isInLegalScope ||
      topics.isNotEmpty ||
      processTypes.isNotEmpty;

  String get topicSummary {
    if (topics.isEmpty) return 'genel mevzuat';
    return topics.join(', ');
  }
}

class LegalQueryAnalyzer {
  LegalQueryAnalyzer({
    LegalSynonymDictionary? synonyms,
    AssistantQueryClassifier? classifier,
  })  : _synonyms = synonyms ?? const LegalSynonymDictionary(),
        _classifier = classifier ?? AssistantQueryClassifier();

  final LegalSynonymDictionary _synonyms;
  final AssistantQueryClassifier _classifier;

  static const _topicPatterns = <String, List<String>>{
    'yediemin': [
      'yediemin',
      'yedieminden',
      'adli emanet',
      'emanet arac',
      'yediemin odasi',
    ],
    'arac_teslimi': [
      'arac cikar',
      'araci cikar',
      'arac teslim',
      'aracin iadesi',
      'teslim ed',
      'yedieminden',
    ],
    'mahkeme_karari_infazi': [
      'mahkeme karari',
      'karar infaz',
      'infaz',
      'hukum',
      'karar var',
    ],
    'yetki': [
      'baska il',
      'baska sehir',
      'baska ilce',
      'yetki',
      'gorev yeri',
    ],
    'savci_talimati': [
      'savci talimati',
      'savcilik',
      'talimat',
      'cumhuriyet savciligi',
    ],
    'izinler': ['izin', 'refakat', 'mazeret', 'yillik izin'],
    'disiplin': ['disiplin', 'gec kal', 'devamsiz', 'uyarma', 'kinama'],
    'pvsk': ['pvsk', 'kimlik', 'durdur', 'zor kullan', 'arama'],
    'idari_para_ceza': ['idari para', 'kabahat', 'dilencilik'],
    'personel_haklari': ['basari', 'odul', 'taltif'],
    'atis': ['atis', 'poligon'],
  };

  static const _processPatterns = <String, List<String>>{
    'mahkeme_kararinin_infazi': [
      'mahkeme karari',
      'infaz',
      'karar infaz',
    ],
    'arac_teslim_islemi': [
      'teslim',
      'iade',
      'cikar',
      'emanet',
    ],
    'idari_islem': ['idari para', 'kabahat', 'tutanak'],
    'disiplin_sorusturmasi': ['disiplin', 'sorusturma', 'gec kal'],
  };

  static final _slotCatalog = <String, List<LegalMissingInfoSlot>>{
    'yediemin': [
      LegalMissingInfoSlot(
        id: 'karar_kesin_mi',
        label: 'Karar kesinliği',
        question: 'Mahkeme kararı kesinleşmiş mi, infaza elverişli şerh var mı?',
        resolveHints: [
          'kesinlesti',
          'kesinlesme',
          'kesin',
          'infaza elverisli',
          'tefhim',
        ],
      ),
      LegalMissingInfoSlot(
        id: 'teslim_hukmu_var_mi',
        label: 'Teslim hükmü',
        question:
            'Kararda aracın iadesi/teslimi veya yedieminden çıkarılmasına ilişkin '
            'açık hüküm var mı?',
        resolveHints: [
          'teslim',
          'iade',
          'yedieminden cikar',
          'emanetten cikar',
          'iadesine',
        ],
      ),
      LegalMissingInfoSlot(
        id: 'adli_emanette_mi',
        label: 'Emanet durumu',
        question:
            'Araç adli emanette / yediemin kaydında mı, plaka ve dosya eşleşiyor mu?',
        resolveHints: [
          'adli emanet',
          'yediemin',
          'emanet',
          'yediemin kaydi',
          'otopark',
        ],
      ),
      LegalMissingInfoSlot(
        id: 'baska_il_karari_detay',
        label: 'Başka il kararı',
        question:
            'Kararı veren mahkeme/savcılık hangi ilde, infaz yazışması yapıldı mı?',
        resolveHints: [
          'baska il',
          'baska sehir',
          'infaz yazisma',
          'yetkili mahkeme',
          'karari veren',
        ],
      ),
    ],
    'disiplin': [
      LegalMissingInfoSlot(
        id: 'gec_kalma_suresi',
        label: 'Gecikme süresi',
        question: 'Geç kalma süresi ve mazeret durumu nedir?',
        resolveHints: ['dakika', 'saat', 'mazeret', 'belge', 'rapor'],
      ),
      LegalMissingInfoSlot(
        id: 'tekrar',
        label: 'Tekerrür',
        question: 'Aynı fiil daha önce işlendi mi?',
        resolveHints: ['tekrar', 'once de', 'ikinci kez', 'ilk kez'],
      ),
    ],
  };

  LegalQueryAnalysis analyze(String rawQuery) {
    final trimmed = rawQuery.trim();
    final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    final folded = trFold(normalized);
    final expanded = _synonyms.expandQuery(trimmed);
    final classification = _classifier.classify(trimmed);

    final topics = <String>[];
    final subtopics = <String>[];
    final processTypes = <String>[];
    final jurisdictionIssues = <String>[];

    for (final e in _topicPatterns.entries) {
      if (_anyMatch(folded, expanded, e.value)) topics.add(e.key);
    }
    for (final e in _processPatterns.entries) {
      if (_anyMatch(folded, expanded, e.value)) processTypes.add(e.key);
    }

    if (topics.contains('yetki') || _anyMatch(folded, expanded, _topicPatterns['yetki']!)) {
      jurisdictionIssues.add('baska_il_yetkisi');
    }
    if (topics.contains('savci_talimati')) {
      subtopics.add('talimat_gerekliligi');
    }
    if (topics.contains('yediemin') && topics.contains('arac_teslimi')) {
      subtopics.add('yediemin_arac_teslim');
    }

    final slots = <LegalMissingInfoSlot>[];
    for (final topic in topics) {
      slots.addAll(_slotCatalog[topic] ?? const []);
    }
    final seen = <String>{};
    final uniqueSlots = <LegalMissingInfoSlot>[];
    for (final s in slots) {
      if (seen.add(s.id)) uniqueSlots.add(s);
    }

    final unresolved =
        uniqueSlots.where((s) => !s.isResolvedIn(folded)).toList();

    return LegalQueryAnalysis(
      rawQuery: trimmed,
      normalizedQuery: normalized,
      foldedQuery: folded,
      expandedTerms: expanded,
      topics: topics,
      subtopics: subtopics,
      processTypes: processTypes,
      jurisdictionIssues: jurisdictionIssues,
      missingSlots: uniqueSlots,
      unresolvedSlots: unresolved,
      classification: classification,
    );
  }

  bool _anyMatch(String folded, List<String> expanded, List<String> patterns) {
    for (final p in patterns) {
      final fp = trFold(p);
      if (fp.length >= 3 && folded.contains(fp)) return true;
      for (final t in expanded) {
        if (t.length >= 3 && (fp.contains(t) || t.contains(fp))) return true;
      }
    }
    return false;
  }
}
