// Web'de şehit listesi assets/json/martyrs.json'dan; Isar yok.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';

final webMartyrsProvider = FutureProvider<List<Martyr>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/json/martyrs.json');
  return _parseMartyrsFromJson(jsonStr);
});

List<Martyr> _parseMartyrsFromJson(String jsonStr) {
  final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
  final list = <Martyr>[];
  for (var i = 0; i < raw.length; i++) {
    final map = raw[i] as Map<String, dynamic>;
    final m = Martyr()
      ..id = i + 1
      ..fullName = map['fullName'] as String
      ..cityName = map['cityName'] as String;

    final dateRaw = map['dateOfMartyrdom'];
    if (dateRaw is String && dateRaw.toString().trim().isNotEmpty) {
      m.dateOfMartyrdom = DateTime.tryParse(dateRaw.toString());
    }
    list.add(m);
  }
  return list;
}
