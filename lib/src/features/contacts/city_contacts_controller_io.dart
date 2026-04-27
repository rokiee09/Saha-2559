import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/city_contact.dart';

final cityContactsProvider =
    FutureProvider<List<CityContact>>((ref) async {
  final isar = IsarService.db;
  return await isar.cityContacts.where().sortByCityName().findAll();
});

Future<void> callPhone(String phone, {BuildContext? context}) async {
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openSourceUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri);
}
