import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IlYasamIndeksiKayit {
  const IlYasamIndeksiKayit({
    required this.sira,
    this.ad,
  });

  final int sira;
  final String? ad;
}

class YasamIndeksiSet {
  const YasamIndeksiSet({
    required this.yil,
    required this.kaynak,
    required this.ilHaritasi,
  });

  final int yil;
  final String kaynak;
  final Map<String, IlYasamIndeksiKayit> ilHaritasi;
}

Future<YasamIndeksiSet> loadYasamIndeksi() async {
  final raw = await rootBundle.loadString('assets/json/yasam_indeksi.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final iller = json['iller'] as Map<String, dynamic>? ?? const {};
  final map = <String, IlYasamIndeksiKayit>{};
  for (final e in iller.entries) {
    if (e.value is! Map<String, dynamic>) continue;
    final j = e.value as Map<String, dynamic>;
    final sira = (j['sira'] as num?)?.toInt();
    if (sira == null) continue;
    map[e.key] = IlYasamIndeksiKayit(
      sira: sira,
      ad: j['ad'] as String?,
    );
  }
  return YasamIndeksiSet(
    yil: (json['yil'] as num?)?.toInt() ?? 2015,
    kaynak: json['kaynak'] as String? ?? 'TÜİK',
    ilHaritasi: map,
  );
}

final yasamIndeksiProvider = FutureProvider<YasamIndeksiSet>((ref) async {
  return loadYasamIndeksi();
});

IlYasamIndeksiKayit? yasamIndeksiForIlId(String ilId, YasamIndeksiSet set) {
  return set.ilHaritasi[ilId];
}
