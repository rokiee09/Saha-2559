import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/text/tr_text.dart';

/// 2025 / 2026 görev yeri puanı kaydı (il veya il-ilçe).
class GorevPuaniKayit {
  const GorevPuaniKayit({required this.yer, required this.puan});

  final String yer;
  final double puan;

  factory GorevPuaniKayit.fromJson(Map<String, dynamic> json) {
    return GorevPuaniKayit(
      yer: json['yer'] as String? ?? '',
      puan: (json['puan'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Türkçe binlik ayraçlı gösterim: 1718 → "1.718 Puan"
  String get puanMetni => '${formatGorevPuani(puan)} Puan';

  bool get ilceMi => yer.contains('-');
  String get ilAdi => ilceMi ? yer.split('-').first : yer;
  String? get ilceAdi => ilceMi ? yer.split('-').skip(1).join('-') : null;
}

/// JSON'daki puan değerini ekranda göster (1.718 biçimi).
String formatGorevPuani(double puan) {
  final v = (puan * 1000).round();
  final s = v.toString();
  if (s.length <= 3) return s;
  return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
}

String _jsonPathForYil(int yil) {
  switch (yil) {
    case 2026:
      return 'assets/json/gorev_puanlari_2026.json';
    case 2025:
    default:
      return 'assets/json/gorev_puanlari_2025.json';
  }
}

Future<GorevPuanlariSet> _loadGorevPuanlari(int yil) async {
  final raw = await rootBundle.loadString(_jsonPathForYil(yil));
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final list = (json['kayitlar'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(GorevPuaniKayit.fromJson)
      .where((k) => k.yer.isNotEmpty && k.puan > 0)
      .toList()
    ..sort((a, b) => trFold(a.yer).compareTo(trFold(b.yer)));
  return GorevPuanlariSet(
    yil: json['yil'] as int? ?? yil,
    kayitlar: list,
    uyari: json['uyari'] as String?,
    kaynak: json['kaynak'] as String?,
  );
}

/// Yıla göre cetvel (2025 veya 2026).
final gorevPuanlariByYilProvider =
    FutureProvider.family<GorevPuanlariSet, int>((ref, yil) async {
  return _loadGorevPuanlari(yil);
});

/// Geriye dönük: 2025 cetveli.
final gorevPuanlariProvider = gorevPuanlariByYilProvider(2025);

/// Her iki yıl cetveli (hesaplama / karşılaştırma).
final gorevPuanlariIkiliProvider =
    FutureProvider<(GorevPuanlariSet, GorevPuanlariSet)>((ref) async {
  final y2025 = await ref.watch(gorevPuanlariByYilProvider(2025).future);
  final y2026 = await ref.watch(gorevPuanlariByYilProvider(2026).future);
  return (y2025, y2026);
});

class GorevPuanlariSet {
  const GorevPuanlariSet({
    required this.yil,
    required this.kayitlar,
    this.uyari,
    this.kaynak,
  });

  final int yil;
  final List<GorevPuaniKayit> kayitlar;
  final String? uyari;
  final String? kaynak;

  bool get bos => kayitlar.isEmpty;

  List<GorevPuaniKayit> ara(String query) {
    final q = trFold(query.trim());
    if (q.isEmpty) return kayitlar;
    return kayitlar.where((k) => trFold(k.yer).contains(q)).toList();
  }

  GorevPuaniKayit? bul(String yer) {
    final key = trFold(yer);
    for (final k in kayitlar) {
      if (trFold(k.yer) == key) return k;
    }
    return null;
  }
}

/// Aynı yer için 2025 ve 2026 günlük puanlarını birlikte göster.
class GorevPuaniIkiliSatir {
  const GorevPuaniIkiliSatir({
    required this.yer,
    this.puan2025,
    this.puan2026,
  });

  final String yer;
  final double? puan2025;
  final double? puan2026;

  String get puan2025Metni =>
      puan2025 != null ? formatGorevPuani(puan2025!) : '—';

  String get puan2026Metni =>
      puan2026 != null ? formatGorevPuani(puan2026!) : '—';
}

List<GorevPuaniIkiliSatir> gorevPuaniIkiliListe(
  GorevPuanlariSet set2025,
  GorevPuanlariSet set2026, {
  String query = '',
}) {
  final keys = <String>{};
  final map2025 = <String, double>{};
  final map2026 = <String, double>{};
  for (final k in set2025.kayitlar) {
    keys.add(k.yer);
    map2025[k.yer] = k.puan;
  }
  for (final k in set2026.kayitlar) {
    keys.add(k.yer);
    map2026[k.yer] = k.puan;
  }
  var list = keys
      .map(
        (yer) => GorevPuaniIkiliSatir(
          yer: yer,
          puan2025: map2025[yer],
          puan2026: map2026[yer],
        ),
      )
      .toList()
    ..sort((a, b) => trFold(a.yer).compareTo(trFold(b.yer)));

  final q = trFold(query.trim());
  if (q.isNotEmpty) {
    list = list.where((s) => trFold(s.yer).contains(q)).toList();
  }
  return list;
}

/// JSON'daki büyük harf yer adını okunaklı göster.
String displayGorevYeriAdi(String yer) {
  if (!yer.contains('-')) {
    return _titleCaseTr(yer);
  }
  final parts = yer.split('-');
  return '${_titleCaseTr(parts.first)}-${parts.skip(1).map(_titleCaseTr).join('-')}';
}

String _titleCaseTr(String s) {
  if (s.isEmpty) return s;
  final lower = trLower(s);
  return lower[0].toUpperCase() + lower.substring(1);
}
