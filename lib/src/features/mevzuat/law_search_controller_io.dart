import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/law_article.dart';

final lawSearchQueryProvider = StateProvider<String>((ref) => '');

final lawSearchResultsProvider =
    FutureProvider.autoDispose<List<LawArticle>>((ref) async {
  final query = ref.watch(lawSearchQueryProvider).trim();
  final isar = IsarService.db;

  if (query.isEmpty) {
    return isar.lawArticles
        .where()
        .sortByLastViewedAtDesc()
        .limit(20)
        .findAll();
  }

  final lower = query.toLowerCase();
  final number = int.tryParse(lower);

  final q = isar.lawArticles.filter();

  if (number != null) {
    q.articleNumberEqualTo(number);
  }

  return q
      .or()
      .lawNameContains(lower, caseSensitive: false)
      .or()
      .officialTextContains(lower, caseSensitive: false)
      .or()
      .plainSummaryContains(lower, caseSensitive: false)
      .findAll();
});

Future<void> markArticleViewed(LawArticle article) async {
  final isar = IsarService.db;
  await isar.writeTxn(() async {
    article.lastViewedAt = DateTime.now();
    await isar.lawArticles.put(article);
  });
}

Future<void> toggleFavorite(LawArticle article) async {
  final isar = IsarService.db;
  await isar.writeTxn(() async {
    article.isFavorite = !article.isFavorite;
    await isar.lawArticles.put(article);
  });
}

Future<void> updateNote(LawArticle article, String? note) async {
  final isar = IsarService.db;
  await isar.writeTxn(() async {
    article.userNote = (note?.trim().isEmpty ?? true) ? null : note?.trim();
    await isar.lawArticles.put(article);
  });
}
