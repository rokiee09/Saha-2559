// Web'de liste ve detayın aynı kaynaktan veri alması için tek cache.
// Sadece web (stub) tarafında kullanılır.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';

final webLawArticlesProvider =
    FutureProvider<List<LawArticle>>((ref) async {
  final jsonStr =
      await rootBundle.loadString('assets/json/law_articles.json');
  return _parseLawArticlesFromJson(jsonStr);
});

List<LawArticle> _parseLawArticlesFromJson(String jsonStr) {
  final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
  final list = <LawArticle>[];
  for (var i = 0; i < raw.length; i++) {
    final map = raw[i] as Map<String, dynamic>;
    final article = LawArticle()
      ..id = (i + 1)
      ..lawCode = map['lawCode'] as String
      ..lawName = map['lawName'] as String
      ..articleNumber = map['articleNumber'] as int
      ..officialText = _str(map['official_text'])
      ..plainSummary = _str(map['plain_summary'])
      ..fieldExample = _strOrNull(map['field_example'])
      ..commonMistakes = _strOrNull(map['common_mistakes']);

    final relatedRaw = map['related'];
    if (relatedRaw is List) {
      article.relatedArticleIds =
          relatedRaw.map((e) => e as int).toList(growable: false);
    }

    final lastUpdatedRaw = map['last_updated'];
    if (lastUpdatedRaw is String && lastUpdatedRaw.isNotEmpty) {
      article.lastUpdated = DateTime.tryParse(lastUpdatedRaw);
    }

    article.sourceUrl = map['source_url'] as String?;
    list.add(article);
  }
  return list;
}

String _str(dynamic v) => v is String ? v : (v?.toString() ?? '');

String? _strOrNull(dynamic v) {
  if (v == null) return null;
  final s = v is String ? v : v.toString();
  return s.trim().isEmpty ? null : s;
}
