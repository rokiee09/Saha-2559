import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../data/models/city_contact.dart';

const kCityContactsAssetPath = 'assets/json/city_contacts.json';

Future<List<CityContact>> loadCityContactsFromAsset() async {
  final jsonStr = await rootBundle.loadString(kCityContactsAssetPath);
  final raw = jsonDecode(jsonStr) as List<dynamic>;
  return raw.map((e) {
    final map = e as Map<String, dynamic>;
    return CityContact()
      ..cityName = map['cityName'] as String
      ..phone = map['phone'] as String
      ..address = map['address'] as String?
      ..sourceUrl = map['sourceUrl'] as String?
      ..directorName = map['directorName'] as String?;
  }).toList(growable: false);
}

Future<Map<String, String>> loadCityContactPlateCodes() async {
  final jsonStr = await rootBundle.loadString(kCityContactsAssetPath);
  final raw = jsonDecode(jsonStr) as List<dynamic>;
  return {
    for (final e in raw)
      (e as Map<String, dynamic>)['cityName'] as String:
          (e['plateCode'] as String?) ?? '',
  };
}

List<CityContact> sortCityContactsByPlate(
  List<CityContact> contacts,
  Map<String, String> plateByCity,
) {
  final sorted = [...contacts];
  int plateOrder(String city) =>
      int.tryParse(plateByCity[city] ?? '') ?? 999;
  sorted.sort((a, b) {
    final cmp = plateOrder(a.cityName).compareTo(plateOrder(b.cityName));
    if (cmp != 0) return cmp;
    return a.cityName.compareTo(b.cityName);
  });
  return sorted;
}
