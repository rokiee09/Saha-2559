import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class MaasDonemData {
  final String id;
  final String etiket;
  final double memurAylikKatsayisi;
  final double tabanAylik;
  final double tahminiNetOrani;
  final String? kaynakNot;

  MaasDonemData({
    required this.id,
    required this.etiket,
    required this.memurAylikKatsayisi,
    required this.tabanAylik,
    required this.tahminiNetOrani,
    this.kaynakNot,
  });

  factory MaasDonemData.fromJson(Map<String, dynamic> j) {
    return MaasDonemData(
      id: j['id'] as String? ?? '',
      etiket: j['etiket'] as String? ?? '',
      memurAylikKatsayisi: (j['memurAylikKatsayisi'] as num?)?.toDouble() ?? 0,
      tabanAylik: (j['tabanAylik'] as num?)?.toDouble() ?? 0,
      tahminiNetOrani: (j['tahminiNetOrani'] as num?)?.toDouble() ?? 0.7,
      kaynakNot: j['kaynakNot'] as String?,
    );
  }
}

class MaasKatsayiFile {
  final String sonGuncelleme;
  final String genelUyari;
  final String formulAciklama;
  final List<MaasDonemData> donemler;
  final String varsayilanDonem;

  MaasKatsayiFile({
    required this.sonGuncelleme,
    required this.genelUyari,
    required this.formulAciklama,
    required this.donemler,
    required this.varsayilanDonem,
  });

  factory MaasKatsayiFile.fromJson(Map<String, dynamic> j) {
    final raw = j['donemler'] as List<dynamic>? ?? [];
    return MaasKatsayiFile(
      sonGuncelleme: j['sonGuncelleme'] as String? ?? '',
      genelUyari: j['genelUyari'] as String? ?? '',
      formulAciklama: j['formulAciklama'] as String? ?? '',
      donemler: raw
          .map((e) => MaasDonemData.fromJson(e as Map<String, dynamic>))
          .toList(),
      varsayilanDonem: j['varsayilanDonem'] as String? ?? '',
    );
  }

  MaasDonemData? donemById(String id) {
    for (final d in donemler) {
      if (d.id == id) return d;
    }
    return null;
  }
}

/// Bordro satırları + tahmini net (tek oran; kesin değil).
class MaasHesapSonucu {
  final double tabanAylik;
  final double gostergeAyligi;
  final double ekGostergeTl;
  final double kidemAyligi;
  final double ozelHizmetTazminati;
  final double dilTazminati;
  final double ekOdeme;
  final double aileYardimi;
  final double cocukYardimi;
  final double brut;
  final double vergiIstisnaEtkisi;
  final double ozelSaglikVergiEtkisi;
  final double raporKesintisi;
  final double sendikaKesintisi;
  final double besKesintisi;
  final double ilksanKesintisi;
  final double kefaletKesintisi;
  final double digerKesintiler;
  final double tahminiKesinti;
  final double tahminiNet;
  final double eldeKalan;

  const MaasHesapSonucu({
    required this.tabanAylik,
    required this.gostergeAyligi,
    required this.ekGostergeTl,
    required this.kidemAyligi,
    required this.ozelHizmetTazminati,
    required this.dilTazminati,
    required this.ekOdeme,
    required this.aileYardimi,
    required this.cocukYardimi,
    required this.brut,
    required this.vergiIstisnaEtkisi,
    required this.ozelSaglikVergiEtkisi,
    required this.raporKesintisi,
    required this.sendikaKesintisi,
    required this.besKesintisi,
    required this.ilksanKesintisi,
    required this.kefaletKesintisi,
    required this.digerKesintiler,
    required this.tahminiKesinti,
    required this.tahminiNet,
    required this.eldeKalan,
  });
}

