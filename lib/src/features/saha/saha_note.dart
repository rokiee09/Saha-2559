class SahaNote {
  const SahaNote({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.body,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String categoryId;
  final String title;
  final String body;
  final int createdAtMs;
  final int updatedAtMs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'title': title,
        'body': body,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  factory SahaNote.fromJson(Map<String, dynamic> j) {
    return SahaNote(
      id: j['id'] as String? ?? '',
      categoryId: j['categoryId'] as String? ?? '',
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (j['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  SahaNote copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? body,
    int? createdAtMs,
    int? updatedAtMs,
  }) {
    return SahaNote(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}
