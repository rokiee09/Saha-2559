import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/mevzuat/mevzuat_provider.dart';

/// Disk üzerindeki gerçek mevzuat asset'lerini doğrular.
/// (flutter test, paket kökünden çalışır; göreli yollar geçerlidir.)
void main() {
  const baseDir = 'assets/mevzuat';
  const catalogPath = '$baseDir/catalog.json';

  late MevzuatCatalog catalog;
  late List<MevzuatEntry> allEntries;

  setUpAll(() {
    final raw = File(catalogPath).readAsStringSync();
    catalog = MevzuatCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    allEntries = [...catalog.kanunlar, ...catalog.yonetmelikler];
  });

  test('katalog boş değil ve hem kanun hem yönetmelik içerir', () {
    expect(catalog.kanunlar, isNotEmpty);
    expect(catalog.yonetmelikler, isNotEmpty);
  });

  test('her katalog girişinin id ve path değeri dolu', () {
    for (final e in allEntries) {
      expect(e.id.trim(), isNotEmpty, reason: 'boş id: ${e.name}');
      expect(e.path.trim(), isNotEmpty, reason: 'boş path: ${e.id}');
    }
  });

  test('katalog id değerleri benzersiz', () {
    final ids = allEntries.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'tekrarlı id var');
  });

  test('her path gerçekten var olan bir dosyaya işaret eder', () {
    for (final e in allEntries) {
      final f = File('$baseDir/${e.path}');
      expect(f.existsSync(), isTrue, reason: 'dosya yok: ${e.path}');
    }
  });

  test('tüm madde dosyaları parse olur ve maddeleri tutarlıdır', () {
    var totalArticles = 0;
    for (final e in allEntries) {
      final raw = File('$baseDir/${e.path}').readAsStringSync();
      final doc = MevzuatDocumentData.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        entry: e,
      );
      expect(doc.sections, isNotEmpty, reason: '${e.id} maddesiz');
      for (final s in doc.sections) {
        expect(s.article.trim(), isNotEmpty,
            reason: '${e.id}: boş "article"');
        expect(s.text.trim(), isNotEmpty,
            reason: '${e.id}/${s.article}: boş "text"');
      }
      totalArticles += doc.sections.length;
    }
    expect(totalArticles, greaterThan(500));
  });
}
