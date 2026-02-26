import 'package:isar/isar.dart';

part 'law_article.g.dart';

@collection
class LawArticle {
  Id id = Isar.autoIncrement;

  late String lawCode; // Örn: PVSK
  late String lawName;
  late int articleNumber;

  late String officialText;
  late String plainSummary;
  String? fieldExample;
  String? commonMistakes;

  List<int> relatedArticleIds = [];

  String? sourceUrl;
  DateTime? lastUpdated;

  bool isFavorite = false;
  String? userNote;
  DateTime? lastViewedAt;
}

