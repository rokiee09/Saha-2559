import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TazminatDerece {
  const TazminatDerece({
    required this.derece,
    required this.ekOdemeTl,
    required this.etiket,
    required this.renkHex,
    required this.ilIdler,
  });

  final int derece;
  final int ekOdemeTl;
  final String etiket;
  final String renkHex;
  final List<String> ilIdler;

  Color get renk {
    final h = renkHex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return const Color(0xFF2D7EFF);
  }
}

class IlTazminatKayit {
  const IlTazminatKayit({
    this.derece,
    this.ekOdemeTl,
    this.etiket,
    this.renkHex,
  });

  final int? derece;
  final int? ekOdemeTl;
  final String? etiket;
  final String? renkHex;

  bool get varMi => derece != null && ekOdemeTl != null && ekOdemeTl! > 0;

  Color? get renk =>
      renkHex != null ? Color(int.parse('FF${renkHex!.replaceFirst('#', '')}', radix: 16)) : null;
}

class TazminatDereceleriSet {
  const TazminatDereceleriSet({
    required this.dereceler,
    required this.ilHaritasi,
    required this.kaynak,
  });

  final List<TazminatDerece> dereceler;
  final Map<String, IlTazminatKayit> ilHaritasi;
  final String kaynak;
}

Future<TazminatDereceleriSet> loadTazminatDereceleri() async {
  final raw = await rootBundle.loadString('assets/json/tazminat_dereceleri.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final dereceler = <TazminatDerece>[];
  final ilHaritasi = <String, IlTazminatKayit>{};

  for (final d in (json['dereceler'] as List<dynamic>? ?? const [])) {
    if (d is! Map<String, dynamic>) continue;
    final derece = (d['derece'] as num?)?.toInt();
    final ek = (d['ekOdemeTl'] as num?)?.toInt();
    final etiket = d['etiket'] as String? ?? '';
    final renk = d['renk'] as String? ?? '#2D7EFF';
    final iller = (d['iller'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    if (derece == null || ek == null) continue;
    dereceler.add(
      TazminatDerece(
        derece: derece,
        ekOdemeTl: ek,
        etiket: etiket,
        renkHex: renk,
        ilIdler: iller,
      ),
    );
    for (final ilId in iller) {
      ilHaritasi[ilId] = IlTazminatKayit(
        derece: derece,
        ekOdemeTl: ek,
        etiket: etiket,
        renkHex: renk,
      );
    }
  }

  dereceler.sort((a, b) => a.derece.compareTo(b.derece));
  return TazminatDereceleriSet(
    dereceler: dereceler,
    ilHaritasi: ilHaritasi,
    kaynak: json['kaynak'] as String? ?? '',
  );
}

final tazminatDereceleriProvider = FutureProvider<TazminatDereceleriSet>((ref) async {
  return loadTazminatDereceleri();
});

IlTazminatKayit? tazminatForIlId(String ilId, TazminatDereceleriSet set) {
  return set.ilHaritasi[ilId];
}

String formatEkOdeme(int? tl) {
  if (tl == null || tl <= 0) return '';
  final s = tl.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${buf.toString()} ₺';
}
