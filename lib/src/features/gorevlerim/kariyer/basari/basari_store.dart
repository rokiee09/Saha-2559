import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../kariyer_profil_provider.dart';
import 'basari_models.dart';

const _key = 'basari_belgeler_v1';
const _legacyKey = 'kariyer_kayitlar_v1';

Future<List<BasariBelge>> _load() async {
  final prefs = await SharedPreferences.getInstance();
  await _migrateLegacy(prefs);
  final raw = prefs.getString(_key);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(BasariBelge.fromJson)
        .toList()
      ..sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  } catch (_) {
    return [];
  }
}

Future<void> _migrateLegacy(SharedPreferences prefs) async {
  if (prefs.getString(_key) != null) return;
  final raw = prefs.getString(_legacyKey);
  if (raw == null || raw.isEmpty) return;
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return;
    final out = <BasariBelge>[];
    for (final row in dec) {
      if (row is! Map<String, dynamic>) continue;
      if (row['tur'] != 'basari') continue;
      final yil = (row['yil'] as num?)?.toInt() ?? 0;
      out.add(BasariBelge(
        id: row['id'] as String? ?? 'm_${out.length}',
        tur: BasariBelgeTuru.basari,
        tarihMs: yil > 0
            ? DateTime(yil).millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch,
        verenMakam: '',
        aciklama: row['not'] as String? ?? '',
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    if (out.isNotEmpty) {
      await prefs.setString(
        _key,
        jsonEncode(out.map((e) => e.toJson()).toList()),
      );
    }
  } catch (_) {}
}

Future<void> _save(List<BasariBelge> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _key,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
}

final basariBelgelerProvider = FutureProvider<List<BasariBelge>>((ref) async {
  ref.watch(kariyerVersionProvider);
  return _load();
});

Future<void> basariUpsert(WidgetRef ref, BasariBelge belge) async {
  final list = await _load();
  list.removeWhere((e) => e.id == belge.id);
  list.add(belge);
  list.sort((a, b) => b.tarihMs.compareTo(a.tarihMs));
  await _save(list);
  ref.read(kariyerVersionProvider.notifier).state++;
}

Future<void> basariDelete(WidgetRef ref, BasariBelge belge) async {
  final list = (await _load()).where((e) => e.id != belge.id).toList();
  await _save(list);
  ref.read(kariyerVersionProvider.notifier).state++;
}

String basariGenerateId() => 'basari_${DateTime.now().microsecondsSinceEpoch}';
