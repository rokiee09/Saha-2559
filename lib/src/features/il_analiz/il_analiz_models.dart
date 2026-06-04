/// İl analiz ve tayin karar destek — veri modelleri.
/// Boş alanlar null kalır; uygulama uydurma değer basmaz.

int? _jsonInt(dynamic v) => v == null ? null : (v as num).toInt();

bool? _jsonBool(dynamic v) => v is bool ? v : null;

String? _jsonStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class IlAnalizPuanlar {
  const IlAnalizPuanlar({
    this.polisYasam,
    this.aile,
    this.bekar,
    this.emeklilik,
  });

  final int? polisYasam;
  final int? aile;
  final int? bekar;
  final int? emeklilik;

  bool get bos =>
      polisYasam == null &&
      aile == null &&
      bekar == null &&
      emeklilik == null;

  factory IlAnalizPuanlar.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizPuanlar();
    return IlAnalizPuanlar(
      polisYasam: _jsonInt(j['polisYasam']),
      aile: _jsonInt(j['aile']),
      bekar: _jsonInt(j['bekar']),
      emeklilik: _jsonInt(j['emeklilik']),
    );
  }
}

class IlAnalizGenel {
  const IlAnalizGenel({
    this.nufus,
    this.yuzolcumuKm2,
    this.ilceSayisi,
    this.rakimM,
    this.kalkinmadaOncelikli,
    this.yasamIndeksiSira,
    this.yasamIndeksiYil,
    this.kaynak,
  });

  final int? nufus;
  final int? yuzolcumuKm2;
  final int? ilceSayisi;
  final int? rakimM;
  final bool? kalkinmadaOncelikli;
  /// TÜİK İllerde Yaşam Endeksi bileşik sırası (1 = en iyi).
  final int? yasamIndeksiSira;
  final int? yasamIndeksiYil;
  final String? kaynak;

  factory IlAnalizGenel.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizGenel();
    return IlAnalizGenel(
      nufus: _jsonInt(j['nufus']),
      yuzolcumuKm2: _jsonInt(j['yuzolcumuKm2']),
      ilceSayisi: _jsonInt(j['ilceSayisi']),
      rakimM: _jsonInt(j['rakimM']),
      kalkinmadaOncelikli: _jsonBool(j['kalkinmadaOncelikli']),
      yasamIndeksiSira: _jsonInt(j['yasamIndeksiSira']),
      yasamIndeksiYil: _jsonInt(j['yasamIndeksiYil']),
      kaynak: _jsonStr(j['kaynak']),
    );
  }
}

class IlAnalizEkonomi {
  const IlAnalizEkonomi({
    this.ortalamaKiraTl,
    this.konutSatisOrtTl,
    this.segeDuzey,
    this.sosyoekonomikSira,
    this.kaynak,
  });

  final int? ortalamaKiraTl;
  final int? konutSatisOrtTl;
  final String? segeDuzey;
  final int? sosyoekonomikSira;
  final String? kaynak;

  factory IlAnalizEkonomi.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizEkonomi();
    return IlAnalizEkonomi(
      ortalamaKiraTl: _jsonInt(j['ortalamaKiraTl']),
      konutSatisOrtTl: _jsonInt(j['konutSatisOrtTl']),
      segeDuzey: _jsonStr(j['segeDuzey']),
      sosyoekonomikSira: _jsonInt(j['sosyoekonomikSira']),
      kaynak: _jsonStr(j['kaynak']),
    );
  }
}

class IlAnalizSaglik {
  const IlAnalizSaglik({
    this.devletHastanesi,
    this.egitimArastirma,
    this.universiteHastanesi,
    this.sehirHastanesi,
    this.ozelHastane,
    this.kaynak,
  });

  final int? devletHastanesi;
  final int? egitimArastirma;
  final int? universiteHastanesi;
  final bool? sehirHastanesi;
  final int? ozelHastane;
  final String? kaynak;

  factory IlAnalizSaglik.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizSaglik();
    return IlAnalizSaglik(
      devletHastanesi: _jsonInt(j['devletHastanesi']),
      egitimArastirma: _jsonInt(j['egitimArastirma']),
      universiteHastanesi: _jsonInt(j['universiteHastanesi']),
      sehirHastanesi: _jsonBool(j['sehirHastanesi']),
      ozelHastane: _jsonInt(j['ozelHastane']),
      kaynak: _jsonStr(j['kaynak']),
    );
  }
}

class IlAnalizEgitim {
  const IlAnalizEgitim({
    this.universite,
    this.fenLisesi,
    this.anadoluLisesi,
    this.meslekLisesi,
    this.ozelOkul,
    this.kaynak,
  });

