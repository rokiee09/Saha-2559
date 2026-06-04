import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../kariyer_profil_provider.dart';
import 'taltif_models.dart';

const _key = 'taltif_kayitlari_v1';

Future<List<TaltifKayit>> _load() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_key);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(TaltifKayit.fromJson)
        .toList()
      ..sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  } catch (_) {
    return [];
  }
}

Future<void> _save(List<TaltifKayit> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _key,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
}

final taltifKayitlariProvider = FutureProvider<List<TaltifKayit>>((ref) async {
  ref.watch(kariyerVersionProvider);
  return _load();
});

Future<void> taltifUpsert(WidgetRef ref, TaltifKayit kayit) async {
  final list = await _load();
  list.removeWhere((e) => e.id == kayit.id);
  list.add(kayit);
  list.sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  await _save(list);
  ref.read(kariyerVersionProvider.notifier).state++;
}

Future<void> taltifDelete(WidgetRef ref, TaltifKayit kayit) async {
  final list = (await _load()).where((e) => e.id != kayit.id).toList();
  await _save(list);
  ref.read(kariyerVersionProvider.notifier).state++;
}

String taltifGenerateId() => 'taltif_${DateTime.now().microsecondsSinceEpoch}';
