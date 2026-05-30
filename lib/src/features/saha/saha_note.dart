class SahaNote {
  const SahaNote({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.body,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.tags = const [],
  });

  final String id;
  final String categoryId;
  final String title;
  final String body;
  final int createdAtMs;
  final int updatedAtMs;

  /// Serbest etiketler (Araç/Şahıs/Adres/Olay vb.). Geriye dönük uyumlu.
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'title': title,
        'body': body,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'tags': tags,
      };

  factory SahaNote.fromJson(Map<String, dynamic> j) {
    final rawTags = j['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];
    return SahaNote(
      id: j['id'] as String? ?? '',
      categoryId: j['categoryId'] as String? ?? '',
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (j['updatedAtMs'] as num?)?.toInt() ?? 0,
      tags: tags,
    );
  }

  SahaNote copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? body,
    int? createdAtMs,
    int? updatedAtMs,
    List<String>? tags,
  }) {
    return SahaNote(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      tags: tags ?? this.tags,
    );
  }
}

/// Saha kayıtlarında kullanılabilen standart etiketler.
class SahaTag {
  const SahaTag({required this.id, required this.label});

  final String id;
  final String label;

  static const List<SahaTag> all = [
    SahaTag(id: 'arac', label: 'Araç'),
    SahaTag(id: 'sahis', label: 'Şahıs'),
    SahaTag(id: 'adres', label: 'Adres'),
    SahaTag(id: 'olay', label: 'Olay'),
  ];

  static String labelOf(String id) {
    for (final t in all) {
      if (t.id == id) return t.label;
    }
    return id;
  }
}