  final int? universite;
  final int? fenLisesi;
  final int? anadoluLisesi;
  final int? meslekLisesi;
  final int? ozelOkul;
  final String? kaynak;

  factory IlAnalizEgitim.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizEgitim();
    return IlAnalizEgitim(
      universite: _jsonInt(j['universite']),
      fenLisesi: _jsonInt(j['fenLisesi']),
      anadoluLisesi: _jsonInt(j['anadoluLisesi']),
      meslekLisesi: _jsonInt(j['meslekLisesi']),
      ozelOkul: _jsonInt(j['ozelOkul']),
      kaynak: _jsonStr(j['kaynak']),
    );
  }
}

class IlAnalizSosyal {
  const IlAnalizSosyal({
    this.avm,
    this.havalimani,
    this.superLigTakimi,
    this.sinema,
    this.tiyatro,
    this.sporTesisleri,
    this.sahil,
    this.turizm,
  });

  final int? avm;
  final int? havalimani;
  final bool? superLigTakimi;
  final int? sinema;
  final int? tiyatro;
  final int? sporTesisleri;
  final String? sahil;
  final String? turizm;

  factory IlAnalizSosyal.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizSosyal();
    return IlAnalizSosyal(
      avm: _jsonInt(j['avm']),
      havalimani: _jsonInt(j['havalimani']),
      superLigTakimi: _jsonBool(j['superLigTakimi']),
      sinema: _jsonInt(j['sinema']),
      tiyatro: _jsonInt(j['tiyatro']),
      sporTesisleri: _jsonInt(j['sporTesisleri']),
      sahil: _jsonStr(j['sahil']),
      turizm: _jsonStr(j['turizm']),
    );
  }
}

/// Polis360 "Görev bilgileri" + çalışma/lojman alanları.
class IlAnalizPolis {
  const IlAnalizPolis({
    this.gorevPuani,
    this.gorevSuresiYil,
    this.mudurluk,
    this.amirlik,
    this.ekTazminatTl,
    this.tazminatDerece,
    this.lojmanSayisi,
    this.lojmanDurumu,
    this.lojmanBeklemeYil,
    this.calismaSistemi,
    this.mesai,
    this.anons,
    this.uygulama,
    this.isYuku,
    this.sucTuru,
    this.kaynak,
  });

  final int? gorevPuani;
  final int? gorevSuresiYil;
  final int? mudurluk;
  final int? amirlik;
  final int? ekTazminatTl;
  final int? tazminatDerece;
  final int? lojmanSayisi;
  final String? lojmanDurumu;
  final String? lojmanBeklemeYil;
  final String? calismaSistemi;
  final String? mesai;
  final String? anons;
  final String? uygulama;
  final String? isYuku;
  final String? sucTuru;
  final String? kaynak;

  factory IlAnalizPolis.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizPolis();
    return IlAnalizPolis(
      gorevPuani: _jsonInt(j['gorevPuani']),
      gorevSuresiYil: _jsonInt(j['gorevSuresiYil']),
      mudurluk: _jsonInt(j['mudurluk']),
      amirlik: _jsonInt(j['amirlik']),
      ekTazminatTl: _jsonInt(j['ekTazminatTl']),
      tazminatDerece: _jsonInt(j['tazminatDerece']),
      lojmanSayisi: _jsonInt(j['lojmanSayisi']),
      lojmanDurumu: _jsonStr(j['lojmanDurumu']),
      lojmanBeklemeYil: _jsonStr(j['lojmanBeklemeYil']),
      calismaSistemi: _jsonStr(j['calismaSistemi']),
      mesai: _jsonStr(j['mesai']),
      anons: _jsonStr(j['anons']),
      uygulama: _jsonStr(j['uygulama']),
      isYuku: _jsonStr(j['isYuku']),
      sucTuru: _jsonStr(j['sucTuru']),
      kaynak: _jsonStr(j['kaynak']),
    );
  }
}

class IlGuvenlikGosterge {
  const IlGuvenlikGosterge({
    required this.etiket,
    required this.deger,
    this.egilim,
  });

  final String etiket;
  final String deger;
  final String? egilim;

  factory IlGuvenlikGosterge.fromJson(Map<String, dynamic> j) {
    return IlGuvenlikGosterge(
      etiket: _jsonStr(j['etiket']) ?? '',
      deger: _jsonStr(j['deger']) ?? '',
      egilim: _jsonStr(j['egilim']),
    );
  }

  bool get gecerli => etiket.isNotEmpty && deger.isNotEmpty;
}

class IlAnalizGuvenlik {
  const IlAnalizGuvenlik({
    this.gostergeler = const [],
    this.dipnot,
  });

  final List<IlGuvenlikGosterge> gostergeler;
  final String? dipnot;

