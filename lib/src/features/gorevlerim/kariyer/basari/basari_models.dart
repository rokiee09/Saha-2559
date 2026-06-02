enum BasariBelgeTuru { basari, ustunBasari }

extension BasariBelgeTuruX on BasariBelgeTuru {
  String get id => name;

  String get label => switch (this) {
        BasariBelgeTuru.basari => 'Başarı Belgesi',
        BasariBelgeTuru.ustunBasari => 'Üstün Başarı Belgesi',
      };

  static BasariBelgeTuru fromId(String? id) {
    for (final t in BasariBelgeTuru.values) {
      if (t.id == id) return t;
    }
    return BasariBelgeTuru.basari;
  }
}

class BasariBelge {
  const BasariBelge({
    required this.id,
    required this.tur,
    required this.tarihMs,
    required this.verenMakam,
    required this.aciklama,
    required this.createdAtMs,
    this.fotoPath = '',
    this.pdfPath = '',
  });

  final String id;
  final BasariBelgeTuru tur;
  final int tarihMs;
  final String verenMakam;
  final String aciklama;
  final String fotoPath;
  final String pdfPath;
  final int createdAtMs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tur': tur.id,
        'tarihMs': tarihMs,
        'verenMakam': verenMakam,
        'aciklama': aciklama,
        'fotoPath': fotoPath,
        'pdfPath': pdfPath,
        'createdAtMs': createdAtMs,
      };

  factory BasariBelge.fromJson(Map<String, dynamic> j) => BasariBelge(
        id: j['id'] as String? ?? '',
        tur: BasariBelgeTuruX.fromId(j['tur'] as String?),
        tarihMs: (j['tarihMs'] as num?)?.toInt() ?? 0,
        verenMakam: j['verenMakam'] as String? ?? '',
        aciklama: j['aciklama'] as String? ?? '',
        fotoPath: j['fotoPath'] as String? ?? '',
        pdfPath: j['pdfPath'] as String? ?? '',
        createdAtMs: (j['createdAtMs'] as num?)?.toInt() ?? 0,
      );
}

class BasariHesap {
  const BasariHesap({
    required this.basariSayisi,
    required this.ustunSayisi,
    required this.hakEdilenUstun,
    required this.sonrakiUstunIcinKalan,
  });

  final int basariSayisi;
  final int ustunSayisi;
  final int hakEdilenUstun;
  final int sonrakiUstunIcinKalan;
}

BasariHesap hesaplaBasari(List<BasariBelge> belgeler) {
  final basari = belgeler.where((b) => b.tur == BasariBelgeTuru.basari).length;
  final ustun =
      belgeler.where((b) => b.tur == BasariBelgeTuru.ustunBasari).length;
  final mod = basari % 3;
  final kalan = mod == 0 ? 3 : 3 - mod;
  return BasariHesap(
    basariSayisi: basari,
    ustunSayisi: ustun,
    hakEdilenUstun: basari ~/ 3,
    sonrakiUstunIcinKalan: kalan,
  );
}