MaasHesapSonucu hesaplaMaas({
  required MaasDonemData donem,
  required double gostergePuan,
  required double ekGostergeTl,
  double kidemAyligi = 0,
  double ozelHizmetTazminati = 0,
  double dilTazminati = 0,
  double ekOdeme = 0,
  double aileYardimi = 0,
  double cocukYardimi = 0,
  double gvIstisnasi = 0,
  double dvIstisnaMatrahi = 0,
  double ozelSaglikPrimi = 0,
  double gelirVergisiOrani = 0.15,
  double sendikaKesintiOrani = 0,
  double sendikaTabanAylikKesintiOrani = 0,
  double besKesintiOrani = 0,
  double ilksanKesintisi = 0,
  double kefaletKesintisi = 0,
  double raporluGun = 0,
  double digerKesintiler = 0,
  double? tahminiNetOraniOverride,
}) {
  final netOrani = (tahminiNetOraniOverride ?? donem.tahminiNetOrani)
      .clamp(0.0, 1.0);
  final gostergeAyligi = gostergePuan * donem.memurAylikKatsayisi;
  final brut = donem.tabanAylik +
      gostergeAyligi +
      ekGostergeTl +
      kidemAyligi +
      ozelHizmetTazminati +
      dilTazminati +
      ekOdeme +
      aileYardimi +
      cocukYardimi;

  final gvOrani = gelirVergisiOrani.clamp(0.0, 1.0);
  final vergiIstisnaEtkisi =
      (gvIstisnasi * gvOrani) + (dvIstisnaMatrahi * 0.00759);
  final ozelSaglikVergiEtkisi = ozelSaglikPrimi * gvOrani;

  // Raporlu gün MAHEP'teki "7+" alanına karşılık gelir. Kurum bordrosunda
  // farklı işlenebildiği için burada ÖHT üzerinden günlük yaklaşık kesinti
  // olarak gösterilir.
  final raporKesintisi =
      raporluGun <= 0 ? 0.0 : (ozelHizmetTazminati / 30) * raporluGun;
  final sendikaKesintisi = (brut * sendikaKesintiOrani) +
      (donem.tabanAylik * sendikaTabanAylikKesintiOrani);
  final besKesintisi = brut * besKesintiOrani;

  final ozetKesinti = brut * (1 - netOrani);
  final kesinti = (ozetKesinti -
          vergiIstisnaEtkisi -
          ozelSaglikVergiEtkisi +
          raporKesintisi +
          sendikaKesintisi +
          besKesintisi +
          ilksanKesintisi +
          kefaletKesintisi)
      .clamp(0.0, double.infinity);
  final tahminiNet = (brut - kesinti).clamp(0.0, double.infinity);
  final eldeKalan = (tahminiNet - digerKesintiler).clamp(0.0, double.infinity);

  return MaasHesapSonucu(
    tabanAylik: donem.tabanAylik,
    gostergeAyligi: gostergeAyligi,
    ekGostergeTl: ekGostergeTl,
    kidemAyligi: kidemAyligi,
    ozelHizmetTazminati: ozelHizmetTazminati,
    dilTazminati: dilTazminati,
    ekOdeme: ekOdeme,
    aileYardimi: aileYardimi,
    cocukYardimi: cocukYardimi,
    brut: brut,
    vergiIstisnaEtkisi: vergiIstisnaEtkisi,
    ozelSaglikVergiEtkisi: ozelSaglikVergiEtkisi,
    raporKesintisi: raporKesintisi,
    sendikaKesintisi: sendikaKesintisi,
    besKesintisi: besKesintisi,
    ilksanKesintisi: ilksanKesintisi,
    kefaletKesintisi: kefaletKesintisi,
    digerKesintiler: digerKesintiler,
    tahminiKesinti: kesinti,
    tahminiNet: tahminiNet,
    eldeKalan: eldeKalan,
  );
}

Future<MaasKatsayiFile> loadMaasKatsayiFile() async {
  final s = await rootBundle.loadString('assets/json/maas_katsayilari.json');
  final json = jsonDecode(s) as Map<String, dynamic>;
  return MaasKatsayiFile.fromJson(json);
}
