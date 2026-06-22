import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/text/tr_text.dart';
import 'il_analiz_models.dart';

/// İlçe konut fiyat seviyesi — JSON `level` alanı.
enum KonutFiyatSeviye {
  high,
  medium,
  low,
  seasonal,
  limitedData,
}

KonutFiyatSeviye? konutFiyatSeviyeFromJson(String? raw) {
  switch (raw) {
    case 'high':
      return KonutFiyatSeviye.high;
    case 'medium':
      return KonutFiyatSeviye.medium;
    case 'low':
      return KonutFiyatSeviye.low;
    case 'seasonal':
      return KonutFiyatSeviye.seasonal;
    case 'limitedData':
      return KonutFiyatSeviye.limitedData;
    default:
      return null;
  }
}

class IlKonutOrtalama {
  const IlKonutOrtalama({
    this.averageRent,
    this.rentPerSqm,
    this.salePerSqm,
    this.amortizationYears,
  });

  final int? averageRent;
  final int? rentPerSqm;
  final int? salePerSqm;
  final int? amortizationYears;

  factory IlKonutOrtalama.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const IlKonutOrtalama();
    return IlKonutOrtalama(
      averageRent: (j['averageRent'] as num?)?.toInt(),
      rentPerSqm: (j['rentPerSqm'] as num?)?.toInt(),
      salePerSqm: (j['salePerSqm'] as num?)?.toInt(),
      amortizationYears: (j['amortizationYears'] as num?)?.toInt(),
    );
  }
}

class IlceKonutFiyat {
  const IlceKonutFiyat({
    required this.district,
    this.rentMin,
    this.rentMax,
    this.saleMin,
    this.saleMax,
    this.level,
  });

  final String district;
  final int? rentMin;
  final int? rentMax;
  final int? saleMin;
  final int? saleMax;
  final KonutFiyatSeviye? level;

  factory IlceKonutFiyat.fromJson(Map<String, dynamic> j) {
    return IlceKonutFiyat(
      district: j['district'] as String? ?? '',
      rentMin: (j['rentMin'] as num?)?.toInt(),
      rentMax: (j['rentMax'] as num?)?.toInt(),
      saleMin: (j['saleMin'] as num?)?.toInt(),
      saleMax: (j['saleMax'] as num?)?.toInt(),
      level: konutFiyatSeviyeFromJson(j['level'] as String?),
    );
  }
}

class IlKonutFiyatProfil {
  const IlKonutFiyatProfil({
    required this.id,
    this.province,
    this.plate,
    this.sourceNote,
    required this.provinceAverage,
    required this.districtHousing,
  });

  final String id;
  final String? province;
  final int? plate;
  final String? sourceNote;
  final IlKonutOrtalama provinceAverage;
  final List<IlceKonutFiyat> districtHousing;
}

class KonutFiyatlariKatalog {
  const KonutFiyatlariKatalog({
    required this.defaultSourceNote,
    required this.lastUpdated,
    required this.profilMap,
  });

  final String defaultSourceNote;
  final String? lastUpdated;
  final Map<String, IlKonutFiyatProfil> profilMap;

  IlKonutFiyatProfil? profil(String ilId) => profilMap[ilId];
}

const _assetPath = 'assets/json/il_konut_fiyatlari.json';

Future<KonutFiyatlariKatalog> loadKonutFiyatlariKatalog() async {
  final raw = await rootBundle.loadString(_assetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final map = <String, IlKonutFiyatProfil>{};
  for (final e in json['iller'] as List<dynamic>? ?? const []) {
    if (e is! Map<String, dynamic>) continue;
    final id = e['id'] as String? ?? '';
    if (id.isEmpty) continue;
    map[id] = IlKonutFiyatProfil(
      id: id,
      province: e['province'] as String?,
      plate: (e['plate'] as num?)?.toInt(),
      sourceNote: e['sourceNote'] as String?,
      provinceAverage: IlKonutOrtalama.fromJson(
        e['provinceAverage'] as Map<String, dynamic>?,
      ),
      districtHousing: (e['districtHousing'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(IlceKonutFiyat.fromJson)
          .where((d) => d.district.isNotEmpty)
          .toList(),
    );
  }
  return KonutFiyatlariKatalog(
    defaultSourceNote: json['defaultSourceNote'] as String? ?? '',
    lastUpdated: json['lastUpdated'] as String?,
    profilMap: map,
  );
}

final konutFiyatlariProvider = FutureProvider<KonutFiyatlariKatalog>((ref) async {
  return loadKonutFiyatlariKatalog();
});

/// İlçe adı → konut kaydı (Türkçe-duyarlı eşleştirme).
Map<String, IlceKonutFiyat> konutIlceHaritasi(IlKonutFiyatProfil profil) {
  final map = <String, IlceKonutFiyat>{};
  for (final d in profil.districtHousing) {
    map[trFold(d.district)] = d;
  }
  return map;
}

IlceKonutFiyat? konutForIlceAdi(String ilceAd, Map<String, IlceKonutFiyat> harita) {
  return harita[trFold(ilceAd)];
}

/// Konut bandının orta noktası — ortalama kira gösterimi için.
int? konutOrtalamaKira(IlceKonutFiyat konut) {
  final min = konut.rentMin;
  final max = konut.rentMax;
  if (min != null && max != null) {
    return ((min + max) / 2).round();
  }
  return min ?? max;
}

/// İl analiz ilçe adı ile konut ilçe adını eşleştirir (ör. Feke ↔ Feke (Amirlik)).
bool ilceAdEslesir(String konutIlce, String analizIlce) {
  final k = trFold(konutIlce);
  final a = trFold(analizIlce);
  if (k == a) return true;
  if (a.startsWith('$k ') || a.startsWith('$k(')) return true;
  return false;
}

IlceAnaliz? ilceAnalizEslestir(String konutIlce, List<IlceAnaliz> ilceler) {
  for (final ilce in ilceler) {
    if (ilceAdEslesir(konutIlce, ilce.ad)) return ilce;
  }
  return null;
}

String konutVeriNotu(KonutFiyatlariKatalog katalog) {
  const sabit =
      'Kira ve satılık konut değerleri piyasa endeksi/ilan verilerine göre yaklaşık değerlerdir. Küçük ilçelerde ilan sayısı düşük olduğundan tahmini bant kullanılmıştır.';
  final genel = katalog.defaultSourceNote.trim();
  if (genel.isNotEmpty) return genel;
  return sabit;
}
