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
    required this.evrakNo,
    required this.aciklama,
    required this.not,
    required this.createdAtMs,
    this.fotoPath = '',
    this.pdfPath = '',
  });

  final String id;
  final BasariBelgeTuru tur;
  final int tarihMs;
  final String verenMakam;
  final String evrakNo;
  final String aciklama;
  final String not;
  final String fotoPath;
  final String pdfPath;
  final int createdAtMs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tur': tur.id,
        'tarihMs': tarihMs,
        'verenMakam': verenMakam,
        'evrakNo': evrakNo,
        'aciklama': aciklama,
        'not': not,
        'fotoPath': fotoPath,
        'pdfPath': pdfPath,
        'createdAtMs': createdAtMs,
      };

  factory BasariBelge.fromJson(Map<String, dynamic> j) => BasariBelge(
        id: j['id'] as String? ?? '',
        tur: BasariBelgeTuruX.fromId(j['tur'] as String?),
        tarihMs: (j['tarihMs'] as num?)?.toInt() ?? 0,
        verenMakam: j['verenMakam'] as String? ?? '',
        evrakNo: j['evrakNo'] as String? ?? '',
        aciklama: j['aciklama'] as String? ?? '',
        not: j['not'] as String? ?? '',
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
    required this.ustunEsikUlasildi,
  });

  final int basariSayisi;
  final int ustunSayisi;
  final int hakEdilenUstun;
  final int sonrakiUstunIcinKalan;
  final bool ustunEsikUlasildi;
}

int sonrakiUstunIcinKalan(int basariSayisi) {
  if (basariSayisi <= 0) return 3;
  final mod = basariSayisi % 3;
  return mod == 0 ? 0 : 3 - mod;
}

bool ustunBasariEsikUlasildi(int basariSayisi) =>
    basariSayisi > 0 && basariSayisi % 3 == 0;

BasariHesap hesaplaBasari(List<BasariBelge> belgeler) {
  final basari = belgeler.where((b) => b.tur == BasariBelgeTuru.basari).length;
  final ustun =
      belgeler.where((b) => b.tur == BasariBelgeTuru.ustunBasari).length;
  return BasariHesap(
    basariSayisi: basari,
    ustunSayisi: ustun,
    hakEdilenUstun: basari ~/ 3,
    sonrakiUstunIcinKalan: sonrakiUstunIcinKalan(basari),
    ustunEsikUlasildi: ustunBasariEsikUlasildi(basari),
  );
}
