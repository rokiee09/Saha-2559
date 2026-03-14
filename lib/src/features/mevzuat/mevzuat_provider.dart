import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/mevzuat_article.dart';

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
            ?.map((e) => MevzuatEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final yonetmelikler = (json['yonetmelikler'] as List<dynamic>?)
            ?.map((e) => MevzuatEntry.fromJson(e as Map<String, dynamic>))
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

  MevzuatEntry({
    required this.id,
    this.code,
    required this.name,
    required this.path,
  });

  factory MevzuatEntry.fromJson(Map<String, dynamic> json) {
    return MevzuatEntry(
      id: json['id'] as String? ?? '',
      code: json['code'] as String?,
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );
  }
}

final mevzuatArticleProvider =
    FutureProvider.family<MevzuatArticle?, String>((ref, articleId) async {
  final all = await ref.watch(mevzuatAllArticlesProvider.future);
  return all.where((a) => a.id == articleId).firstOrNull;
});

final mevzuatAllArticlesProvider = FutureProvider<List<MevzuatArticle>>((ref) async {
  final catalog = await ref.watch(mevzuatCatalogProvider.future);
  final all = <MevzuatArticle>[];

  for (final entry in catalog.kanunlar) {
    try {
      final str = await rootBundle.loadString(_basePath + entry.path);
      final json = jsonDecode(str) as Map<String, dynamic>;
      final lawName = json['law'] as String? ?? entry.name;
      final articles = (json['articles'] as List<dynamic>?) ?? [];
      for (final a in articles) {
        final art = MevzuatArticle.fromJson(
          a as Map<String, dynamic>,
          lawName,
          category: 'kanun',
        );
        final id = art.id.isEmpty
            ? '${entry.id}-${art.article.replaceAll(RegExp(r'\s'), '')}'
            : art.id;
        all.add(MevzuatArticle(
          id: id,
          law: lawName,
          article: art.article,
          title: art.title,
          text: art.text,
          source: art.source,
          category: 'kanun',
        ));
      }
    } catch (_) {}
  }

  for (final entry in catalog.yonetmelikler) {
    try {
      final str = await rootBundle.loadString(_basePath + entry.path);
      final json = jsonDecode(str) as Map<String, dynamic>;
      final lawName = json['law'] as String? ?? entry.name;
      final articles = (json['articles'] as List<dynamic>?) ?? [];
      for (final a in articles) {
        final art = MevzuatArticle.fromJson(
          a as Map<String, dynamic>,
          lawName,
          category: 'yonetmelik',
        );
        final id = art.id.isEmpty
            ? '${entry.id}-${art.article.replaceAll(RegExp(r'\s'), '')}'
            : art.id;
        all.add(MevzuatArticle(
          id: id,
          law: lawName,
          article: art.article,
          title: art.title,
          text: art.text,
          source: art.source,
          category: 'yonetmelik',
        ));
      }
    } catch (_) {}
  }

  return all;
});

final mevzuatSearchQueryProvider = StateProvider<String>((ref) => '');
final mevzuatSearchTabProvider = StateProvider<MevzuatTab>((ref) => MevzuatTab.kanunlar);

enum MevzuatTab { kanunlar, yonetmelikler, favoriler }

final mevzuatFavoritesVersionProvider = StateProvider<int>((ref) => 0);

final mevzuatFavoritesProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(mevzuatFavoritesVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_favoritesKey);
  return (list ?? []).toSet();
});

Future<void> mevzuatToggleFavorite(Ref ref, String articleId) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_favoritesKey) ?? [];
  final set = list.toSet();
  if (set.contains(articleId)) {
    set.remove(articleId);
  } else {
    set.add(articleId);
  }
  await prefs.setStringList(_favoritesKey, set.toList());
  ref.read(mevzuatFavoritesVersionProvider.notifier).state++;
}

final mevzuatSearchResultsProvider =
    FutureProvider.autoDispose<List<MevzuatArticle>>((ref) async {
  final query = ref.watch(mevzuatSearchQueryProvider).trim().toLowerCase();
  final tab = ref.watch(mevzuatSearchTabProvider);
  final all = await ref.watch(mevzuatAllArticlesProvider.future);
  final favorites = await ref.watch(mevzuatFavoritesProvider.future);

  List<MevzuatArticle> filtered = all;

  if (tab == MevzuatTab.kanunlar) {
    filtered = filtered.where((a) => a.category == 'kanun').toList();
  } else if (tab == MevzuatTab.yonetmelikler) {
    filtered = filtered.where((a) => a.category == 'yonetmelik').toList();
  } else if (tab == MevzuatTab.favoriler) {
    filtered = filtered.where((a) => favorites.contains(a.id)).toList();
  }

  if (query.isEmpty) return filtered;

  final number = int.tryParse(query);
  return filtered.where((a) {
    if (number != null) {
      final artNum = a.article.replaceAll(RegExp(r'[^\d]'), '');
      if (artNum.isNotEmpty && int.tryParse(artNum) == number) return true;
    }
    return a.law.toLowerCase().contains(query) ||
        a.article.toLowerCase().contains(query) ||
        a.title.toLowerCase().contains(query) ||
        a.text.toLowerCase().contains(query);
  }).toList();
});
