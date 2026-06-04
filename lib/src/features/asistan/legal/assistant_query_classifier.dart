import '../../../common/text/tr_text.dart';
import 'assistant_synonym_dictionary.dart';

/// Mevzuat soru kategorileri.
enum LegalQueryCategory {
  izinler,
  saglikRefakatRapor,
  disiplin,
  icraMaasKesinti,
  atisEgitimGorevIzni,
  pvsk,
  cmk,
  tck,
  idariParaCezalari,
  tutanakEvrak,
  personelHaklari,
  mevzuatGenel,
}

extension LegalQueryCategoryX on LegalQueryCategory {
  String get label => switch (this) {
        LegalQueryCategory.izinler => 'İzinler',
        LegalQueryCategory.saglikRefakatRapor => 'Sağlık / Refakat / Rapor',
        LegalQueryCategory.disiplin => 'Disiplin',
        LegalQueryCategory.icraMaasKesinti => 'İcra / Maaş Kesintisi / Borç',
        LegalQueryCategory.atisEgitimGorevIzni => 'Atış / Eğitim / Görev İzni',
        LegalQueryCategory.pvsk => 'PVSK',
        LegalQueryCategory.cmk => 'CMK',
        LegalQueryCategory.tck => 'TCK',
        LegalQueryCategory.idariParaCezalari => 'İdari Para Cezaları',
        LegalQueryCategory.tutanakEvrak => 'Tutanak / Evrak',
        LegalQueryCategory.personelHaklari => 'Personel Hakları',
        LegalQueryCategory.mevzuatGenel => 'Mevzuat',
      };
}

class LegalQueryClassification {
  const LegalQueryClassification({
    required this.primary,
    required this.secondary,
    required this.isInLegalScope,
    required this.foldedQuery,
    required this.expandedTerms,
  });

  final LegalQueryCategory primary;
  final List<LegalQueryCategory> secondary;
  final bool isInLegalScope;
  final String foldedQuery;
  final List<String> expandedTerms;
}

class AssistantQueryClassifier {
  AssistantQueryClassifier({AssistantSynonymDictionary? synonyms})
      : _synonyms = synonyms ?? const AssistantSynonymDictionary();

  final AssistantSynonymDictionary _synonyms;

  static const _legalScopeHints = [
    'izin',
    'refakat',
    'rapor',
    'disiplin',
    'ceza',
    'icra',
    'haciz',
    'maas',
    'pvsk',
    'cmk',
    'tck',
    'dmk',
    'kanun',
    'yonetmelik',
    'madde',
    'kabahat',
    'idari para',
    'tutanak',
    'arama',
    'kimlik',
    'zor kullan',
    'silah',
    'atis',
    'poligon',
    'gec kal',
    'devamsiz',
    'alkol',
    'dilencilik',
    'basari',
    'memur',
    'personel',
    'mutalaa',
    'mütalaa',
    'dpb',
    'nobet',
    'mesai',
    'yediemin',
    'emanet',
    'mahkeme',
    'infaz',
    'teslim',
    'savci',
    'talimat',
  ];

  static const _outOfScopeHints = [
    'hava durumu',
    'hava nasil',
    'futbol',
    'yemek tarifi',
    'film oner',
    'pizza',
    'sohbet',
    'nasılsın',
    'merhaba nasilsin',
  ];

  LegalQueryClassification classify(String rawQuery) {
    final trimmed = rawQuery.trim();
    final folded = trFold(trimmed);
    final expanded = _synonyms.expandQuery(trimmed);

    if (trimmed.length < 2) {
      return LegalQueryClassification(
        primary: LegalQueryCategory.mevzuatGenel,
        secondary: const [],
        isInLegalScope: true,
        foldedQuery: folded,
        expandedTerms: expanded,
      );
    }

    final hasOutOfScope = _outOfScopeHints.any((o) => folded.contains(trFold(o)));
    final hasLegalHint =
        _legalScopeHints.any((h) => folded.contains(trFold(h)));

    if (hasOutOfScope && !hasLegalHint) {
      return LegalQueryClassification(
        primary: LegalQueryCategory.mevzuatGenel,
        secondary: const [],
        isInLegalScope: false,
        foldedQuery: folded,
        expandedTerms: expanded,
      );
    }

    final inScope = hasLegalHint ||
        expanded.length > trFold(trimmed).split(' ').where((t) => t.length >= 3).length;

    final scores = <LegalQueryCategory, int>{};
    void bump(LegalQueryCategory c, int n) {
      scores[c] = (scores[c] ?? 0) + n;
    }

    void matchList(LegalQueryCategory c, List<String> terms, int weight) {
      for (final t in terms) {
        final ft = trFold(t);
        if (ft.length >= 3 && folded.contains(ft)) bump(c, weight);
      }
    }

    matchList(LegalQueryCategory.izinler, [
      'izin',
      'yillik izin',
      'mazeret izni',
      'refakat izni',
      'iznim',
      'kac gun',
    ], 3);
    matchList(LegalQueryCategory.saglikRefakatRapor, [
      'refakat',
      'rapor',
      'saglik',
      'heyet',
      'hasta',
    ], 3);
    matchList(LegalQueryCategory.disiplin, [
      'disiplin',
      'uyarma',
      'kinama',
      'sorusturma',
      'gec kal',
      'gelmeme',
      'devamsiz',
      'alkol',
    ], 3);
    matchList(LegalQueryCategory.icraMaasKesinti, [
      'icra',
      'haciz',
      'borc',
      'kesinti',
      'maas',
    ], 4);
    matchList(LegalQueryCategory.atisEgitimGorevIzni, [
      'atis',
      'poligon',
      'egitim',
      'sertifika',
    ], 4);
    matchList(LegalQueryCategory.pvsk, [
      'pvsk',
      '2559',
      'kimlik',
      'durdur',
      'zor kullan',
      'ust arama',
      'arac arama',
    ], 3);
    matchList(LegalQueryCategory.cmk, ['cmk', '5271', 'sorgu', 'gozalti'], 3);
    matchList(LegalQueryCategory.tck, ['tck', '5237', 'suc', 'ceza hukuku'], 3);
    matchList(LegalQueryCategory.idariParaCezalari, [
      'idari para',
      'kabahat',
      'dilencilik',
      'para cezasi',
    ], 4);
    matchList(LegalQueryCategory.tutanakEvrak, [
      'tutanak',
      'evrak',
      'zapt',
    ], 2);
    matchList(LegalQueryCategory.personelHaklari, [
      'basari',
      'odul',
      'personel',
      'memur',
      'hak',
    ], 2);

    LegalQueryCategory primary = LegalQueryCategory.mevzuatGenel;
    var best = 0;
    for (final e in scores.entries) {
      if (e.value > best) {
        best = e.value;
        primary = e.key;
      }
    }

    final secondary = scores.entries
        .where((e) => e.key != primary && e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final secCats =
        secondary.map((e) => e.key).take(2).toList(growable: false);

    return LegalQueryClassification(
      primary: primary,
      secondary: secCats,
      isInLegalScope: inScope || best > 0,
      foldedQuery: folded,
      expandedTerms: expanded,
    );
  }
}
