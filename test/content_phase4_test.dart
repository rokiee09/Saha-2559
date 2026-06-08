import 'package:flutter_test/flutter_test.dart';

import 'package:coderipple/src/features/araclar/dilekce/dilekce_templates.dart';
import 'package:coderipple/src/features/araclar/emsal/emsal_rehberi_data.dart';
import 'package:coderipple/src/features/araclar/mutalaa/mutalaa_ozel_data.dart';
import 'package:coderipple/src/features/araclar/trafik/trafik_rehberi_data.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_decision_engine.dart';
import 'package:coderipple/src/features/asistan/decision_support/legal_knowledge_index.dart';
import 'package:coderipple/src/features/asistan/legal/assistant_content_index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('Mütalaa JSON yüklenir ve soru-cevap alanları dolu', () async {
    final set = await loadMutalaaOzelSet();
    expect(set.kayitlar.length, greaterThanOrEqualTo(300));
    expect(set.kayitlar.every((k) => k.cevapMetni.isNotEmpty), isTrue);
    expect(set.kayitlar.every((k) => k.soruMetni.isNotEmpty), isTrue);
  });

  test('Mütalaa arama cevap metninde de eşleşir', () async {
    final set = await loadMutalaaOzelSet();
    final hits = mutalaaEslestir('muvafakat naklen atanma', set.kayitlar);
    expect(hits, isNotEmpty);
    expect(hits.first.cevapMetni.toLowerCase(), contains('muvafakat'));
  });

  test('Mütalaa indeksi asistan cevabında görüş özetini kullanır', () async {
    final set = await loadMutalaaOzelSet();
    final records = legalIndexFromMutalaaOzel(set.kayitlar)
        .map(LegalKnowledgeRecord.fromIndexRecord)
        .toList();
    expect(records, isNotEmpty);
    final sample = records.first;
    expect(
      sample.summary,
      isNot(contains('bilgi talep edilen dilekçe incelenmiştir')),
    );
    expect(sample.tags, contains('mutalaa_ozel'));

    final engine = LegalDecisionEngine(index: records);
    final answer = await engine.answer(
      'Aday memur KPSS ile başka kuruma muvafakatla atanabilir mi?',
    );
    expect(answer.noStrongMatch, isFalse);
    expect(
      answer.topHits.any((h) => h.record.id.startsWith('mutalaa_')),
      isTrue,
    );
    final hit = answer.topHits.firstWhere(
      (h) => h.record.id.startsWith('mutalaa_'),
    );
    expect(hit.record.sourceName, contains('DPB'));
    expect(
      hit.record.summary.toLowerCase(),
      isNot(contains('dilekçe incelenmiştir')),
    );
  });
}
