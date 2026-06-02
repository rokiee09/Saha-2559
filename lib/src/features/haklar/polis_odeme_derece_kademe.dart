import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Polis Memuru ödemeye esas derece/kademe → gösterge, ek gösterge, ÖHT ve sabit kalemler.
class PolisOdemeDereceKademeSonuc {
  final int derece;
  final int kademe;
  final int gostergePuan657;
  final int gostergePuan;
  final double ekGostergeTl;
  final double ohtTl;
  final double kidemAylik;
  final double ekOdemeToplam;
  final double gvIstisnasi;
  final double dvIstisnaMatrahi;
  final bool kalibreNokta;
  final double? tahminiNetBrutOrani;

  const PolisOdemeDereceKademeSonuc({
    required this.derece,
    required this.kademe,
    required this.gostergePuan657,
    required this.gostergePuan,
    required this.ekGostergeTl,
    required this.ohtTl,
    required this.kidemAylik,
    required this.ekOdemeToplam,
    required this.gvIstisnasi,
    required this.dvIstisnaMatrahi,
    required this.kalibreNokta,
    this.tahminiNetBrutOrani,
  });
}

class _PolisUnvanOdeme {
  final double gostergeCarpani;
  final List<double> ekCarpanDerece15;
  final List<double> ohtTlDerece15;
  final Map<String, _KalibreNokta> kalibre;
  final _SabitKalemler sabit;
  final double? tahminiNetBrutOrani;

  _PolisUnvanOdeme({
    required this.gostergeCarpani,
    required this.ekCarpanDerece15,
    required this.ohtTlDerece15,
    required this.kalibre,
    required this.sabit,
    this.tahminiNetBrutOrani,
  });

  factory _PolisUnvanOdeme.fromJson(Map<String, dynamic> j) {
    final ekRaw = j['ekGostergeCarpaniDerece'] as Map<String, dynamic>? ?? {};
    final ohtRaw = j['ohtTlDerece'] as Map<String, dynamic>? ?? {};
    final ekList = List<double>.generate(15, (i) {
      final k = '${i + 1}';
      return (ekRaw[k] as num?)?.toDouble() ?? 1.0;
    });
    final ohtList = List<double>.generate(15, (i) {
      final k = '${i + 1}';
      return (ohtRaw[k] as num?)?.toDouble() ?? 0;
    });
    final kalibreList = j['kalibreNoktalar'] as List<dynamic>? ?? [];
    final kalibre = <String, _KalibreNokta>{};
    for (final e in kalibreList) {
      final m = e as Map<String, dynamic>;
      final d = (m['derece'] as num?)?.toInt() ?? 0;
      final k = (m['kademe'] as num?)?.toInt() ?? 0;
      kalibre['$d/$k'] = _KalibreNokta.fromJson(m);
    }
    return _PolisUnvanOdeme(
      gostergeCarpani: (j['gostergeCarpani'] as num?)?.toDouble() ?? 1,
      ekCarpanDerece15: ekList,
      ohtTlDerece15: ohtList,
      kalibre: kalibre,
      sabit: _SabitKalemler.fromJson(
          j['sabitKalemler'] as Map<String, dynamic>? ?? {}),
      tahminiNetBrutOrani: (j['tahminiNetBrutOrani'] as num?)?.toDouble(),
    );
  }
}

class _KalibreNokta {
  final int gostergePuan;
  final double ekGostergeTl;
  final double ohtTl;
  final double? gvIstisnasi;
  final double? netBrutOrani;

  _KalibreNokta({
    required this.gostergePuan,
    required this.ekGostergeTl,
    required this.ohtTl,
    this.gvIstisnasi,
    this.netBrutOrani,
  });

  factory _KalibreNokta.fromJson(Map<String, dynamic> j) => _KalibreNokta(
        gostergePuan: (j['gostergePuan'] as num?)?.toInt() ?? 0,
        ekGostergeTl: (j['ekGostergeTl'] as num?)?.toDouble() ?? 0,
        ohtTl: (j['ohtTl'] as num?)?.toDouble() ?? 0,
        gvIstisnasi: (j['gvIstisnasi'] as num?)?.toDouble(),
        netBrutOrani: (j['netBrutOrani'] as num?)?.toDouble(),
      );
}

class _SabitKalemler {
  final double kidemAylik;
  final double ekOdeme666;
  final double fazlaMesai;
  final double tayinBedeli;
  final double ilaveOdeme37540;
  final double gvIstisnasi;
  final double dvIstisnaMatrahi;

  _SabitKalemler({
    required this.kidemAylik,
    required this.ekOdeme666,
    required this.fazlaMesai,
    required this.tayinBedeli,
    required this.ilaveOdeme37540,
    required this.gvIstisnasi,
    required this.dvIstisnaMatrahi,
  });

  factory _SabitKalemler.fromJson(Map<String, dynamic> j) => _SabitKalemler(
        kidemAylik: (j['kidemAylik'] as num?)?.toDouble() ?? 0,
        ekOdeme666: (j['ekOdeme666'] as num?)?.toDouble() ?? 0,
        fazlaMesai: (j['fazlaMesai'] as num?)?.toDouble() ?? 0,
        tayinBedeli: (j['tayinBedeli'] as num?)?.toDouble() ?? 0,
        ilaveOdeme37540: (j['ilaveOdeme37540'] as num?)?.toDouble() ?? 0,
        gvIstisnasi: (j['gvIstisnasi'] as num?)?.toDouble() ?? 0,
        dvIstisnaMatrahi: (j['dvIstisnaMatrahi'] as num?)?.toDouble() ?? 0,
      );

