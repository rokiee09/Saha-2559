import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/saglik/saglik_metin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('saglik JSON assets', () {
    test('emniyet sağlık şartları loads', () async {
      final raw = await rootBundle.loadString(
        SaglikMetinId.emniyetSaglikSartlari.assetPath,
      );
      final doc = SaglikMetinBelge.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      expect(doc.sections, isNotEmpty);
      expect(doc.sections.first.article, startsWith('EK-'));
    });

    test('sağlık uygulamaları loads without evrak header', () async {
      final raw = await rootBundle.loadString(
        SaglikMetinId.saglikUygulamalari.assetPath,
      );
      final doc = SaglikMetinBelge.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      expect(doc.disclaimer, isNotNull);
      expect(doc.sections.length, greaterThan(20));
      final joined = doc.sections.map((s) => s.text).join('\n');
      expect(joined.contains('EBYS-'), isFalse);
      expect(joined.contains('95074581'), isFalse);
      expect(joined.contains('DAĞITIM YERLERİNE'), isFalse);
    });
  });
}
