import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:coderipple/src/features/asistan/asistan_provider.dart';

/// concepts.json'u dosyadan (asset değil) okuyup AsistanConcept listesine çevirir.
List<AsistanConcept> _loadConcepts() {
  final file = File('assets/asistan/concepts.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final list = (json['concepts'] as List<dynamic>).cast<Map<String, dynamic>>();
  return list.map(AsistanConcept.fromJson).toList();
}

void main() {
  group('asistanFold', () {
    test('Türkçe karakterleri sadeleştirir', () {
      expect(asistanFold('Güç Kullanma'), 'guc kullanma');
      expect(asistanFold('İFADE'), 'ifade');
      expect(asistanFold('Şırnak'), 'sirnak');
    });
  });

  group('asistanMatchConcept', () {
    final concepts = _loadConcepts();

    test('konseptler yüklendi', () {
      expect(concepts.length, greaterThanOrEqualTo(10));
    });

    test('doğal dildeki sorular doğru kavrama bağlanır', () {
      String? matchId(String q) => asistanMatchConcept(q, concepts)?.id;

      expect(matchId('polise hakaret'), 'mukavemet-hakaret');
      expect(matchId('Refakat izni kaç gün'), 'refakat-izni');
      expect(matchId('yakalama yaparken avukat gerekir mi'), 'yakalama');
      expect(matchId('PVSK zor kullanma'), 'zor-kullanma');
      expect(matchId('güç kullanma ne zaman'), 'zor-kullanma');
      expect(matchId('durdurma ve kimlik sorma'), 'durdurma-kimlik');
      expect(matchId('yıllık izin kaç gün'), 'yillik-izin');
    });

    test('alakasız sorgu kavram döndürmez', () {
      expect(asistanMatchConcept('bugün hava nasıl', concepts), isNull);
      expect(asistanMatchConcept('', concepts), isNull);
    });
  });

  group('concepts.json veri bütünlüğü (deep-link)', () {
    final concepts = _loadConcepts();

    // catalog: entryId -> path
    final catalog = jsonDecode(
      File('assets/mevzuat/catalog.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final entryPaths = <String, String>{};
    for (final group in ['kanunlar', 'yonetmelikler']) {
      for (final e in (catalog[group] as List<dynamic>)) {
        final m = e as Map<String, dynamic>;
        entryPaths[m['id'] as String] = m['path'] as String;
      }
    }

    final sectionCache = <String, Set<String>>{};
    Set<String> sectionIds(String entryId) {
      return sectionCache.putIfAbsent(entryId, () {
        final path = entryPaths[entryId];
        if (path == null) return <String>{};
        final doc = jsonDecode(
          File('assets/mevzuat/$path').readAsStringSync(),
        ) as Map<String, dynamic>;
        final articles = (doc['articles'] as List<dynamic>?) ?? const [];
        return {
          for (final a in articles) (a as Map<String, dynamic>)['id'] as String,
        };
      });
    }

    test('her ref entryId katalogda var', () {
      for (final c in concepts) {
        for (final r in c.refs) {
          expect(
            entryPaths.containsKey(r.entryId),
            isTrue,
            reason: '${c.id} -> bilinmeyen entryId: ${r.entryId}',
          );
        }
      }
    });

    test('sectionId verilen her ref ilgili kanunda gerçekten var', () {
      for (final c in concepts) {
        for (final r in c.refs) {
          final sid = r.sectionId;
          if (sid == null) continue;
          expect(
            sectionIds(r.entryId).contains(sid),
            isTrue,
            reason: '${c.id} -> ${r.entryId} içinde bulunamayan madde: $sid',
          );
        }
      }
    });
  });
}
