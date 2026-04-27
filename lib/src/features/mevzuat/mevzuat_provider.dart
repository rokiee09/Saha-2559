import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mevzuat metinleri tüm platformlarda assets içi JSON’dan okunur (web dahil; Isar bu modülde yok).
const _catalogPath = 'assets/mevzuat/catalog.json';
const _basePath = 'assets/mevzuat/';
const _favoritesKey = 'mevzuat_favorites';

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

Future<void> mevzuatToggleFavorite(WidgetRef ref, String entryId) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_favoritesKey) ?? [];
  final set = list.toSet();
  if (set.contains(entryId)) {
    set.remove(entryId);
  } else {
    set.add(entryId);
  }
  await prefs.setStringList(_favoritesKey, set.toList());
  ref.read(mevzuatFavoritesVersionProvider.notifier).state++;
}

final mevzuatSearchResultsProvider =
    FutureProvider.autoDispose<List<MevzuatEntry>>((ref) async {
  final query = ref.watch(mevzuatSearchQueryProvider).trim().toLowerCase();
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
    final code = a.code?.toLowerCase() ?? '';
    return a.name.toLowerCase().contains(query) || code.contains(query);
  }).toList();
});
