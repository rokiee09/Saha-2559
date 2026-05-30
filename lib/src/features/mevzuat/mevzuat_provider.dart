import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/text/tr_text.dart';

// Mevzuat metinleri tüm platformlarda assets içi JSON’dan okunur (web dahil; Isar bu modülde yok).
const _catalogPath = 'assets/mevzuat/catalog.json';
const _basePath = 'assets/mevzuat/';
const _favoritesKey = 'mevzuat_favorites';
const _recentKey = 'mevzuat_recent_views_v1';

/// Polis kullanımı için önde gösterilen kanun kodları (catalog.code)
/// PVSK, CMK, TCK, DMK 657, Emniyet Teşkilatı Kanunu.
const kanunPopularCodesOrdered = ['2559', '5271', '5237', '657', '3201'];

/// Diğer grupta özellikle vurgulanan örnekler (geri kalan hep “diğer”)
const kanunHighlightedOtherExamples = {'7068', '2918'};

/// Liste kartı ↔ detay AppBar Hero etiketi.
String mevzuatLawHeroTag(String entryId) => 'mevzuat-law-$entryId';

/// 5271 CMK katalog kimliği (okuma tipografisi için).
const mevzuatCmkCatalogEntryId = 'kanun-cmk';

Future<void> mevzuatRecordRecent(
  WidgetRef ref,
  String entryId,
  String articleLabel,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_recentKey);
  var list = <Map<String, dynamic>>[];
  if (raw != null && raw.isNotEmpty) {
    try {
      final dec = jsonDecode(raw);
      if (dec is List) {
        list = dec.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
  }
  list.removeWhere((e) => e['entryId'] == entryId);
  list.insert(0, {
    'entryId': entryId,
    'madde': articleLabel,
    'ts': DateTime.now().millisecondsSinceEpoch,
  });
  if (list.length > 8) {
    list = list.sublist(0, 8);
  }
  await prefs.setString(_recentKey, jsonEncode(list));
  ref.read(mevzuatRecentVersionProvider.notifier).state++;
}

final mevzuatRecentVersionProvider = StateProvider<int>((ref) => 0);

final mevzuatRecentItemsProvider =
    FutureProvider.autoDispose<List<MevzuatRecentItem>>((ref) async {
  ref.watch(mevzuatRecentVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_recentKey);
  if (raw == null || raw.isEmpty) {
    return [];
  }
  try {
    final dec = jsonDecode(raw) as List<dynamic>;
    final catalog = await ref.watch(mevzuatCatalogProvider.future);
    final all = <MevzuatEntry>[...catalog.kanunlar, ...catalog.yonetmelikler];
    final idToEntry = {for (final e in all) e.id: e};
    final out = <MevzuatRecentItem>[];
    for (final row in dec) {
      if (row is! Map<String, dynamic>) {
        continue;
      }
      final id = row['entryId'] as String? ?? '';
      final madde = row['madde'] as String? ?? '';
      final e = idToEntry[id];
      if (e == null || madde.isEmpty) {
        continue;
      }
      out.add(MevzuatRecentItem(entry: e, maddeLabel: madde));
    }
    return out;
  } catch (_) {
    return [];
  }
});

class MevzuatRecentItem {
  final MevzuatEntry entry;
  final String maddeLabel;

  const MevzuatRecentItem({
    required this.entry,
    required this.maddeLabel,
  });
}

final mevzuatCatalogProvider =
    FutureProvider<MevzuatCatalog>((ref) async {
  final str = await rootBundle.loadString(_catalogPath);
  final json = jsonDecode(str) as Map<String, dynamic>;
  return MevzuatCatalog.fromJson(json);
});

class MevzuatCatalog {
  final List<MevzuatEntry> kanunlar;
  final List<MevzuatEntry> yonetmelikler;

  MevzuatCatalog({
    required this.kanunlar,
    required this.yonetmelikler,
  });

  factory MevzuatCatalog.fromJson(Map<String, dynamic> json) {
    final kanunlar = (json['kanunlar'] as List<dynamic>?)
            ?.map(
              (e) => MevzuatEntry.fromJson(
                e as Map<String, dynamic>,
                category: 'kanun',
              ),
            )
            .toList() ??
        [];
    final yonetmelikler = (json['yonetmelikler'] as List<dynamic>?)
            ?.map(
              (e) => MevzuatEntry.fromJson(
                e as Map<String, dynamic>,
                category: 'yonetmelik',
              ),
            )
            .toList() ??
        [];
    return MevzuatCatalog(
      kanunlar: kanunlar,
      yonetmelikler: yonetmelikler,
    );
  }
}

class MevzuatEntry {
  final String id;
  final String? code;
  final String name;
  final String path;
  final String category;
  final String sourceUrl;

  MevzuatEntry({
    required this.id,
    this.code,
    required this.name,
    required this.path,
    required this.category,
    required this.sourceUrl,
  });

  factory MevzuatEntry.fromJson(
    Map<String, dynamic> json, {
    required String category,
  }) {
    return MevzuatEntry(
      id: json['id'] as String? ?? '',
      code: json['code'] as String?,
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      category: category,
      sourceUrl:
          json['sourceUrl'] as String? ?? 'https://www.mevzuat.gov.tr/',
    );
  }

  String get displayTitle {
    if (code != null && code!.trim().isNotEmpty) {
      return '${code!} $name';
    }
    return name;
  }

  String get categoryLabel => category == 'kanun' ? 'Kanun' : 'Yönetmelik';

  /// Katalog id son segmenti, kart üst etiket (ör. pvsk -> PVSK)
  String get catalogTag {
    final parts = id.split('-');
    if (parts.isEmpty) return '';
    return parts.last.replaceAll('_', ' ').toUpperCase();
  }
}

/// JSON’dan madde sayısı ve son inceleme (liste kartları; önbelleksiz, hafif okuma)
final mevzuatEntryMetaProvider =
    FutureProvider.autoDispose.family<({int maddeCount, String? lastReview}), String>((
  ref,
  entryId,
) async {
  final entry = await ref.watch(mevzuatEntryProvider(entryId).future);
  if (entry == null) return (maddeCount: 0, lastReview: null);
  try {
    final str = await rootBundle.loadString(_basePath + entry.path);
    final map = jsonDecode(str) as Map<String, dynamic>;
    final n = (map['articles'] as List<dynamic>?)?.length ?? 0;
    final last = map['lastContentReview'] as String? ??
        map['sonKontrolTarihi'] as String?;
    return (maddeCount: n, lastReview: last);
  } catch (_) {
    return (maddeCount: 0, lastReview: null);
  }
});

class MevzuatSection {
  final String id;
  final String article;
  final String title;
  final String text;
  final String source;
  final String? lastReviewed;

  const MevzuatSection({
    required this.id,
    required this.article,
    required this.title,
    required this.text,
    required this.source,
    this.lastReviewed,
  });

  factory MevzuatSection.fromJson(Map<String, dynamic> json) {
    return MevzuatSection(
      id: json['id'] as String? ?? '',
      article: json['article'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      source: json['source'] as String? ?? 'mevzuat.gov.tr',
      lastReviewed: json['lastReviewed'] as String? ?? json['sonKontrolTarihi'] as String?,
    );
  }
}

class MevzuatDocumentData {
  final String law;
  final String source;
  final String sourceUrl;
  final String? lastContentReview;
  final List<MevzuatSection> sections;

  const MevzuatDocumentData({
    required this.law,
    required this.source,
    required this.sourceUrl,
    this.lastContentReview,
    required this.sections,
  });

  factory MevzuatDocumentData.fromJson(
    Map<String, dynamic> json, {
    required MevzuatEntry entry,
  }) {
    final rawSections = (json['articles'] as List<dynamic>?) ?? [];
    final lastRoot = json['lastContentReview'] as String? ??
        json['sonKontrolTarihi'] as String?;
    return MevzuatDocumentData(
      law: json['law'] as String? ?? entry.name,
      source: json['source'] as String? ?? 'mevzuat.gov.tr',
      sourceUrl: json['sourceUrl'] as String? ?? entry.sourceUrl,
      lastContentReview: lastRoot,
      sections: rawSections
          .map((e) => MevzuatSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory MevzuatDocumentData.empty(MevzuatEntry entry) {
    return MevzuatDocumentData(
      law: entry.name,
      source: 'mevzuat.gov.tr',
      sourceUrl: entry.sourceUrl,
      lastContentReview: null,
      sections: const [],
    );
  }
}

final mevzuatEntryProvider =
    FutureProvider.family<MevzuatEntry?, String>((ref, entryId) async {
  final catalog = await ref.watch(mevzuatCatalogProvider.future);
  final all = <MevzuatEntry>[
    ...catalog.kanunlar,
    ...catalog.yonetmelikler,
  ];
  for (final entry in all) {
    if (entry.id == entryId) return entry;
  }
  return null;
});

final mevzuatDocumentContentProvider =
    FutureProvider.family<MevzuatDocumentData, String>((ref, entryId) async {
  final entry = await ref.watch(mevzuatEntryProvider(entryId).future);
  if (entry == null) {
    throw StateError('Mevzuat kaydı bulunamadı.');
  }

  try {
    final str = await rootBundle.loadString(_basePath + entry.path);
    final json = jsonDecode(str) as Map<String, dynamic>;
    return MevzuatDocumentData.fromJson(json, entry: entry);
  } catch (_) {
    return MevzuatDocumentData.empty(entry);
  }
});

/// Ana sayfadaki "Günün maddesi" kartı için seçilen madde + 30 sn özet.
class GununMaddesi {
  const GununMaddesi({
    required this.entry,
    required this.section,
    required this.ozet,
  });

  final MevzuatEntry entry;
  final MevzuatSection section;
  final String ozet;

  String get maddeLabel {
    final art = section.article.trim();
    if (art.isEmpty) return section.title;
    final hasMadde = art.toLowerCase().contains('madde');
    final prefix = hasMadde ? art : 'Madde $art';
    return section.title.isEmpty ? prefix : '$prefix · ${section.title}';
  }
}

String _gununOzet(String text) {
  final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length <= 160) return clean;
  final cut = clean.substring(0, 160);
  final lastStop = cut.lastIndexOf(RegExp(r'[.!?]'));
  if (lastStop >= 80) return cut.substring(0, lastStop + 1);
  final lastSpace = cut.lastIndexOf(' ');
  return '${cut.substring(0, lastSpace > 0 ? lastSpace : cut.length)}…';
}

/// Tarihe göre değişen "günün maddesi" — popüler kanunlardan rastgele bir madde.
final gununMaddesiProvider =
    FutureProvider.autoDispose<GununMaddesi?>((ref) async {
  final catalog = await ref.watch(mevzuatCatalogProvider.future);
  final kanunlar = catalog.kanunlar;
  if (kanunlar.isEmpty) return null;

  // Popüler kanunları öne al; yoksa tüm kanunlar.
  final popular = kanunlar
      .where((e) => kanunPopularCodesOrdered.contains(e.code))
      .toList();
  final pool = popular.isNotEmpty ? popular : kanunlar;

  final daySeed = DateTime.now().difference(DateTime(2020)).inDays;
  final entry = pool[daySeed % pool.length];

  final doc = await ref.watch(mevzuatDocumentContentProvider(entry.id).future);
  final sections =
      doc.sections.where((s) => s.text.trim().length >= 30).toList();
  if (sections.isEmpty) return null;

  final section = sections[(daySeed ~/ pool.length) % sections.length];
  return GununMaddesi(
    entry: entry,
    section: section,
    ozet: _gununOzet(section.text),
  );
});

final mevzuatSearchQueryProvider = StateProvider<String>((ref) => '');
final mevzuatSearchTabProvider =
    StateProvider<MevzuatTab>((ref) => MevzuatTab.kanunlar);

enum MevzuatTab { kanunlar, yonetmelikler, favoriler }

final mevzuatFavoritesVersionProvider = StateProvider<int>((ref) => 0);

final mevzuatFavoritesProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(mevzuatFavoritesVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_favoritesKey);
  return (list ?? []).toSet();
});

const _sectionNotesKey = 'mevzuat_section_notes_v1';

final mevzuatNotesVersionProvider = StateProvider<int>((ref) => 0);

String mevzuatSectionNoteStorageKey(String entryId, String sectionId) =>
    '$entryId::$sectionId';

Future<Map<String, String>> _loadSectionNotes() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_sectionNotesKey);
  if (raw == null || raw.isEmpty) {
    return {};
  }
  try {
    final dec = jsonDecode(raw);
    if (dec is Map) {
      return dec.map(
        (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
      );
    }
  } catch (_) {}
  return {};
}

/// Kişisel madde notları (yalnızca cihazda, SharedPreferences).
final mevzuatSectionNotesMapProvider =
    FutureProvider<Map<String, String>>((ref) async {
  ref.watch(mevzuatNotesVersionProvider);
  final map = await _loadSectionNotes();
  map.removeWhere((_, v) => v.trim().isEmpty);
  return map;
});

Future<void> mevzuatSaveSectionNote(
  WidgetRef ref,
  String entryId,
  String sectionId,
  String text,
) async {
  final key = mevzuatSectionNoteStorageKey(entryId, sectionId);
  final prefs = await SharedPreferences.getInstance();
  final map = await _loadSectionNotes();
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    map.remove(key);
  } else {
    map[key] = trimmed;
  }
  await prefs.setString(_sectionNotesKey, jsonEncode(map));
  ref.read(mevzuatNotesVersionProvider.notifier).state++;
}

