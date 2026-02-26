import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/city_contact.dart';

final cityContactsProvider =
    FutureProvider<List<CityContact>>((ref) async => []);

Future<void> callPhone(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri);
}

Future<void> openSourceUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri);
}
