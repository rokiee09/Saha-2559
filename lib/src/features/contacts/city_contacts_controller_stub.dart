import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/phone/phone_dial_handler.dart';
import '../../data/models/city_contact.dart';

final cityContactsProvider =
    FutureProvider<List<CityContact>>((ref) async {
  final jsonStr =
      await rootBundle.loadString('assets/json/city_contacts.json');
  final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
  return raw.map((e) {
    final map = e as Map<String, dynamic>;
    final c = CityContact()
      ..cityName = map['cityName'] as String
      ..phone = map['phone'] as String
      ..address = map['address'] as String?
      ..sourceUrl = map['sourceUrl'] as String?
      ..directorName = map['directorName'] as String?;
    return c;
  }).toList();
});

Future<void> callPhone(String phone, {BuildContext? context}) async {
  if (kIsWeb) {
    if (context == null || !context.mounted) {
      return;
    }
    await dialOrShowNumberDialog(context, phone: phone, placeName: 'İl emniyet');
    return;
  }
  final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openSourceUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri);
}
