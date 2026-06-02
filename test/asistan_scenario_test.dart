import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:coderipple/src/features/asistan/asistan_domain.dart';
import 'package:coderipple/src/features/asistan/asistan_provider.dart';

List<AsistanScenario> _loadScenarios() {
  final file = File('assets/asistan/scenarios.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final list = (json['scenarios'] as List<dynamic>).cast<Map<String, dynamic>>();
  return list.map(AsistanScenario.fromJson).toList();
}

void main() {
  group('asistanQueryInScope', () {
    final scenarios = _loadScenarios();

    test('uzmanlık alanı içi sorgular', () {
      expect(asistanQueryInScope('refakat izni', scenarios), isTrue);
      expect(asistanQueryInScope('görev puanı tayin', scenarios), isTrue);
      expect(asistanQueryInScope('lojman puanı', scenarios), isTrue);
    });

    test('genel sohbet dışı', () {
      expect(asistanQueryInScope('bugün hava nasıl', scenarios), isFalse);
      expect(asistanQueryInScope('yemek tarifi', scenarios), isFalse);
    });
  });

  group('asistanMatchScenario', () {
    final scenarios = _loadScenarios();

    test('senaryo eşleşmesi', () {
      expect(
        asistanMatchScenario('PVSK zor kullanma', scenarios)?.id,
        'zor-kullanma',
      );
      expect(
        asistanMatchScenario('lojman puanı', scenarios)?.domain,
        AsistanDomain.lojman,
      );
    });

    test('yapılandırılmış alanlar dolu', () {
      final s = asistanMatchScenario('yıllık izin', scenarios)!;
      expect(s.summary.startsWith(asistanLegalPrefix), isTrue);
      expect(s.appContext, isNotEmpty);
      expect(s.source, isNotEmpty);
    });
  });
}
