import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';
import 'web_law_articles.dart';

final lawArticleProvider =
    FutureProvider.family<LawArticle?, int>((ref, id) async {
  final articles = await ref.watch(webLawArticlesProvider.future);
  try {
    return articles.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});
