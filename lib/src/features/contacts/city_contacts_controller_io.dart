import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/city_contact.dart';
import 'city_contacts_loader.dart';

export 'city_contacts_loader.dart'
    show loadCityContactsFromAsset, loadCityContactPlateCodes;

final cityContactPlateCodesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  return loadCityContactPlateCodes();
});

/// 81 il — her zaman paketteki JSON'dan okunur (Isar yalnızca yedek/harita için).
final cityContactsProvider =
    FutureProvider<List<CityContact>>((ref) async {
  final plates = await loadCityContactPlateCodes();
  final fromAsset = await loadCityContactsFromAsset();
  await _trySeedIsar(fromAsset);
  return sortCityContactsByPlate(fromAsset, plates);
});

Future<void> _trySeedIsar(List<CityContact> contacts) async {
  if (contacts.isEmpty) return;
  try {
    final isar = IsarService.db;
    final count = await isar.cityContacts.count();
    if (count > 0) return;
    await isar.writeTxn(() async {
      await isar.cityContacts.putAll(contacts);
    });
  } catch (_) {
    // Isar yoksa liste yine JSON'dan gelir.
  }
}

Future<void> callPhone(String phone, {BuildContext? context}) async {
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openSourceUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri);
}
