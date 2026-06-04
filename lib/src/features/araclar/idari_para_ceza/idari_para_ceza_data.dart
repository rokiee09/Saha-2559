import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/text/tr_text.dart';

/// 2026 idari para cezası kaydı.
class IdariParaCezaKayit {
  const IdariParaCezaKayit({
    required this.id,
    required this.kanunSayisi,
    required this.kanun,
    required this.madde,
    required this.kabahatAdi,
    required this.cezaMiktari,
    required this.kararVerenMakam,
    required this.itirazMercii,
    required this.itirazSuresi,
    required this.odemeSuresi,
    required this.belge,
  });

  final String id;
  final String kanunSayisi;
  final String kanun;
  final String madde;
  final String kabahatAdi;
  final int cezaMiktari;
  final String kararVerenMakam;
  final String itirazMercii;
  final String itirazSuresi;
  final String odemeSuresi;
  final String belge;

  factory IdariParaCezaKayit.fromJson(Map<String, dynamic> json) {
    return IdariParaCezaKayit(
      id: json['id'] as String? ?? '',
      kanunSayisi: json['kanunSayisi'] as String? ?? '',
      kanun: json['kanun'] as String? ?? '',
      madde: json['madde'] as String? ?? '',
      kabahatAdi: json['kabahatAdi'] as String? ?? '',
      cezaMiktari: (json['cezaMiktari'] as num?)?.toInt() ?? 0,
      kararVerenMakam: json['kararVerenMakam'] as String? ?? '',
      itirazMercii: json['itirazMercii'] as String? ?? '',
      itirazSuresi: json['itirazSuresi'] as String? ?? '',
      odemeSuresi: json['odemeSuresi'] as String? ?? '',
      belge: json['belge'] as String? ?? '',
    );
  }

  String get cezaMetni => '${formatCezaMiktari(cezaMiktari)} TL';

  String get kanunEtiketi {
    if (kanunSayisi.isEmpty) return kanun;
    return '$kanun ($kanunSayisi)';
  }

  String get aramaMetni => [
        kanun,
        kanunSayisi,
        madde,
        kabahatAdi,
        kararVerenMakam,
        itirazMercii,
        belge,
      ].join(' ');
}

enum IdariParaCezaSirala { varsayilan, cezaDesc, cezaAsc }

const _jsonPath = 'assets/json/idari_para_cezalari_2026.json';

const _gurultuKelimeler = {
  'ne',
  'kadar',
  'ceza',
  'cezasi',
  'miktari',
  'miktar',
  'tutar',
  'tl',
  'lira',
  'idari',
  'para',
  'kabahat',
  'ucreti',
  'bedeli',
  'nedir',
  'var',
  'mi',
  'mu',
  'icin',
  'olan',
  'bu',
  'bir',
};

