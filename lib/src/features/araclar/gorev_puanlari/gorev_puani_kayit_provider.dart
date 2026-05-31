import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gorev_puani_calculator.dart';

/// Cihazda saklanan görev puanı dönemi kaydı.
class GorevPuaniKaydi {
  const GorevPuaniKaydi({
    required this.id,
    required this.yer,
    required this.gunlukPuan,
    required this.baslangicMs,
    required this.bitisMs,
    required this.gunSayisi,
    required this.toplamPuan,
    this.halenGorevde = false,
    this.olusturulmaMs = 0,
  });

  final String id;
  final String yer;
  final double gunlukPuan;
  final int baslangicMs;
  final int bitisMs;
  final int gunSayisi;
  final double toplamPuan;
  final bool halenGorevde;
  final int olusturulmaMs;

  DateTime get baslangic =>
      DateTime.fromMillisecondsSinceEpoch(baslangicMs);

  DateTime get bitisKayitli => DateTime.fromMillisecondsSinceEpoch(bitisMs);

  /// Halen görevdeyse bitiş bugün kabul edilir.
  DateTime get bitis =>
      halenGorevde ? DateTime.now() : bitisKayitli;

  int guncelGunSayisi() {
    if (halenGorevde) {
      return gorevPuaniGunSayisi(baslangic, DateTime.now());
    }
    return gunSayisi;
  }

  double guncelToplamPuan() =>
      gorevPuaniToplam(gunlukPuan, guncelGunSayisi());

  Map<String, dynamic> toJson() => {
        'id': id,
        'yer': yer,
        'gunlukPuan': gunlukPuan,
        'baslangicMs': baslangicMs,
        'bitisMs': bitisMs,
        'gunSayisi': gunSayisi,
        'toplamPuan': toplamPuan,
        'halenGorevde': halenGorevde,
        'olusturulmaMs': olusturulmaMs,
      };

  factory GorevPuaniKaydi.fromJson(Map<String, dynamic> j) => GorevPuaniKaydi(
        id: j['id'] as String? ?? '',
        yer: j['yer'] as String? ?? '',
        gunlukPuan: (j['gunlukPuan'] as num?)?.toDouble() ?? 0,
        baslangicMs: (j['baslangicMs'] as num?)?.toInt() ?? 0,
        bitisMs: (j['bitisMs'] as num?)?.toInt() ?? 0,
        gunSayisi: (j['gunSayisi'] as num?)?.toInt() ?? 0,
        toplamPuan: (j['toplamPuan'] as num?)?.toDouble() ?? 0,
        halenGorevde: j['halenGorevde'] as bool? ?? false,
        olusturulmaMs: (j['olusturulmaMs'] as num?)?.toInt() ?? 0,
      );
}

const _kayitlarKey = 'gorev_puani_kayitlari_v1';

final gorevPuaniKayitVersionProvider = StateProvider<int>((ref) => 0);

final gorevPuaniKayitlariProvider =
    FutureProvider<List<GorevPuaniKaydi>>((ref) async {
  ref.watch(gorevPuaniKayitVersionProvider);
  return _readKayitlar();
});

/// Kayıtlı dönemlerin güncel genel toplamı.
final gorevPuaniGenelToplamProvider = Provider<double>((ref) {
  final kayitlar = ref.watch(gorevPuaniKayitlariProvider).valueOrNull;
  if (kayitlar == null || kayitlar.isEmpty) return 0;
  return gorevPuaniGenelToplam(
    kayitlar.map((k) => k.guncelToplamPuan()),
  );
});

Future<List<GorevPuaniKaydi>> _readKayitlar() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kayitlarKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(GorevPuaniKaydi.fromJson)
        .toList()
      ..sort((a, b) => b.baslangicMs.compareTo(a.baslangicMs));
  } catch (_) {
    return [];
  }
}

Future<void> gorevPuaniKayitEkle(WidgetRef ref, GorevPuaniKaydi kayit) async {
  final list = await _readKayitlar();
  list.add(kayit);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kayitlarKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
  ref.read(gorevPuaniKayitVersionProvider.notifier).state++;
}

Future<void> gorevPuaniKayitSil(WidgetRef ref, String id) async {
  final list = (await _readKayitlar()).where((e) => e.id != id).toList();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kayitlarKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
  ref.read(gorevPuaniKayitVersionProvider.notifier).state++;
}

String gorevPuaniKayitId() =>
    'gorev_puani_${DateTime.now().microsecondsSinceEpoch}';
