import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';

final lawSearchQueryProvider = StateProvider<String>((ref) => '');

final lawSearchResultsProvider =
    FutureProvider.autoDispose<List<LawArticle>>((ref) async => []);

Future<void> markArticleViewed(LawArticle article) async {}

Future<void> toggleFavorite(LawArticle article) async {}

Future<void> updateNote(LawArticle article, String? note) async {}
