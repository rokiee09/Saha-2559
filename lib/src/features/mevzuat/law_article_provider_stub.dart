import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';

final lawArticleProvider =
    FutureProvider.family<LawArticle?, int>((ref, id) async => null);
