import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/contacts/city_contacts_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('city_contacts.json loads 81 provinces', () async {
    final jsonStr = await rootBundle.loadString(kCityContactsAssetPath);
    final raw = jsonDecode(jsonStr) as List<dynamic>;
    expect(raw.length, 81);

    final contacts = await loadCityContactsFromAsset();
    expect(contacts.length, 81);
    expect(contacts.first.cityName, isNotEmpty);
    expect(contacts.first.phone, isNotEmpty);
  });
}
