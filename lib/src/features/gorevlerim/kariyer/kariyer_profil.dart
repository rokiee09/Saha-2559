import 'kariyer_constants.dart';

/// Personel profili — cihazda saklanır; resmî özlük kaydı değildir.
class KariyerProfil {
  const KariyerProfil({
    this.adSoyad = '',
    this.sicil = '',
    this.rutbeId = '',
    this.birim = '',
    this.il = '',
    this.gorevBaslamaMs = 0,
    this.egitimId = '',
    this.gazi = false,
  });

  final String adSoyad;
  final String sicil;
  final String rutbeId;
  final String birim;
  final String il;
  final int gorevBaslamaMs;
  final String egitimId;
  final bool gazi;

  KariyerRutbe? get rutbe => KariyerRutbe.byId(rutbeId);
  EgitimDurumu? get egitim => EgitimDurumuX.fromId(egitimId);

  int get hizmetYili {
    if (gorevBaslamaMs <= 0) return 0;
    final bas = DateTime.fromMillisecondsSinceEpoch(gorevBaslamaMs);
    final y = DateTime.now().year - bas.year;
    if (DateTime.now().isBefore(
        DateTime(DateTime.now().year, bas.month, bas.day))) {
      return y > 0 ? y - 1 : 0;
    }
    return y < 0 ? 0 : y;
  }

  bool get hasOzet =>
      adSoyad.isNotEmpty || rutbe != null || birim.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'adSoyad': adSoyad,
        'sicil': sicil,
        'rutbeId': rutbeId,
        'birim': birim,
        'il': il,
        'gorevBaslamaMs': gorevBaslamaMs,
        'egitimId': egitimId,
        'gazi': gazi,
      };

  factory KariyerProfil.fromJson(Map<String, dynamic> j) => KariyerProfil(
        adSoyad: j['adSoyad'] as String? ?? '',
        sicil: j['sicil'] as String? ?? '',
        rutbeId: j['rutbeId'] as String? ?? '',
        birim: j['birim'] as String? ?? '',
        il: j['il'] as String? ?? '',
        gorevBaslamaMs: (j['gorevBaslamaMs'] as num?)?.toInt() ?? 0,
        egitimId: j['egitimId'] as String? ?? '',
        gazi: j['gazi'] as bool? ?? false,
      );

  /// Eski kariyer_profil_v1 (branş/sicil/yıl) alanlarından taşıma.
  factory KariyerProfil.fromLegacyV1(Map<String, dynamic> j) => KariyerProfil(
        sicil: j['sicil'] as String? ?? '',
        birim: j['brans'] as String? ?? '',
        gorevBaslamaMs: ((j['baslamaYili'] as num?)?.toInt() ?? 0) > 0
            ? DateTime((j['baslamaYili'] as num).toInt()).millisecondsSinceEpoch
            : 0,
      );

  KariyerProfil copyWith({
    String? adSoyad,
    String? sicil,
    String? rutbeId,
    String? birim,
    String? il,
    int? gorevBaslamaMs,
    String? egitimId,
    bool? gazi,
  }) {
    return KariyerProfil(
      adSoyad: adSoyad ?? this.adSoyad,
      sicil: sicil ?? this.sicil,
      rutbeId: rutbeId ?? this.rutbeId,
      birim: birim ?? this.birim,
      il: il ?? this.il,
      gorevBaslamaMs: gorevBaslamaMs ?? this.gorevBaslamaMs,
      egitimId: egitimId ?? this.egitimId,
      gazi: gazi ?? this.gazi,
    );
  }
}
