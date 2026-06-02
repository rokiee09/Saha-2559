import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../data/models/martyr.dart';

const kMartyrsAssetPath = 'assets/json/martyrs.json';

/// Paketteki JSON — kararlı `id` (1…n), detay sayfası ile liste aynı kaynaktan.
Future<List<Martyr>> loadMartyrsFromAsset() async {
  final jsonStr = await rootBundle.loadString(kMartyrsAssetPath);
  return parseMartyrsFromJson(jsonStr);
}

List<Martyr> parseMartyrsFromJson(String jsonStr) {
  final raw = jsonDecode(jsonStr) as List<dynamic>;
  final list = <Martyr>[];
  for (var i = 0; i < raw.length; i++) {
    final map = raw[i] as Map<String, dynamic>;
    final m = Martyr()
      ..id = i + 1
      ..fullName = map['fullName'] as String
      ..cityName = map['cityName'] as String;

    final dateRaw = map['dateOfMartyrdom'];
    if (dateRaw is String && dateRaw.trim().isNotEmpty) {
      m.dateOfMartyrdom = DateTime.tryParse(dateRaw);
    }
    list.add(m);
  }
  return list;
}

List<Martyr> filterMartyrs({
  required List<Martyr> all,
  String? city,
  String nameQuery = '',
}) {
  final q = nameQuery.trim().toLowerCase();
  final hasCity = city != null && city.isNotEmpty;
  final hasName = q.isNotEmpty;

  Iterable<Martyr> items = all;
  if (hasCity) {
    items = items.where((m) => m.cityName == city);
  }
  if (hasName) {
    items = items.where((m) => m.fullName.toLowerCase().contains(q));
  }

  final sorted = items.toList()
    ..sort((a, b) {
      final da = a.dateOfMartyrdom;
      final db = b.dateOfMartyrdom;
      if (da == null && db == null) {
        return a.fullName.compareTo(b.fullName);
      }
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
  return sorted;
}

List<String> martyrCityNames(List<Martyr> all) {
  final set = all.map((m) => m.cityName).toSet()..remove('');
  final list = set.toList()..sort();
  return list;
}

String formatMartyrDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final mo = local.month.toString().padLeft(2, '0');
  return '$d.$mo.${local.year}';
}
