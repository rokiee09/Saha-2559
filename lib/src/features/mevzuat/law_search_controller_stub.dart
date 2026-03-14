import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';
import 'web_law_articles.dart';

final lawSearchQueryProvider = StateProvider<String>((ref) => '');

final lawSearchResultsProvider =
    FutureProvider.autoDispose<List<LawArticle>>((ref) async {
  final articles = await ref.watch(webLawArticlesProvider.future);
  final query = ref.watch(lawSearchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) {
    return articles;
  }

  final number = int.tryParse(query);
  return articles.where((a) {
    if (number != null && a.articleNumber == number) return true;
    return a.lawName.toLowerCase().contains(query) ||
        a.officialText.toLowerCase().contains(query) ||
        a.plainSummary.toLowerCase().contains(query);
  }).toList();
});

Future<void> markArticleViewed(LawArticle article) async {
  article.lastViewedAt = DateTime.now();
}

Future<void> toggleFavorite(LawArticle article) async {
  article.isFavorite = !article.isFavorite;
}

Future<void> updateNote(LawArticle article, String? note) async {
  article.userNote = (note?.trim().isEmpty ?? true) ? null : note?.trim();
}
