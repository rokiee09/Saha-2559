import '../../../common/text/tr_text.dart';

/// Mevzuat asistanı eş anlamlı sözlük — sorgu genişletme.
class AssistantSynonymDictionary {
  const AssistantSynonymDictionary();

  static const Map<String, List<String>> _groups = {
    'refakat izni': [
      'refakat',
      'hasta yakini',
      'bakmakla yukumlu',
      'saglik izni',
      'refakat iznim',
    ],
    'yillik izin': ['yillik', 'senelik izin', 'tatil izni', 'izin hakki'],
    'mazeret izni': ['mazeret', 'evlilik izni', 'olum izni'],
    'ise gec kalma': [
      'goreve gec gelme',
      'mesaiye gec kalma',
      'gec kalmak',
      'nobete gec gelme',
      'gec kalma',
    ],
    'goreve gelmeme': ['devamsizlik', 'gorev terk', 'gelmemek', 'devamsiz'],
    'icra': [
      'maas haczi',
      'borc',
      'kesinti',
      'haciz',
      'icra takibi',
      'maas kesintisi',
    ],
    'alkollu arac': [
      'alkollu arac kullanma',
      'alkol',
      'trafik guvenligi',
      'disiplin sorusturmasi',
      'sarhos arac',
    ],
    'atis izni': [
      'atis egitimi',
      'poligon',
      'atis gunu',
      'hizmet ici egitim',
      'gorev izni',
      'atis iznim',
    ],
    'kimlik sorma': [
      'kimlik vermeyen',
      'huviyet',
      'kimlik kontrol',
      'durdurma',
    ],
    'zor kullanma': [
      'silah kullanma',
      'guc kullanma',
      'orantili guc',
      'pvsk 16',
    ],
    'ust aramasi': [
      'ust arama',
      'onleme aramasi',
      'adli arama',
      'arama karari',
    ],
    'arac aramasi': ['aracta arama', 'arac arama'],
    'dilencilik': ['dilenci', 'dilencilik cezasi', 'kabahat'],
    'basari belgesi': [
      'ustun basari',
      'basari',
      'odul',
      'taltif',
    ],
    'disiplin': [
      'uyarma',
      'kinama',
      'ayliktan kesme',
      '7068',
      'gkdh',
    ],
  };

  /// Sorgu için genişletilmiş token listesi (normalize edilmiş).
  List<String> expandQuery(String rawQuery) {
    final folded = trFold(rawQuery);
    final tokens = folded
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 2)
        .toList();
    final out = <String>{...tokens, folded.replaceAll(RegExp(r'\s+'), ' ')};

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

  /// Eş anlamlı ifade eşleşmesi puanı için terimler.
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
