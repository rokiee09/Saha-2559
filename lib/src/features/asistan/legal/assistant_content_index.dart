import '../../araclar/dilekce/dilekce_templates.dart';
import '../../araclar/emsal/emsal_rehberi_data.dart';
import '../../araclar/mutalaa/mutalaa_ozel_data.dart';
import '../../araclar/trafik/trafik_rehberi_data.dart';
import 'assistant_legal_index.dart';

List<LegalIndexRecord> legalIndexFromDilekceTemplates() {
  return DilekceTemplate.all.map((t) {
    return LegalIndexRecord(
      id: 'dilekce_${t.id}',
      sourceType: LegalSourceType.rehber,
      sourceName: 'SAHA 2559 · Dilekçe Merkezi',
      articleNo: 'Taslak',
      title: t.title,
      summary:
          '${t.title} — Araçlar → Dilekçe Merkezi\'nde doldurulabilir taslak.',
      fullText: '${t.title}\n${t.description}',
      keywords: [
        t.title,
        'dilekce',
        'dilekçe',
        'talep',
        'yazı',
        'basvuru',
        'savunma',
        'izin talebi',
      ],
      synonyms: const ['dilekce', 'yazi', 'form'],
      tags: ['dilekce', 'personel', 'uygulama'],
      moduleRoute: 'dilekce',
      explanation:
          'Şablonu doldurup panoya kopyalayın; birim formatına göre düzenleyin. '
          'Resmî evrak yerine geçmez.',
      isAppGuide: true,
    );
  }).toList();
}

List<LegalIndexRecord> legalIndexFromEmsal() {
  return kEmsalKayitlari.map((e) {
    return LegalIndexRecord(
      id: 'emsal_${e.id}',
      sourceType: LegalSourceType.rehber,
      sourceName: 'SAHA 2559 · Emsal özetleri',
      articleNo: 'Uygulama özeti',
      title: e.title,
      summary: e.summary,
      fullText: '${e.situation}\n${e.summary}\n${e.checklist.join('\n')}',
      keywords: e.keywords,
      synonyms: const ['emsal', 'uygulama', 'ornek', 'ozet'],
      tags: [...e.tags, 'emsal', 'uygulama'],
      moduleRoute: 'emsal',
      entryId: e.mevzuatRefs.isNotEmpty ? e.mevzuatRefs.first.entryId : null,
      sectionId: e.mevzuatRefs.isNotEmpty ? e.mevzuatRefs.first.sectionId : null,
      riskNote: e.riskNote,
      explanation:
          'Anonim uygulama özeti; yargı kararı değildir. Araçlar → Emsal özetleri.',
      isAppGuide: true,
      isPriority: e.id == 'yediemin_teslim',
    );
  }).toList();
}

List<LegalIndexRecord> legalIndexFromMutalaaOzel(List<MutalaaKayit> kayitlar) {
  return kayitlar.map((m) {
    final soru = m.soruMetni;
    final cevap = m.cevapMetni;
    final full = StringBuffer()
      ..writeln(m.baslik)
      ..writeln()
      ..writeln(soru);
    if (cevap.isNotEmpty) {
      full.writeln('\nGörüş: $cevap\n');
    }
    full.write(m.metin);
    return LegalIndexRecord(
      id: 'mutalaa_${m.id}',
      sourceType: LegalSourceType.rehber,
      sourceName: 'DPB · Mütalaalar Özel Bülteni',
      articleNo: m.ref.isNotEmpty ? m.ref : 'Mütalaa',
      title: m.baslik.length > 120
          ? '${m.baslik.substring(0, 117)}…'
          : m.baslik,
      summary: soru.isNotEmpty ? soru : m.ozet,
      fullText: full.toString().trim(),
      keywords: [
        ...m.keywords,
        'mutalaa',
        'dpb',
        'personel',
        if (m.ref.isNotEmpty) m.ref,
      ],
      synonyms: const [
        'mutalaa',
        'mütalaa',
        'dpb',
        'devlet personel',
        'gorus',
      ],
      tags: ['mutalaa_ozel', 'personel', 'dpb'],
      moduleRoute: 'mutalaa_ozel',
      explanation:
          'DPB görüş özetidir; güncel mevzuatla birlikte kullanın. '
          'Araçlar → Mütalaa Özel.',
      isAppGuide: true,
      riskNote: cevap.isNotEmpty
          ? cevap
          : 'Görüşün güncelliğini mevzuatla doğrulayın.',
    );
  }).toList();
}

List<LegalIndexRecord> legalIndexFromTrafik() {
  return kTrafikKonulari.map((t) {
    return LegalIndexRecord(
      id: 'trafik_${t.id}',
      sourceType: LegalSourceType.rehber,
      sourceName: 'SAHA 2559 · Trafik rehberi',
      articleNo: 'Kontrol listesi',
      title: t.title,
      summary: t.summary,
      fullText:
          '${t.summary}\n${t.steps.map((s) => '${s.title}: ${s.detail}').join('\n')}',
      keywords: t.keywords,
      synonyms: const ['trafik', 'kara yollari', 'surucu', 'arac'],
      tags: ['trafik', 'uygulama'],
      moduleRoute: t.moduleRoute ?? 'trafik',
      explanation:
          'Adım adım kontrol listesi Araçlar → Trafik rehberi\'nde. '
          '${t.mevzuatNote}',
      isAppGuide: true,
    );
  }).toList();
}
