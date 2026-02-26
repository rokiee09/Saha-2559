import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../db/isar_service.dart';
import '../models/law_article.dart';

class LawRepository {
  Future<void> importFromJsonString(String jsonStr) async {
    if (kIsWeb) return;
    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;

    final articles = raw.map((e) {
      final map = e as Map<String, dynamic>;
      final article = LawArticle()
        ..lawCode = map['lawCode'] as String
        ..lawName = map['lawName'] as String
        ..articleNumber = map['articleNumber'] as int
        ..officialText = map['official_text'] as String
        ..plainSummary = map['plain_summary'] as String
        ..fieldExample = map['field_example'] as String?
        ..commonMistakes = map['common_mistakes'] as String?
        ..sourceUrl = map['source_url'] as String?;

      final relatedRaw = map['related'];
      if (relatedRaw is List) {
        article.relatedArticleIds =
            relatedRaw.map((e) => e as int).toList(growable: false);
      }

      final lastUpdatedRaw = map['last_updated'];
      if (lastUpdatedRaw is String && lastUpdatedRaw.isNotEmpty) {
        article.lastUpdated = DateTime.tryParse(lastUpdatedRaw);
      }

      return article;
    }).toList(growable: false);

    final isar = IsarService.db;
    await isar.writeTxn(() async {
      await isar.lawArticles.putAll(articles);
    });
  }
}

