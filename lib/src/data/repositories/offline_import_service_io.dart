import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../db/isar_service.dart';
import '../models/city_contact.dart';
import '../models/field_card.dart';
import '../models/martyr.dart';
import 'law_repository.dart';

class OfflineImportService {
  static Future<void> importAll() async {
    await Future.wait([
      _importLawArticles(),
      _importCityContacts(),
      _importMartyrs(),
      _importFieldCards(),
    ]);
  }

  static Future<void> _importLawArticles() async {
    final jsonStr =
        await rootBundle.loadString('assets/json/law_articles.json');
    final repo = LawRepository();
    await repo.importFromJsonString(jsonStr);
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
        ..sourceUrl = map['sourceUrl'] as String?;
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

  static Future<void> _importFieldCards() async {
    final jsonStr =
        await rootBundle.loadString('assets/json/field_cards.json');
    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
    final cards = raw.map((e) {
      final map = e as Map<String, dynamic>;
      final c = FieldCard()
        ..title = map['title'] as String
        ..description = map['description'] as String
        ..lawRef = map['lawRef'] as String?
        ..iconKey = map['iconKey'] as String?;
      return c;
    }).toList(growable: false);

    final isar = IsarService.db;
    await isar.writeTxn(() async {
      await isar.fieldCards.clear();
      await isar.fieldCards.putAll(cards);
    });
  }
}
