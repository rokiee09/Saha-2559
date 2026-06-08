import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/text/tr_text.dart';

class MutalaaKayit {
  const MutalaaKayit({
    required this.id,
    required this.ref,
    required this.baslik,
    required this.ozet,
    required this.metin,
    required this.keywords,
    this.soru,
    this.cevap,
  });

  final String id;
  final String ref;
  final String baslik;
  final String ozet;
  final String metin;
  final List<String> keywords;
  final String? soru;
  final String? cevap;

  String get soruMetni => (soru?.trim().isNotEmpty == true ? soru! : ozet).trim();

  String get cevapMetni =>
      (cevap?.trim().isNotEmpty == true ? cevap! : '').trim();

  factory MutalaaKayit.fromJson(Map<String, dynamic> json) {
    return MutalaaKayit(
      id: json['id'] as String? ?? '',
      ref: json['ref'] as String? ?? '',
      baslik: json['baslik'] as String? ?? '',
      ozet: json['ozet'] as String? ?? '',
      metin: json['metin'] as String? ?? '',
      soru: json['soru'] as String?,
      cevap: json['cevap'] as String?,
      keywords: (json['keywords'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}

class MutalaaOzelSet {
  const MutalaaOzelSet({
    required this.kaynak,
    required this.uyari,
    required this.kayitlar,
  });

  final String kaynak;
  final String uyari;
  final List<MutalaaKayit> kayitlar;
}

Future<MutalaaOzelSet> loadMutalaaOzelSet() async {
  final raw = await rootBundle.loadString('assets/json/mutalaa_ozel.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final list = (json['kayitlar'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(MutalaaKayit.fromJson)
      .where((k) => k.id.isNotEmpty && k.baslik.isNotEmpty)
      .toList();
  return MutalaaOzelSet(
    kaynak: json['kaynak'] as String? ?? 'DPB Mütalaalar Özel',
    uyari: json['uyari'] as String? ??
        'Kurum görüşüdür; güncel mevzuatla birlikte değerlendirin.',
    kayitlar: list,
  );
}

final mutalaaOzelProvider = FutureProvider<MutalaaOzelSet>((ref) async {
  return loadMutalaaOzelSet();
});

/// DPB görüş metninden asistan özet cevabı üretir.
String mutalaaCevapOzeti(String cevap, {int maxLen = 360}) {
  final t = cevap.trim();
  if (t.isEmpty) return '';
  final lines = t.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isNotEmpty) {
    final last = lines.last.trim();
    if (last.length >= 40 && last.length <= maxLen) return last;
  }
  if (t.length <= maxLen) return t;
  final cut = t.substring(0, maxLen);
  final lastDot = cut.lastIndexOf('.');
  if (lastDot > 80) return cut.substring(0, lastDot + 1).trim();
  return '${cut.trimRight()}…';
}

List<MutalaaKayit> mutalaaEslestir(String query, List<MutalaaKayit> kayitlar) {
  final q = trFold(query.trim());
  if (q.length < 2) return const [];
  final tokens =
      q.split(RegExp(r'\s+')).where((t) => t.length >= 2).toList();
  final out = <MutalaaKayit>[];
  for (final k in kayitlar) {
    final blob = trFold(
      '${k.baslik} ${k.ozet} ${k.soruMetni} ${k.cevapMetni} ${k.metin} ${k.keywords.join(' ')}',
    );
    final match = blob.contains(q) ||
        k.keywords.any((w) => trFold(w).contains(q)) ||
        (tokens.isNotEmpty && tokens.every((t) => blob.contains(t)));
    if (match) out.add(k);
  }
  return out;
}
