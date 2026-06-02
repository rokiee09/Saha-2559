import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _key = 'tutanak_template_usage_v1';

/// Şablon kullanım sayıları — favori sıralama için cihazda tutulur.
class TutanakFavoritesStore {
  TutanakFavoritesStore._();

  static Future<Map<String, int>> loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (k, v) => MapEntry(k.toString(), v is int ? v : int.tryParse('$v') ?? 0),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> recordUse(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = await loadCounts();
    counts[templateId] = (counts[templateId] ?? 0) + 1;
    await prefs.setString(_key, jsonEncode(counts));
  }

  static List<String> sortByUsage(
    List<String> templateIds,
    Map<String, int> counts,
  ) {
    final ids = [...templateIds];
    ids.sort((a, b) {
      final ca = counts[a] ?? 0;
      final cb = counts[b] ?? 0;
      if (ca != cb) return cb.compareTo(ca);
      return a.compareTo(b);
    });
    return ids;
  }
}
