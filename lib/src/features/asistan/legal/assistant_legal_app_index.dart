import '../../araclar/tutanak/tutanak_templates.dart';
import '../../saglik/saglik_rehberi_data.dart';
import '../search/assistant_help_corpus.dart';
import '../search/assistant_models.dart';
import 'assistant_legal_index.dart';

List<String> _tagsForHelpCategory(AssistantCategory category) {
  return switch (category) {
    AssistantCategory.mevzuat => ['mevzuat', 'uygulama'],
    AssistantCategory.idariParaCeza => ['idari_para_ceza', 'uygulama'],
    AssistantCategory.tutanak => ['tutanak', 'uygulama'],
    AssistantCategory.kariyer => ['kariyer', 'personel', 'uygulama'],
    AssistantCategory.atis => ['atis', 'egitim', 'uygulama'],
    AssistantCategory.basari => ['basari', 'personel', 'uygulama'],
    AssistantCategory.egitim => ['egitim', 'uygulama'],
    AssistantCategory.saglik => ['saglik', 'uygulama'],
    AssistantCategory.uygulamaYardim => ['uygulama'],
  };
}

/// Uygulama yardım metinleri → mevzuat asistan indeksi.
List<LegalIndexRecord> legalIndexFromHelpCorpus() {
  return kAssistantHelpEntries.map((h) {
    final nav = h.nav;
    return LegalIndexRecord(
      id: 'help_${h.id}',
      sourceType: LegalSourceType.rehber,
      sourceName: h.source,
      articleNo: 'Uygulama rehberi',
      title: h.title,
      summary: h.shortAnswer,
      fullText: '${h.shortAnswer}\n${h.appContext}',
      keywords: h.keywords,
      synonyms: const [],
      tags: _tagsForHelpCategory(h.category),
      entryId: nav?.mevzuatEntryId,
      sectionId: nav?.mevzuatSectionId,
      moduleRoute: nav?.moduleRoute,
      saglikKonuId: nav?.saglikKonuId,
      tutanakTemplateId: nav?.tutanakTemplateId,
      explanation: h.appContext,
      isAppGuide: true,
    );
  }).toList();
}

List<LegalIndexRecord> legalIndexFromSaglikRehber() {
  final out = <LegalIndexRecord>[];

  for (final s in kSaglikSenaryolari) {
    out.add(
      LegalIndexRecord(
        id: 'saglik_${s.id}',
        sourceType: LegalSourceType.rehber,
        sourceName: s.mevzuatNotlari.isNotEmpty
            ? s.mevzuatNotlari.first
            : 'Sağlık ve Sosyal Haklar rehberi',
        articleNo: 'Sağlık rehberi',
        title: s.baslik,
        summary: s.ozet,
        fullText: '${s.ozet}\n${s.uygulamada}',
        keywords: s.anahtarlar,
        synonyms: const ['rapor', 'istirahat', 'heyet', 'saglik'],
        tags: ['saglik', 'uygulama'],
        moduleRoute: 'saglik',
        saglikKonuId: s.ilgiliKonu?.id,
        explanation: s.uygulamada,
        isAppGuide: true,
      ),
    );
  }

  for (final konu in SaglikRehberKonu.values) {
    final icerik = rehberIcerik(konu);
    out.add(
      LegalIndexRecord(
        id: 'saglik_konu_${konu.id}',
        sourceType: LegalSourceType.rehber,
        sourceName: 'Sağlık ve Sosyal Haklar',
        articleNo: konu.title,
        title: konu.title,
        summary: icerik.ozet,
        fullText: '${icerik.ozet}\n${icerik.uygulamada}',
        keywords: [konu.title, ...icerik.ozet.split(RegExp(r'\s+')).where((w) => w.length >= 5).take(8)],
        synonyms: const ['saglik', 'rapor', 'rehber'],
        tags: ['saglik', 'uygulama'],
        moduleRoute: 'saglik',
        saglikKonuId: konu.id,
        explanation: icerik.uygulamada,
        isAppGuide: true,
      ),
    );
  }

  return out;
}

List<LegalIndexRecord> legalIndexFromTutanakTemplates() {
  return TutanakTemplate.all.map((t) {
    return LegalIndexRecord(
      id: 'tutanak_${t.id}',
      sourceType: LegalSourceType.rehber,
      sourceName: 'SAHA 2559 · Tutanak Merkezi',
      articleNo: 'Şablon',
      title: t.title,
      summary:
          '${t.title} şablonu Araçlar → Tutanak Merkezi\'nde taslak olarak sunulur.',
      fullText: '${t.title}\n${t.description}',
      keywords: [
        t.title,
        'tutanak',
        'tutanak sablon',
        'evrak sablon',
        'belge lazim',
      ],
      synonyms: const ['tutanak', 'zapt', 'evrak'],
      tags: ['tutanak', 'uygulama'],
      moduleRoute: 'tutanak',
      tutanakTemplateId: t.id,
      explanation:
          'Şablonu seçip alanları doldurun; PDF veya metin olarak paylaşın. '
          'Resmî form yerine geçmez.',
      isAppGuide: true,
    );
  }).toList();
}
