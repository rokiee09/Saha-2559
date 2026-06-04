import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/gorev_puanlari/gorev_hizmet_sureleri_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('gorev_hizmet_sureleri_2026.json', () {
    late Map<String, dynamic> root;

    setUpAll(() async {
      final raw = await rootBundle.loadString(
        'assets/json/gorev_hizmet_sureleri_2026.json',
      );
      root = jsonDecode(raw) as Map<String, dynamic>;
    });

    test('yüklenebilir ve kayıt içerir', () {
      final kayitlar = root['kayitlar'] as List<dynamic>;
      expect(kayitlar.length, greaterThan(1000));
      final ilk = GorevHizmetSuresiKayit.fromJson(
        kayitlar.first as Map<String, dynamic>,
      );
      expect(ilk.sn, 1);
      expect(ilk.yer, 'ADANA');
      expect(ilk.bolge, 1);
      expect(ilk.yil, 8);
    });

    test('Ankara merkez 10 yıl', () {
      final kayitlar = (root['kayitlar'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final ankara = kayitlar.firstWhere(
        (k) => k['yer'] == 'ANKARA',
      );
      expect(ankara['yil'], 10);
      expect(ankara['bolge'], 1);
    });
  });
}
