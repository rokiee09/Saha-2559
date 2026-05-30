import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kariyer paneli verisi yalnızca cihazda (SharedPreferences) tutulur.
/// Kişisel kayıt amaçlıdır; resmî sicil/özlük kaydı değildir. Tayin puanı
/// tahmini, doğrulanmış kriter verisi eklenene kadar yapılmaz.

enum KariyerKayitTuru { basari, egitim, sark }

extension KariyerKayitTuruX on KariyerKayitTuru {
  String get id => name;

  String get label => switch (this) {
        KariyerKayitTuru.basari => 'Başarı belgesi',
        KariyerKayitTuru.egitim => 'Eğitim / kurs',
        KariyerKayitTuru.sark => 'Şark / zorunlu görev',
      };

  static KariyerKayitTuru fromId(String? id) =>
      KariyerKayitTuru.values.firstWhere(
        (e) => e.name == id,
        orElse: () => KariyerKayitTuru.basari,
      );
}

class KariyerKayit {
  const KariyerKayit({
    required this.id,
    required this.tur,
    required this.baslik,
    this.yil = 0,
    this.not = '',
  });

  final String id;
  final KariyerKayitTuru tur;
  final String baslik;
  final int yil;
  final String not;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tur': tur.id,
        'baslik': baslik,
        'yil': yil,
        'not': not,
      };

  factory KariyerKayit.fromJson(Map<String, dynamic> j) => KariyerKayit(
        id: j['id'] as String? ?? '',
        tur: KariyerKayitTuruX.fromId(j['tur'] as String?),
        baslik: j['baslik'] as String? ?? '',
        yil: (j['yil'] as num?)?.toInt() ?? 0,
        not: j['not'] as String? ?? '',
      );
}

class KariyerProfil {
  const KariyerProfil({
    this.brans = '',
    this.sicil = '',
    this.baslamaYili = 0,
  });

  final String brans;
  final String sicil;
  final int baslamaYili;

  /// Göreve başlama yılından bu yana hizmet yılı (yaklaşık).
  int get hizmetYili {
    if (baslamaYili <= 0) return 0;
    final y = DateTime.now().year - baslamaYili;
    return y < 0 ? 0 : y;
  }

  KariyerProfil copyWith({String? brans, String? sicil, int? baslamaYili}) =>
      KariyerProfil(
        brans: brans ?? this.brans,
        sicil: sicil ?? this.sicil,
        baslamaYili: baslamaYili ?? this.baslamaYili,
      );
}

const _profilKey = 'kariyer_profil_v1';
const _kayitlarKey = 'kariyer_kayitlar_v1';

final kariyerVersionProvider = StateProvider<int>((ref) => 0);

final kariyerProfilProvider = FutureProvider<KariyerProfil>((ref) async {
  ref.watch(kariyerVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_profilKey);
  if (raw == null || raw.isEmpty) return const KariyerProfil();
  try {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return KariyerProfil(
      brans: j['brans'] as String? ?? '',
      sicil: j['sicil'] as String? ?? '',
      baslamaYili: (j['baslamaYili'] as num?)?.toInt() ?? 0,
    );
  } catch (_) {
    return const KariyerProfil();
  }
});

Future<void> kariyerSaveProfil(WidgetRef ref, KariyerProfil profil) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _profilKey,
    jsonEncode({
      'brans': profil.brans,
      'sicil': profil.sicil,
      'baslamaYili': profil.baslamaYili,
    }),
  );
  ref.read(kariyerVersionProvider.notifier).state++;
}

final kariyerKayitlarProvider =
    FutureProvider<List<KariyerKayit>>((ref) async {
  ref.watch(kariyerVersionProvider);
  return _readKayitlar();
});

Future<List<KariyerKayit>> _readKayitlar() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kayitlarKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(KariyerKayit.fromJson)
        .toList()
      ..sort((a, b) => b.yil.compareTo(a.yil));
  } catch (_) {
    return [];
  }
}

Future<void> _writeKayitlar(WidgetRef ref, List<KariyerKayit> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kayitlarKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
  ref.read(kariyerVersionProvider.notifier).state++;
}

Future<void> kariyerAddKayit(WidgetRef ref, KariyerKayit kayit) async {
  final list = await _readKayitlar();
  list.add(kayit);
  await _writeKayitlar(ref, list);
}

Future<void> kariyerDeleteKayit(WidgetRef ref, String id) async {
  final list = (await _readKayitlar()).where((e) => e.id != id).toList();
  await _writeKayitlar(ref, list);
}

String kariyerGenerateId() => 'kariyer_${DateTime.now().microsecondsSinceEpoch}';

/// Türe göre sayım (özet kartları için).
int kariyerSayisi(List<KariyerKayit> list, KariyerKayitTuru tur) =>
    list.where((e) => e.tur == tur).length;
