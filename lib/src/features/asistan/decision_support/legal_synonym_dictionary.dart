import '../../../common/text/tr_text.dart';

/// Doğal dil mevzuat sorguları için eş anlamlı ve olay terimleri.
class LegalSynonymDictionary {
  const LegalSynonymDictionary();

  static const Map<String, List<String>> _groups = {
    'yediemin': [
      'yedieminden',
      'adli emanet',
      'emanet arac',
      'otopark',
      'yediemin odasi',
      'aracin iadesi',
    ],
    'mahkeme karari infazi': [
      'mahkeme karari',
      'baska il',
      'baska sehir',
      'infaz',
      'karar infazi',
      'kesinlesme',
      'teslim',
      'iade',
    ],
    'savci talimati': [
      'savci talimati',
      'cumhuriyet savciligi',
      'talimat',
      'savcilik yazisi',
    ],
    'refakat izni': [
      'refakat',
      'hasta yakini',
      'bakmakla yukumlu',
      'refakat iznim',
    ],
    'yillik izin': ['yillik', 'senelik izin', 'izin hakki'],
    'ise gec kalma': [
      'goreve gec gelme',
      'mesaiye gec kalma',
      'gec kalmak',
      'gec kalma',
    ],
    'goreve gelmeme': ['devamsizlik', 'gorev terk', 'devamsiz'],
    'icra': ['maas haczi', 'borc', 'kesinti', 'haciz'],
    'kimlik sorma': [
      'kimlik vermeyen',
      'huviyet',
      'durdurma',
    ],
    'zor kullanma': ['silah kullanma', 'guc kullanma', 'pvsk 16'],
    'ust aramasi': [
      'ust arama',
      'onleme aramasi',
      'adli arama',
    ],
    'dilencilik': ['dilenci', 'kabahat'],
    'basari belgesi': ['ustun basari', 'basari', 'odul'],
    'disiplin': ['uyarma', 'kinama', '7068', 'gkdh'],
    'atis izni': ['poligon', 'atis egitimi', 'atis iznim'],
  };

  List<String> expandQuery(String rawQuery) {
    final folded = trFold(rawQuery);
    final tokens = folded
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 2)
        .toList();
    final out = <String>{...tokens, folded};

    for (final entry in _groups.entries) {
      final key = trFold(entry.key);
      final group = [key, ...entry.value.map(trFold)];
      final hit = group.any(
        (g) => g.length >= 3 && (folded.contains(g) || tokens.contains(g)),
      );
      if (hit) {
        out.addAll(group);
        out.add(key);
      }
    }
    return out.toList();
  }

  Iterable<String> synonymTermsFor(String foldedQuery) sync* {
    for (final entry in _groups.entries) {
      final key = trFold(entry.key);
      final group = [key, ...entry.value.map(trFold)];
      if (group.any((g) => g.length >= 3 && foldedQuery.contains(g))) {
        yield key;
        yield* group;
      }
    }
  }
}
