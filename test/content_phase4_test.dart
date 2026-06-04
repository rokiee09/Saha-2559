import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/dilekce/dilekce_templates.dart';
import 'package:coderipple/src/features/araclar/emsal/emsal_rehberi_data.dart';
import 'package:coderipple/src/features/araclar/trafik/trafik_rehberi_data.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_content_index.dart';

void main() {
  test('Dilekçe şablonları metin üretir', () {
    final t = DilekceTemplate.byId('yillik_izin')!;
    final text = t.build({
      'birim': 'X İl Emniyet',
      'unvan': 'Polis Memuru',
      'adSoyad': 'A. Yılmaz',
      'sicil': '12345',
      'baslangic': '01.07.2026',
      'bitis': '15.07.2026',
      'gun': '15',
    });
    expect(text, contains('Yıllık izin'));
    expect(text, contains('A. Yılmaz'));
  });

  test('Emsal eşleştirme yediemin', () {
    final hits = emsalEslestir('yediemin savcı');
    expect(hits, isNotEmpty);
    expect(hits.first.id, 'yediemin_teslim');
  });

  test('Trafik konuları ve eşleştirme', () {
    expect(kTrafikKonulari.length, greaterThanOrEqualTo(5));
    expect(trafikEslestir('alkol'), isNotEmpty);
  });

  test('İçerik indeksi asistan kayıtları üretir', () {
    final dilekce = legalIndexFromDilekceTemplates();
    final emsal = legalIndexFromEmsal();
    final trafik = legalIndexFromTrafik();
    expect(dilekce.length, DilekceTemplate.all.length);
    expect(emsal.length, kEmsalKayitlari.length);
    expect(trafik.length, kTrafikKonulari.length);
    expect(emsal.any((r) => r.moduleRoute == 'emsal'), isTrue);
  });
}
