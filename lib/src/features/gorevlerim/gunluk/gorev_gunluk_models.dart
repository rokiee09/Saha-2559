/// Görev günlüğü kaydı — yalnızca cihazda saklanır.
class GorevGunlukKayit {
  const GorevGunlukKayit({
    required this.id,
    required this.tarihMs,
    required this.saat,
    required this.gorevAdi,
    required this.sureSaat,
    required this.not,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.il = '',
    this.ilce = '',
    this.fotoPaths = const [],
  });

  final String id;
  final int tarihMs;
  final String saat;
  final String gorevAdi;
  final double sureSaat;
  final String not;
  final String il;
  final String ilce;
  final List<String> fotoPaths;
  final int createdAtMs;
  final int updatedAtMs;

  DateTime get tarih => DateTime.fromMillisecondsSinceEpoch(tarihMs);

  Map<String, dynamic> toJson() => {
        'id': id,
        'tarihMs': tarihMs,
        'saat': saat,
        'gorevAdi': gorevAdi,
        'sureSaat': sureSaat,
        'not': not,
        'il': il,
        'ilce': ilce,
        'fotoPaths': fotoPaths,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  factory GorevGunlukKayit.fromJson(Map<String, dynamic> j) {
    final raw = j['fotoPaths'];
    final fotos = raw is List
        ? raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    return GorevGunlukKayit(
      id: j['id'] as String? ?? '',
      tarihMs: (j['tarihMs'] as num?)?.toInt() ?? 0,
      saat: j['saat'] as String? ?? '',
      gorevAdi: j['gorevAdi'] as String? ?? '',
      sureSaat: (j['sureSaat'] as num?)?.toDouble() ?? 0,
      not: j['not'] as String? ?? '',
      il: j['il'] as String? ?? '',
      ilce: j['ilce'] as String? ?? '',
      fotoPaths: fotos,
      createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (j['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  GorevGunlukKayit copyWith({
    int? tarihMs,
    String? saat,
    String? gorevAdi,
    double? sureSaat,
    String? not,
    String? il,
    String? ilce,
    List<String>? fotoPaths,
    int? updatedAtMs,
  }) {
    return GorevGunlukKayit(
      id: id,
      tarihMs: tarihMs ?? this.tarihMs,
      saat: saat ?? this.saat,
      gorevAdi: gorevAdi ?? this.gorevAdi,
      sureSaat: sureSaat ?? this.sureSaat,
      not: not ?? this.not,
      il: il ?? this.il,
      ilce: ilce ?? this.ilce,
      fotoPaths: fotoPaths ?? this.fotoPaths,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}
