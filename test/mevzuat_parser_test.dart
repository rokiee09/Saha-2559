import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/mevzuat/mevzuat_provider.dart';

void main() {
  group('MevzuatCatalog.fromJson', () {
    test('kanun ve yönetmelikleri kategorileyerek ayrıştırır', () {
      final catalog = MevzuatCatalog.fromJson({
        'kanunlar': [
          {
            'id': 'kanun-pvsk',
            'code': '2559',
            'name': 'Polis Vazife ve Salahiyet Kanunu',
            'path': 'kanunlar/pvsk.json',
            'sourceUrl': 'https://www.mevzuat.gov.tr/x',
          },
        ],
        'yonetmelikler': [
          {
            'id': 'yon-ornek',
            'name': 'Örnek Yönetmelik',
            'path': 'yonetmelikler/ornek.json',
          },
        ],
      });

      expect(catalog.kanunlar, hasLength(1));
      expect(catalog.yonetmelikler, hasLength(1));
      expect(catalog.kanunlar.first.category, 'kanun');
      expect(catalog.yonetmelikler.first.category, 'yonetmelik');
    });

    test('eksik anahtarlarda boş listelere düşer', () {
      final catalog = MevzuatCatalog.fromJson({});
      expect(catalog.kanunlar, isEmpty);
      expect(catalog.yonetmelikler, isEmpty);
    });
  });

  group('MevzuatEntry', () {
    test('code varsa displayTitle koda göre kurulur', () {
      final e = MevzuatEntry.fromJson(
        {
          'id': 'kanun-pvsk',
          'code': '2559',
          'name': 'Polis Vazife ve Salahiyet Kanunu',
          'path': 'kanunlar/pvsk.json',
        },
        category: 'kanun',
      );

      expect(e.displayTitle, '2559 Polis Vazife ve Salahiyet Kanunu');
      expect(e.categoryLabel, 'Kanun');
      expect(e.catalogTag, 'PVSK'); // id son segmenti büyük harf
      // sourceUrl verilmezse varsayılan mevzuat.gov.tr.
      expect(e.sourceUrl, contains('mevzuat.gov.tr'));
    });

    test('code yoksa displayTitle yalnızca ad olur', () {
      final e = MevzuatEntry.fromJson(
        {'id': 'yon-ornek', 'name': 'Örnek Yönetmelik', 'path': 'x.json'},
        category: 'yonetmelik',
      );

      expect(e.displayTitle, 'Örnek Yönetmelik');
      expect(e.categoryLabel, 'Yönetmelik');
    });
  });

  group('MevzuatDocumentData.fromJson', () {
    final entry = MevzuatEntry(
      id: 'kanun-pvsk',
      code: '2559',
      name: 'PVSK',
      path: 'kanunlar/pvsk.json',
      category: 'kanun',
      sourceUrl: 'https://www.mevzuat.gov.tr/x',
    );

    test('articles -> sections olarak ayrıştırılır', () {
      final doc = MevzuatDocumentData.fromJson(
        {
          'law': 'PVSK',
          'source': 'mevzuat.gov.tr',
          'lastContentReview': '2024-01-01',
          'articles': [
            {'id': 'm16', 'article': 'Madde 16', 'title': 'Zor kullanma', 'text': '...'},
            {'id': 'm17', 'article': 'Madde 17', 'title': 'Yakalama', 'text': '...'},
          ],
        },
        entry: entry,
      );

      expect(doc.sections, hasLength(2));
      expect(doc.sections.first.article, 'Madde 16');
      expect(doc.lastContentReview, '2024-01-01');
    });

    test('lastContentReview yoksa sonKontrolTarihi alanına düşer', () {
      final doc = MevzuatDocumentData.fromJson(
        {
          'articles': [],
          'sonKontrolTarihi': '2023-05-05',
        },
        entry: entry,
      );

      expect(doc.lastContentReview, '2023-05-05');
      // law verilmezse entry.name kullanılır.
      expect(doc.law, 'PVSK');
    });

    test('empty fabrikası boş ama tutarlı bir belge verir', () {
      final doc = MevzuatDocumentData.empty(entry);
      expect(doc.sections, isEmpty);
      expect(doc.sourceUrl, entry.sourceUrl);
    });
  });

  group('MevzuatSection.fromJson', () {
    test('eksik kaynakta varsayılan mevzuat.gov.tr olur', () {
      final s = MevzuatSection.fromJson({
        'id': 'm1',
        'article': 'Madde 1',
        'title': 'Amaç',
        'text': 'Bu Kanunun amacı...',
      });

      expect(s.source, 'mevzuat.gov.tr');
      expect(s.lastReviewed, isNull);
    });
  });
}
