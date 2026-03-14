import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';

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

final lawsGroupedProvider = FutureProvider<List<LawSummary>>((ref) async => []);

final articlesByLawCodeProvider =
    FutureProvider.family<List<LawArticle>, String>((ref, lawCode) async => []);

Future<void> saveLawArticle(LawArticle article) async {}

Future<void> deleteLawArticle(LawArticle article) async {}
