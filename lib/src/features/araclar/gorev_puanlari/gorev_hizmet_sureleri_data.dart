import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/text/tr_text.dart';
import 'gorev_puanlari_data.dart';

/// EK-1 sayılı cetvel — zorunlu hizmet süresi (yıl) ve bölge.
class GorevHizmetSuresiKayit {
  const GorevHizmetSuresiKayit({
    required this.sn,
    required this.yer,
    required this.bolge,
    required this.yil,
  });

  final int sn;
  final String yer;
  final int bolge;
  final int yil;

  factory GorevHizmetSuresiKayit.fromJson(Map<String, dynamic> json) {
    return GorevHizmetSuresiKayit(
      sn: json['sn'] as int? ?? 0,
      yer: json['yer'] as String? ?? '',
      bolge: json['bolge'] as int? ?? 1,
      yil: json['yil'] as int? ?? 0,
    );
  }

  String get bolgeMetni => '$bolge. bölge';
  String get yilMetni => '$yil yıl';

  bool get ilceMi => yer.contains('-');
  String get ilAdi => ilceMi ? yer.split('-').first : yer;
}

class GorevHizmetSureleriSet {
  const GorevHizmetSureleriSet({
    required this.yil,
    required this.kayitlar,
    this.uyari,
    this.kaynak,
    this.eksikSnAraligi,
  });

  final int yil;
  final List<GorevHizmetSuresiKayit> kayitlar;
  final String? uyari;
  final String? kaynak;
  final String? eksikSnAraligi;

  bool get bos => kayitlar.isEmpty;

  List<GorevHizmetSuresiKayit> ara(
    String query, {
    int? bolgeFiltre,
  }) {
    final q = trFold(query.trim());
    return kayitlar.where((k) {
      if (bolgeFiltre != null && k.bolge != bolgeFiltre) return false;
      if (q.isEmpty) return true;
      return trFold(k.yer).contains(q);
    }).toList();
  }

  GorevHizmetSuresiKayit? bul(String yer) {
    final key = trFold(yer);
    for (final k in kayitlar) {
      if (trFold(k.yer) == key) return k;
    }
    return null;
  }
}

List<int> _eksikSeriNumaralari(List<int> sns) {
  if (sns.isEmpty) return const [];
  final set = sns.toSet();
  final gaps = <int>[];
  for (var i = sns.first; i <= sns.last; i++) {
    if (!set.contains(i)) gaps.add(i);
  }
  return gaps;
}

String? _eksikSnOzeti(List<int> gaps) {
  if (gaps.isEmpty) return null;
  if (gaps.length == 1) return 'SN ${gaps.first}';
  final ardisik = gaps.length == gaps.last - gaps.first + 1;
  if (ardisik) return 'SN ${gaps.first}–${gaps.last}';
  return '${gaps.length} sıra no eksik';
}

Future<GorevHizmetSureleriSet> _loadHizmetSureleri() async {
  const path = 'assets/json/gorev_hizmet_sureleri_2026.json';
  final raw = await rootBundle.loadString(path);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final list = (json['kayitlar'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(GorevHizmetSuresiKayit.fromJson)
      .where((k) => k.yer.isNotEmpty && k.yil > 0)
      .toList()
    ..sort((a, b) => a.sn.compareTo(b.sn));

  final sns = list.map((k) => k.sn).toList();
  final eksik = _eksikSnOzeti(_eksikSeriNumaralari(sns));

  return GorevHizmetSureleriSet(
    yil: json['yil'] as int? ?? 2026,
    kayitlar: list,
    uyari: json['uyari'] as String?,
    kaynak: json['kaynak'] as String?,
    eksikSnAraligi: eksik,
  );
}

/// Cumhurbaşkanlığı Kararı 10665 (5.12.2025) — EK-1 cetveli.
final gorevHizmetSureleriProvider =
    FutureProvider<GorevHizmetSureleriSet>((ref) async {
  return _loadHizmetSureleri();
});
