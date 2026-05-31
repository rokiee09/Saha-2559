import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/text/tr_text.dart';

/// 2025 görev yeri puanı kaydı (il veya il-ilçe).
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

const _jsonPath = 'assets/json/gorev_puanlari_2025.json';

final gorevPuanlariProvider = FutureProvider<GorevPuanlariSet>((ref) async {
  final raw = await rootBundle.loadString(_jsonPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final list = (json['kayitlar'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(GorevPuaniKayit.fromJson)
      .where((k) => k.yer.isNotEmpty && k.puan > 0)
      .toList()
    ..sort((a, b) => trFold(a.yer).compareTo(trFold(b.yer)));
  return GorevPuanlariSet(
    yil: json['yil'] as int? ?? 2025,
    kayitlar: list,
  );
});

class GorevPuanlariSet {
  const GorevPuanlariSet({required this.yil, required this.kayitlar});

  final int yil;
  final List<GorevPuaniKayit> kayitlar;

  List<GorevPuaniKayit> ara(String query) {
    final q = trFold(query.trim());
    if (q.isEmpty) return kayitlar;
    return kayitlar
        .where((k) => trFold(k.yer).contains(q))
        .toList();
  }

  GorevPuaniKayit? bul(String yer) {
    final key = trFold(yer);
    for (final k in kayitlar) {
      if (trFold(k.yer) == key) return k;
    }
    return null;
  }
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
