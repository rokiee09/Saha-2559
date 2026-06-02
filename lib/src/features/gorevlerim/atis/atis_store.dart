import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'atis_models.dart';

const _prefsKey = 'atis_takip_v1';

Future<List<AtisKayit>> atisLoadAll() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_prefsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(AtisKayit.fromJson)
        .toList()
      ..sort((a, b) {
        final y = b.yil.compareTo(a.yil);
        if (y != 0) return y;
        return b.donem.compareTo(a.donem);
      });
  } catch (_) {
    return [];
  }
}

Future<void> _saveAll(List<AtisKayit> list) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _prefsKey,
    jsonEncode(list.map((e) => e.toJson()).toList()),
  );
}

Future<void> atisUpsert(AtisKayit entry) async {
  final list = await atisLoadAll();
  list.removeWhere((e) => e.yil == entry.yil && e.donem == entry.donem);
  list.removeWhere((e) => e.id == entry.id);
  list.add(entry);
  await _saveAll(list);
}

Future<void> atisDelete(String id) async {
  final list = await atisLoadAll();
  await _saveAll(list.where((e) => e.id != id).toList());
}

String atisGenerateId() => 'atis_${DateTime.now().microsecondsSinceEpoch}';

AtisKayit? atisKayitForDonem(List<AtisKayit> all, int yil, int donem) {
  for (final k in all) {
    if (k.yil == yil && k.donem == donem) return k;
  }
  return null;
}
