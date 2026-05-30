/// O-1 gider kaydı. Yalnızca bu cihazda saklanır; fiş görüntüleri uygulamanın
/// özel klasöründe tutulur ve buluta gönderilmez.
class GiderKayit {
  const GiderKayit({
    required this.id,
    required this.baslik,
    required this.tutar,
    required this.tarihMs,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.kategori = '',
    this.not = '',
    this.fisPaths = const [],
  });

  final String id;
  final String baslik;

  /// TL cinsinden tutar; girilmemişse 0.
  final double tutar;

  /// Gider tarihi (epoch ms).
  final int tarihMs;
  final int createdAtMs;
  final int updatedAtMs;

  /// Serbest kategori etiketi (yakıt, yemek, konaklama vb.).
  final String kategori;
  final String not;

  /// Cihazdaki fiş görüntülerinin tam yolları.
  final List<String> fisPaths;

  Map<String, dynamic> toJson() => {
        'id': id,
        'baslik': baslik,
        'tutar': tutar,
        'tarihMs': tarihMs,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'kategori': kategori,
        'not': not,
        'fisPaths': fisPaths,
      };

  factory GiderKayit.fromJson(Map<String, dynamic> j) {
    final rawFis = j['fisPaths'];
    final fis = rawFis is List
        ? rawFis.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];
    return GiderKayit(
      id: j['id'] as String? ?? '',
      baslik: j['baslik'] as String? ?? '',
      tutar: (j['tutar'] as num?)?.toDouble() ?? 0,
      tarihMs: (j['tarihMs'] as num?)?.toInt() ??
          (j['createdAtMs'] as num?)?.toInt() ??
          0,
      createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (j['updatedAtMs'] as num?)?.toInt() ?? 0,
      kategori: j['kategori'] as String? ?? '',
      not: j['not'] as String? ?? '',
      fisPaths: fis,
    );
  }

  GiderKayit copyWith({
    String? baslik,
    double? tutar,
    int? tarihMs,
    int? updatedAtMs,
    String? kategori,
    String? not,
    List<String>? fisPaths,
  }) {
    return GiderKayit(
      id: id,
      baslik: baslik ?? this.baslik,
      tutar: tutar ?? this.tutar,
      tarihMs: tarihMs ?? this.tarihMs,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      kategori: kategori ?? this.kategori,
      not: not ?? this.not,
      fisPaths: fisPaths ?? this.fisPaths,
    );
  }
}