  double get ekOdemeToplam =>
      ekOdeme666 + fazlaMesai + tayinBedeli + ilaveOdeme37540;
}

class PolisOdemeDereceKademeTablosu {
  final List<List<int>> gosterge657;
  final List<int> ekGosterge657Derece;
  final double referansKatsayi;
  final Map<String, _PolisUnvanOdeme> unvanlar;

  PolisOdemeDereceKademeTablosu({
    required this.gosterge657,
    required this.ekGosterge657Derece,
    required this.referansKatsayi,
    required this.unvanlar,
  });

  factory PolisOdemeDereceKademeTablosu.fromJson(Map<String, dynamic> j) {
    final gRaw = j['gosterge657'] as List<dynamic>? ?? [];
    final gosterge657 = gRaw
        .map((row) => (row as List<dynamic>)
            .map((e) => (e as num?)?.toInt() ?? 0)
            .toList())
        .toList();
    final ekRaw = j['ekGosterge657Derece'] as List<dynamic>? ?? [];
    final unvanRaw = j['unvanlar'] as Map<String, dynamic>? ?? {};
    final unvanlar = <String, _PolisUnvanOdeme>{};
    unvanRaw.forEach((k, v) {
      unvanlar[k] = _PolisUnvanOdeme.fromJson(v as Map<String, dynamic>);
    });
    return PolisOdemeDereceKademeTablosu(
      gosterge657: gosterge657,
      ekGosterge657Derece:
          ekRaw.map((e) => (e as num).toInt()).toList(growable: false),
      referansKatsayi: (j['referansKatsayi'] as num?)?.toDouble() ?? 0.352397,
      unvanlar: unvanlar,
    );
  }

  /// 657 tablosunda bu derece için geçerli en yüksek kademe (1–9).
  int maxKademe657(int derece) {
    if (derece < 1 || derece > gosterge657.length) return 0;
    final row = gosterge657[derece - 1];
    for (var i = row.length - 1; i >= 0; i--) {
      if (row[i] > 0) return i + 1;
    }
    return 0;
  }

  int? _gosterge657Puan(int derece, int kademe) {
    if (derece < 1 || derece > gosterge657.length) return null;
    final row = gosterge657[derece - 1];
    if (kademe < 1 || kademe > row.length) return null;
    final p = row[kademe - 1];
    return p > 0 ? p : null;
  }

  /// [memurAylikKatsayisi] dönem JSON’undan; ek gösterge TL bu orana göre ölçeklenir.
  PolisOdemeDereceKademeSonuc? hesapla({
    required String unvan,
    required int derece,
    required int kademe,
    required double memurAylikKatsayisi,
  }) {
    final u = unvanlar[unvan];
    if (u == null) return null;

    final g657 = _gosterge657Puan(derece, kademe);
    if (g657 == null) return null;

    final key = '$derece/$kademe';
    final kal = u.kalibre[key];
    final katsayiOran = referansKatsayi <= 0
        ? 1.0
        : memurAylikKatsayisi / referansKatsayi;

    int gostergePuan;
    double ekTl;
    double ohtTl;
    double gvIst;
    var kalibreNokta = false;

    double? netOraniKalibre;
    if (kal != null) {
      kalibreNokta = true;
      gostergePuan = kal.gostergePuan;
      ekTl = kal.ekGostergeTl * katsayiOran;
      ohtTl = kal.ohtTl * katsayiOran;
      gvIst = (kal.gvIstisnasi ?? u.sabit.gvIstisnasi) * katsayiOran;
      netOraniKalibre = kal.netBrutOrani ?? u.tahminiNetBrutOrani;
    } else {
      gostergePuan = (g657 * u.gostergeCarpani).round();
      final dIdx = (derece - 1).clamp(0, 14);
      final ek657 = dIdx < ekGosterge657Derece.length
          ? ekGosterge657Derece[dIdx]
          : ekGosterge657Derece.last;
      final ekCarpan = u.ekCarpanDerece15[dIdx];
      final ekPuanEff = ek657 * ekCarpan;
      ekTl = ekPuanEff * memurAylikKatsayisi;
      ohtTl = u.ohtTlDerece15[dIdx] * katsayiOran;
      gvIst = u.sabit.gvIstisnasi * katsayiOran;
    }

    return PolisOdemeDereceKademeSonuc(
      derece: derece,
      kademe: kademe,
      gostergePuan657: g657,
      gostergePuan: gostergePuan,
      ekGostergeTl: ekTl,
      ohtTl: ohtTl,
      kidemAylik: u.sabit.kidemAylik * katsayiOran,
      ekOdemeToplam: u.sabit.ekOdemeToplam * katsayiOran,
      gvIstisnasi: gvIst,
      dvIstisnaMatrahi: u.sabit.dvIstisnaMatrahi,
      kalibreNokta: kalibreNokta,
      tahminiNetBrutOrani: netOraniKalibre ?? u.tahminiNetBrutOrani,
    );
  }

  bool desteklenenUnvan(String unvan) => unvanlar.containsKey(unvan);
}

PolisOdemeDereceKademeTablosu? _cachedTablo;

Future<PolisOdemeDereceKademeTablosu> loadPolisOdemeDereceKademeTablosu() async {
  if (_cachedTablo != null) return _cachedTablo!;
  final s =
      await rootBundle.loadString('assets/json/polis_odeme_derece_kademe.json');
  final json = jsonDecode(s) as Map<String, dynamic>;
  _cachedTablo = PolisOdemeDereceKademeTablosu.fromJson(json);
  return _cachedTablo!;
}

/// Testlerde önbelleği sıfırlamak için.
void resetPolisOdemeTabloCacheForTest() => _cachedTablo = null;
