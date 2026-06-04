import '../../../common/text/tr_text.dart';

/// Türkçe-duyarlı sorgu normalizasyonu ve token çıkarımı.
class NormalizedQuery {
  const NormalizedQuery({
    required this.raw,
    required this.folded,
    required this.tokens,
    required this.expandedTokens,
    required this.articleRefs,
    required this.lawRefs,
  });

  final String raw;
  final String folded;
  final List<String> tokens;
  final Set<String> expandedTokens;
  final List<String> articleRefs;
  final List<String> lawRefs;
}

final _tokenSplit = RegExp(r'[^a-z0-9]+');

/// Kanun kısaltmaları ve yaygın adlar.
const _lawAliases = {
  'pvsk': ['2559', 'polis vazife', 'polis kanunu'],
  'cmk': ['5271', 'ceza muhakemesi'],
  'tck': ['5237', 'turk ceza', 'ceza kanunu'],
  'dmk': ['657', 'devlet memurlari', 'memur kanunu'],
  'kabahatler': ['5326', 'kabahatler kanunu'],
};

/// Madde numarası kalıpları: "md 16", "madde 4/a", "m.105"
final _articlePattern = RegExp(
  r'(?:md\.?|madde|m\.)\s*(\d+[a-zA-Z]?)(?:\s*/\s*([a-zA-Z]))?',
  caseSensitive: false,
);

class QueryNormalizer {
  QueryNormalizer._();

  static NormalizedQuery normalize(String raw, {Set<String>? extraTokens}) {
    final folded = trFold(raw);
    final phrase = folded.replaceAll(RegExp(r'\s+'), ' ').trim();

    final tokens = phrase
        .split(_tokenSplit)
        .where((t) => t.length >= 2)
        .toList();

    final expanded = <String>{...tokens, ...?extraTokens};
    for (final t in tokens) {
      expanded.addAll(SynonymDictionary.expandTerm(t));
    }
    // Tam ifade eşanlamlı genişletme
    expanded.addAll(SynonymDictionary.expandPhrase(phrase));

    final articleRefs = <String>[];
    for (final m in _articlePattern.allMatches(raw)) {
      final base = m.group(1)?.toLowerCase() ?? '';
      final suffix = m.group(2)?.toLowerCase();
      if (base.isNotEmpty) {
        articleRefs.add(base);
        if (suffix != null && suffix.isNotEmpty) {
          articleRefs.add('$base$suffix');
          articleRefs.add('$base/$suffix');
        }
      }
    }

    final lawRefs = <String>[];
    for (final entry in _lawAliases.entries) {
      if (phrase.contains(entry.key) ||
          entry.value.any((a) => phrase.contains(trFold(a)))) {
        lawRefs.add(entry.key);
      }
    }
    for (final t in tokens) {
      if (_lawAliases.containsKey(t)) lawRefs.add(t);
    }

    return NormalizedQuery(
      raw: raw.trim(),
      folded: phrase,
      tokens: tokens,
      expandedTokens: expanded,
      articleRefs: articleRefs,
      lawRefs: lawRefs.toSet().toList(),
    );
  }
}

/// Eş anlamlı ve yakın anlamlı kelime sözlüğü.
abstract final class SynonymDictionary {
  SynonymDictionary._();

  static const _groups = <String, List<String>>{
    'kimlik': [
      'huviyet',
      'kimlik sorma',
      'kimlik kontrol',
      'kimlik verme',
      'kimlik vermeyen',
      'nufus',
      'tc',
    ],
    'arama': [
      'ust aramasi',
      'ust arama',
      'arac aramasi',
      'arac arama',
      'konut aramasi',
      'el koyma',
      'arama karari',
      'onleme aramasi',
      'adli arama',
    ],
    'ceza': [
      'idari para cezasi',
      'ipc',
      'yaptirim',
      'kabahat',
      'para cezasi',
      'ne kadar',
    ],
    'basari': [
      'basari belgesi',
      'ustun basari',
      'odul',
      'taltif',
    ],
    'tutanak': [
      'belge',
      'evrak',
      'sablon',
      'ornek',
      'taslak',
    ],
    'izin': [
      'yillik izin',
      'mazeret',
      'atis izni',
      'refakat',
      'analik',
      'babalik',
    ],
    'saglik': [
      'rapor',
      'heyet',
      'istirahat',
      'elverislilik',
      'maluliyet',
      'saglik raporu',
    ],
    'atis': [
      'atis takibi',
      'atis puani',
      'atis izni',
      'atış',
    ],
    'durdurma': ['dur', 'durdur', 'dur ihtar'],
    'gozalti': ['goz alti', 'yakalama', 'nezaret'],
    'mudafi': ['avukat', 'savunma', 'mudafii'],
    'zor': ['guc', 'guc kullanma', 'zor kullanma', 'silah'],
    'dilencilik': ['dilenci', 'dilencilik'],
    'egitim': ['sertifika', 'kurs', 'diploma', 'egitimlerim'],
    'kariyer': ['profilim', 'emeklilik', 'tayin', 'lojman'],
  };

  static Set<String> expandTerm(String term) {
    final t = trFold(term);
    final out = <String>{t};
    for (final entry in _groups.entries) {
      final key = trFold(entry.key);
      final syns = entry.value.map(trFold).toList();
      if (t == key || syns.contains(t)) {
        out.add(key);
        out.addAll(syns);
      }
    }
    return out;
  }

  static Set<String> expandPhrase(String foldedPhrase) {
    final out = <String>{};
    for (final entry in _groups.entries) {
      final key = trFold(entry.key);
      if (foldedPhrase.contains(key)) {
        out.add(key);
        out.addAll(entry.value.map(trFold));
      }
      for (final syn in entry.value) {
        final s = trFold(syn);
        if (s.length >= 4 && foldedPhrase.contains(s)) {
          out.add(key);
          out.addAll(entry.value.map(trFold));
        }
      }
    }
    return out;
  }

  static bool sharesSynonymGroup(String a, String b) {
    final fa = trFold(a);
    final fb = trFold(b);
    if (fa == fb) return true;
    for (final entry in _groups.entries) {
      final all = {trFold(entry.key), ...entry.value.map(trFold)};
      if (all.contains(fa) && all.contains(fb)) return true;
    }
    return false;
  }
}
