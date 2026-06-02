import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/phone/phone_dial_handler.dart';
import '../../data/models/city_contact.dart';
import 'city_contacts_loader.dart';

export 'city_contacts_loader.dart'
    show loadCityContactsFromAsset, loadCityContactPlateCodes;

final cityContactPlateCodesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  return loadCityContactPlateCodes();
});

final cityContactsProvider =
    FutureProvider<List<CityContact>>((ref) async {
  final plates = await loadCityContactPlateCodes();
  final fromAsset = await loadCityContactsFromAsset();
  return sortCityContactsByPlate(fromAsset, plates);
});

Future<void> callPhone(String phone, {BuildContext? context}) async {
  if (context == null || !context.mounted) {
    return;
  }
  await dialOrShowNumberDialog(context, phone: phone, placeName: 'İl emniyet');
}

Future<void> openSourceUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri);
}
