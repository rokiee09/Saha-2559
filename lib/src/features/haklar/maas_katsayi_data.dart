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
      memurAylikKatsayisi:
          (j['memurAylikKatsayisi'] as num?)?.toDouble() ?? 0,
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

/// MAHEP tarzı bordro satırları + tahmini net (tek oran; kesin değil).
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
  final double tahminiKesinti;
  final double tahminiNet;

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
    required this.tahminiKesinti,
    required this.tahminiNet,
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
}) {
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
  final tahminiNet = brut * donem.tahminiNetOrani;
  final kesinti = brut - tahminiNet;
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
    tahminiKesinti: kesinti,
    tahminiNet: tahminiNet,
  );
}

Future<MaasKatsayiFile> loadMaasKatsayiFile() async {
  final s =
      await rootBundle.loadString('assets/json/maas_katsayilari.json');
  final json = jsonDecode(s) as Map<String, dynamic>;
  return MaasKatsayiFile.fromJson(json);
}
