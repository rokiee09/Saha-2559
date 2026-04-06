import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../db/isar_service.dart';
import '../models/city_contact.dart';
import '../models/martyr.dart';

class OfflineImportService {
  static Future<void> importAll() async {
    await Future.wait([
      _importCityContacts(),
      _importMartyrs(),
    ]);
  }

  static Future<void> _importCityContacts() async {
    final jsonStr =
        await rootBundle.loadString('assets/json/city_contacts.json');
    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
    final contacts = raw.map((e) {
      final map = e as Map<String, dynamic>;
      final c = CityContact()
        ..cityName = map['cityName'] as String
        ..phone = map['phone'] as String
        ..address = map['address'] as String?
        ..sourceUrl = map['sourceUrl'] as String?
        ..directorName = map['directorName'] as String?;
      return c;
    }).toList(growable: false);

    final isar = IsarService.db;
    await isar.writeTxn(() async {
      await isar.cityContacts.clear();
      await isar.cityContacts.putAll(contacts);
    });
  }

  static Future<void> _importMartyrs() async {
    final jsonStr = await rootBundle.loadString('assets/json/martyrs.json');
    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
    final martyrs = raw.map((e) {
      final map = e as Map<String, dynamic>;
      final m = Martyr()
        ..fullName = map['fullName'] as String
        ..cityName = map['cityName'] as String
        ..location = map['location'] as String?
        ..story = map['story'] as String?;

      final dateRaw = map['dateOfMartyrdom'];
      if (dateRaw is String && dateRaw.isNotEmpty) {
        m.dateOfMartyrdom = DateTime.tryParse(dateRaw);
      }

      return m;
    }).toList(growable: false);

    final isar = IsarService.db;
    await isar.writeTxn(() async {
      await isar.martyrs.clear();
      await isar.martyrs.putAll(martyrs);
    });
  }
}
