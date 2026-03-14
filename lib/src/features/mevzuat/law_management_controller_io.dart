import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/law_article.dart';

/// Kanun özeti: kod, ad, madde sayısı
class LawSummary {
  final String lawCode;
  final String lawName;
  final int count;

  LawSummary({
    required this.lawCode,
    required this.lawName,
    required this.count,
  });
}

/// Tüm kanunları madde sayılarıyla listeler (gruplu)
final lawsGroupedProvider = FutureProvider<List<LawSummary>>((ref) async {
  final isar = IsarService.db;
  final all = await isar.lawArticles.where().findAll();
  final map = <String, LawSummary>{};
  for (final a in all) {
    final key = '${a.lawCode}|${a.lawName}';
    if (map.containsKey(key)) {
      map[key] = LawSummary(
        lawCode: map[key]!.lawCode,
        lawName: map[key]!.lawName,
        count: map[key]!.count + 1,
      );
    } else {
      map[key] = LawSummary(lawCode: a.lawCode, lawName: a.lawName, count: 1);
    }
  }
  return map.values.toList()..sort((a, b) => a.lawName.compareTo(b.lawName));
});

/// Belirli bir kanuna ait maddeleri getirir
final articlesByLawCodeProvider =
    FutureProvider.family<List<LawArticle>, String>((ref, lawCode) async {
  final isar = IsarService.db;
  return isar.lawArticles
      .filter()
      .lawCodeEqualTo(lawCode)
      .sortByArticleNumber()
      .findAll();
});

Future<void> saveLawArticle(LawArticle article) async {
  final isar = IsarService.db;
  await isar.writeTxn(() async {
    article.lastUpdated = DateTime.now();
    await isar.lawArticles.put(article);
  });
}

Future<void> deleteLawArticle(LawArticle article) async {
  final isar = IsarService.db;
  await isar.writeTxn(() async {
    await isar.lawArticles.delete(article.id);
  });
}
