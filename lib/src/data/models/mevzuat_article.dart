/// JSON tabanlı mevzuat maddesi (mevzuat.gov.tr referanslı).
class MevzuatArticle {
  final String id;
  final String law;
  final String article;
  final String title;
  final String text;
  final String source;
  /// 'kanun' veya 'yonetmelik'
  final String category;

  const MevzuatArticle({
    required this.id,
    required this.law,
    required this.article,
    required this.title,
    required this.text,
    required this.source,
    this.category = 'kanun',
  });

  factory MevzuatArticle.fromJson(
    Map<String, dynamic> json,
    String lawName, {
    String category = 'kanun',
  }) {
    return MevzuatArticle(
      id: json['id'] as String? ?? '',
      law: lawName,
      article: json['article'] as String? ?? '',
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      source: json['source'] as String? ?? 'mevzuat.gov.tr',
      category: category,
    );
  }

  String get displaySubtitle => '$law - $article';
}