String formatCezaMiktari(int tl) {
  final s = tl.toString();
  if (s.length <= 3) return s;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _titleCaseTr(String s) {
  if (s.isEmpty) return s;
  final lower = trLower(s);
  return lower[0].toUpperCase() + lower.substring(1);
}

String displayKabahatAdi(String adi) {
  if (adi.isEmpty) return adi;
  return adi
      .split(' ')
      .map((w) => w.isEmpty ? w : _titleCaseTr(w))
      .join(' ');
}

String _temizSorgu(String raw) {
  final tokens = trFold(raw)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((t) => t.length >= 2 && !_gurultuKelimeler.contains(t))
      .toList();
  return tokens.join(' ');
}

final idariParaCezaProvider =
    FutureProvider<IdariParaCezaSet>((ref) async {
  final raw = await rootBundle.loadString(_jsonPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final list = (json['kayitlar'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(IdariParaCezaKayit.fromJson)
      .where((k) => k.kabahatAdi.isNotEmpty)
      .toList();
  return IdariParaCezaSet(
    yil: json['yil'] as int? ?? 2026,
    kaynak: json['kaynak'] as String? ?? '',
    kayitlar: list,
  );
});

class IdariParaCezaSet {
  const IdariParaCezaSet({
    required this.yil,
    required this.kaynak,
    required this.kayitlar,
  });

  final int yil;
  final String kaynak;
  final List<IdariParaCezaKayit> kayitlar;

  List<String> get kanunlar {
    final seen = <String>{};
    final out = <String>[];
    for (final k in kayitlar) {
      if (k.kanun.isEmpty || !seen.add(k.kanun)) continue;
      out.add(k.kanun);
    }
    out.sort((a, b) => trFold(a).compareTo(trFold(b)));
    return out;
  }

  List<String> maddelerForKanun(String? kanun) {
    if (kanun == null || kanun.isEmpty) {
      final seen = <String>{};
      final out = <String>[];
      for (final k in kayitlar) {
        if (k.madde.isEmpty || !seen.add(k.madde)) continue;
        out.add(k.madde);
      }
      out.sort((a, b) => trFold(a).compareTo(trFold(b)));
      return out;
    }
    final seen = <String>{};
    final out = <String>[];
    for (final k in kayitlar) {
      if (k.kanun != kanun || k.madde.isEmpty || !seen.add(k.madde)) {
        continue;
      }
      out.add(k.madde);
    }
    out.sort((a, b) => trFold(a).compareTo(trFold(b)));
    return out;
  }

  List<IdariParaCezaKayit> filtrele({
    String query = '',
    String? kanun,
    String? madde,
    bool yalnizFavoriler = false,
    Set<String> favoriIds = const {},
    IdariParaCezaSirala sirala = IdariParaCezaSirala.varsayilan,
  }) {
    final q = trFold(query.trim());
    var out = kayitlar.where((k) {
      if (kanun != null && kanun.isNotEmpty && k.kanun != kanun) {
        return false;
      }
      if (madde != null && madde.isNotEmpty && k.madde != madde) {
        return false;
      }
      if (yalnizFavoriler && !favoriIds.contains(k.id)) return false;
      if (q.isEmpty) return true;
      return trFold(k.aramaMetni).contains(q);
    }).toList();

    switch (sirala) {
      case IdariParaCezaSirala.cezaDesc:
        out.sort((a, b) => b.cezaMiktari.compareTo(a.cezaMiktari));
      case IdariParaCezaSirala.cezaAsc:
        out.sort((a, b) => a.cezaMiktari.compareTo(b.cezaMiktari));
      case IdariParaCezaSirala.varsayilan:
        break;
    }
    return out;
  }

  /// Asistan sorguları için en iyi eşleşme (ör. "dilencilik cezası ne kadar").
  IdariParaCezaKayit? enIyiEslesme(String rawQuery) {
    final cleaned = _temizSorgu(rawQuery);
    if (cleaned.isEmpty) return null;

    final q = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    final tokens = q.split(' ').where((t) => t.length >= 2).toList();
    if (tokens.isEmpty) return null;

    IdariParaCezaKayit? best;
    var bestScore = 0;

    for (final k in kayitlar) {
      final kab = trFold(k.kabahatAdi);
      final kan = trFold(k.kanun);
      final mad = trFold(k.madde);
      var score = 0;

      if (q == kab) {
        score = 2000 + q.length;
      } else if (kab.contains(q)) {
        score = 1200 + q.length;
      } else if (q.contains(kab) && kab.length >= 4) {
        score = 900 + kab.length;
      }

      for (final t in tokens) {
        if (kab.contains(t)) score += 80 + t.length;
        if (kan.contains(t)) score += 20;
        if (mad.contains(t)) score += 15;
      }

      final matchedAll = tokens.every((t) => kab.contains(t));
      if (matchedAll && tokens.length > 1) score += 100;

      if (score > bestScore) {
        bestScore = score;
        best = k;
      }
    }

    return bestScore >= 80 ? best : null;
  }
}

bool idariParaCezaSorguMu(String raw) {
  final q = trFold(raw);
  const anahtar = [
    'ceza',
    'kabahat',
    'idari para',
    'para cezasi',
    'ne kadar',
    'tl',
  ];
  for (final k in anahtar) {
    if (q.contains(trFold(k))) return true;
  }
  return false;
}