/// Tamamlandıktan sonra kayıt favorilerde mi (SnackBar / geri bildirim için).
Future<bool> mevzuatToggleFavorite(WidgetRef ref, String entryId) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_favoritesKey) ?? [];
  final set = list.toSet();
  final bool nowFavorite;
  if (set.contains(entryId)) {
    set.remove(entryId);
    nowFavorite = false;
  } else {
    set.add(entryId);
    nowFavorite = true;
  }
  await prefs.setStringList(_favoritesKey, set.toList());
  ref.read(mevzuatFavoritesVersionProvider.notifier).state++;
  return nowFavorite;
}

final mevzuatSearchResultsProvider =
    FutureProvider.autoDispose<List<MevzuatEntry>>((ref) async {
  final query = trFold(ref.watch(mevzuatSearchQueryProvider).trim());
  final tab = ref.watch(mevzuatSearchTabProvider);
  final catalog = await ref.watch(mevzuatCatalogProvider.future);
  final favorites = await ref.watch(mevzuatFavoritesProvider.future);
  final all = <MevzuatEntry>[
    ...catalog.kanunlar,
    ...catalog.yonetmelikler,
  ];

  List<MevzuatEntry> filtered = all;

  if (tab == MevzuatTab.kanunlar) {
    filtered = filtered.where((a) => a.category == 'kanun').toList();
  } else if (tab == MevzuatTab.yonetmelikler) {
    filtered = filtered.where((a) => a.category == 'yonetmelik').toList();
  } else if (tab == MevzuatTab.favoriler) {
    filtered = filtered.where((a) => favorites.contains(a.id)).toList();
  }

  if (query.isEmpty) return filtered;

  return filtered.where((a) {
    final code = trFold(a.code ?? '');
    return trFold(a.name).contains(query) || code.contains(query);
  }).toList();
});