  factory IlAnalizGuvenlik.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlAnalizGuvenlik();
    final list = (j['gostergeler'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(IlGuvenlikGosterge.fromJson)
        .where((g) => g.gecerli)
        .toList();
    return IlAnalizGuvenlik(
      gostergeler: list,
      dipnot: _jsonStr(j['dipnot']),
    );
  }
}

class IlceAnaliz {
  const IlceAnaliz({
    required this.ad,
    this.nufus,
    this.kiraTl,
    this.yasam,
    this.sosyal,
    this.isYuku,
    this.aile,
    this.gorevYil,
    this.yogunluk,
    this.uygulama,
    this.profil,
  });

  final String ad;
  final int? nufus;
  final int? kiraTl;
  final int? yasam;
  final int? sosyal;
  final int? isYuku;
  final int? aile;
  final int? gorevYil;
  final String? yogunluk;
  final String? uygulama;
  final String? profil;

  factory IlceAnaliz.fromJson(Map<String, dynamic> j) {
    return IlceAnaliz(
      ad: _jsonStr(j['ad']) ?? '',
      nufus: _jsonInt(j['nufus']),
      kiraTl: _jsonInt(j['kiraTl']),
      yasam: _jsonInt(j['yasam']),
      sosyal: _jsonInt(j['sosyal']),
      isYuku: _jsonInt(j['isYuku']),
      aile: _jsonInt(j['aile']),
      gorevYil: _jsonInt(j['gorevYil']),
      yogunluk: _jsonStr(j['yogunluk']),
      uygulama: _jsonStr(j['uygulama']),
      profil: _jsonStr(j['profil']),
    );
  }
}

class IlAnalizProfil {
  const IlAnalizProfil({
    required this.id,
    required this.ad,
    required this.plaka,
    this.detayliProfil = false,
    this.bolge,
    this.buyuksehir,
    required this.puanlar,
    required this.genel,
    required this.ekonomi,
    required this.saglik,
    required this.egitim,
    required this.sosyal,
    required this.polis,
    required this.guvenlik,
    this.ozetAi,
    required this.ilceler,
  });

  final String id;
  final String ad;
  final String plaka;
  final bool detayliProfil;
  final String? bolge;
  final bool? buyuksehir;
  final IlAnalizPuanlar puanlar;
  final IlAnalizGenel genel;
  final IlAnalizEkonomi ekonomi;
  final IlAnalizSaglik saglik;
  final IlAnalizEgitim egitim;
  final IlAnalizSosyal sosyal;
  final IlAnalizPolis polis;
  final IlAnalizGuvenlik guvenlik;
  final String? ozetAi;
  final List<IlceAnaliz> ilceler;

  factory IlAnalizProfil.fromJson(Map<String, dynamic> j) {
    return IlAnalizProfil(
      id: _jsonStr(j['id']) ?? '',
      ad: _jsonStr(j['ad']) ?? '',
      plaka: _jsonStr(j['plaka']) ?? '',
      detayliProfil: true,
      bolge: _jsonStr(j['bolge']),
      buyuksehir: _jsonBool(j['buyuksehir']),
      puanlar: IlAnalizPuanlar.fromJson(
        j['puanlar'] as Map<String, dynamic>?,
      ),
      genel: IlAnalizGenel.fromJson(j['genel'] as Map<String, dynamic>?),
      ekonomi:
          IlAnalizEkonomi.fromJson(j['ekonomi'] as Map<String, dynamic>?),
      saglik: IlAnalizSaglik.fromJson(j['saglik'] as Map<String, dynamic>?),
      egitim: IlAnalizEgitim.fromJson(j['egitim'] as Map<String, dynamic>?),
      sosyal: IlAnalizSosyal.fromJson(j['sosyal'] as Map<String, dynamic>?),
      polis: IlAnalizPolis.fromJson(j['polis'] as Map<String, dynamic>?),
      guvenlik:
          IlAnalizGuvenlik.fromJson(j['guvenlik'] as Map<String, dynamic>?),
      ozetAi: _jsonStr(j['ozetAi']),
      ilceler: (j['ilceler'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(IlceAnaliz.fromJson)
          .where((i) => i.ad.isNotEmpty)
          .toList(),
    );
  }
}

class IlAnalizOzet {
  const IlAnalizOzet({
    required this.id,
    required this.ad,
    required this.plaka,
    this.profil,
  });

  final String id;
  final String ad;
  final String plaka;
  final IlAnalizProfil? profil;

  bool get hazir => profil?.detayliProfil ?? false;

  bool get polisOzetiVar =>
      profil != null &&
      (profil!.polis.gorevPuani != null ||
          profil!.polis.tazminatDerece != null ||
          (profil!.polis.ekTazminatTl != null && profil!.polis.ekTazminatTl! > 0));
}
