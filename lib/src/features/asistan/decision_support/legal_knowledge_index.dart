import '../../../common/text/tr_text.dart';
import '../../araclar/idari_para_ceza/idari_para_ceza_data.dart';
import '../../mevzuat/mevzuat_provider.dart';
import '../legal/assistant_legal_app_index.dart';
import '../legal/assistant_legal_index.dart';

/// Mevzuat kaydı risk seviyesi.
enum LegalRiskLevel {
  low,
  medium,
  high,
  critical,
}

extension LegalRiskLevelX on LegalRiskLevel {
  String get label => switch (this) {
        LegalRiskLevel.low => 'Düşük',
        LegalRiskLevel.medium => 'Orta',
        LegalRiskLevel.high => 'Yüksek',
        LegalRiskLevel.critical => 'Kritik',
      };
}

/// Karar destek asistanı mevzuat kaydı.
class LegalKnowledgeRecord {
  const LegalKnowledgeRecord({
    required this.id,
    required this.sourceName,
    required this.articleNo,
    required this.title,
    required this.fullText,
    required this.summary,
    required this.keywords,
    required this.tags,
    this.exampleQuestions = const [],
    this.riskLevel = LegalRiskLevel.medium,
    this.topics = const [],
    this.subtopics = const [],
    this.sourceType = LegalSourceType.rehber,
    this.synonyms = const [],
    this.entryId,
    this.sectionId,
    this.moduleRoute,
    this.saglikKonuId,
    this.tutanakTemplateId,
    this.riskNote = '',
    this.explanation = '',
    this.isPriority = false,
    this.isAppGuide = false,
  });

  final String id;
  final String sourceName;
  final String articleNo;
  final String title;
  final String fullText;
  final String summary;
  final List<String> keywords;
  final List<String> tags;
  final List<String> exampleQuestions;
  final LegalRiskLevel riskLevel;
  final List<String> topics;
  final List<String> subtopics;
  final LegalSourceType sourceType;
  final List<String> synonyms;
  final String? entryId;
  final String? sectionId;
  final String? moduleRoute;
  final String? saglikKonuId;
  final String? tutanakTemplateId;
  final String riskNote;
  final String explanation;
  final bool isPriority;
  final bool isAppGuide;

  String get sourceLabel => '$sourceName · $articleNo';

  LegalIndexRecord toIndexRecord() => LegalIndexRecord(
        id: id,
        sourceType: sourceType,
        sourceName: sourceName,
        articleNo: articleNo,
        title: title,
        summary: summary,
        fullText: fullText,
        keywords: keywords,
        synonyms: synonyms,
        tags: tags,
        entryId: entryId,
        sectionId: sectionId,
        moduleRoute: moduleRoute,
        saglikKonuId: saglikKonuId,
        tutanakTemplateId: tutanakTemplateId,
        riskNote: riskNote,
        explanation: explanation,
        isPriority: isPriority,
        isAppGuide: isAppGuide,
      );

  factory LegalKnowledgeRecord.fromIndexRecord(LegalIndexRecord record) {
    return LegalKnowledgeRecord(
      id: record.id,
      sourceType: record.sourceType,
      sourceName: record.sourceName,
      articleNo: record.articleNo,
      title: record.title,
      summary: record.summary,
      fullText: record.fullText,
      keywords: record.keywords,
      synonyms: record.synonyms,
      tags: record.tags,
      entryId: record.entryId,
      sectionId: record.sectionId,
      moduleRoute: record.moduleRoute,
      saglikKonuId: record.saglikKonuId,
      tutanakTemplateId: record.tutanakTemplateId,
      riskNote: record.riskNote,
      explanation: record.explanation,
      isPriority: record.isPriority,
      isAppGuide: record.isAppGuide,
      riskLevel: _inferRisk(record),
      topics: _inferTopics(record),
    );
  }
}

LegalRiskLevel _inferRisk(LegalIndexRecord record) {
  final blob = '${record.tags.join(' ')} ${record.title} ${record.riskNote}'
      .toLowerCase();
  if (blob.contains('disiplin') ||
      blob.contains('zor kullan') ||
      blob.contains('pvsk')) {
    return LegalRiskLevel.high;
  }
  if (blob.contains('idari_para') || blob.contains('icra')) {
    return LegalRiskLevel.medium;
  }
  if (record.isAppGuide) return LegalRiskLevel.low;
  return LegalRiskLevel.medium;
}

List<String> _inferTopics(LegalIndexRecord record) {
  final topics = <String>[];
  void add(String t) {
    if (!topics.contains(t)) topics.add(t);
  }

  for (final tag in record.tags) {
    add(tag);
  }
  final blob = trFold('${record.title} ${record.keywords.join(' ')}');
  if (blob.contains('yediemin') || blob.contains('emanet')) add('yediemin');
  if (blob.contains('refakat') || blob.contains('izin')) add('izinler');
  if (blob.contains('disiplin')) add('disiplin');
  if (blob.contains('pvsk') || blob.contains('kimlik')) add('pvsk');
  if (blob.contains('arama')) add('arama');
  if (blob.contains('atis')) add('atis');
  if (blob.contains('basari')) add('personel_haklari');
  return topics;
}

/// Olay tabanlı öncelikli rehber kayıtları (doğal dil soruları).
const kScenarioKnowledgeRecords = <LegalKnowledgeRecord>[
  LegalKnowledgeRecord(
    id: 'scenario_yediemin_arac_teslim',
    sourceName:
        'CMK · İİK · Adli emanat ve yediemin uygulaması (bilgilendirme özeti)',
    articleNo: 'Teslim / infaz koordinasyonu',
    title: 'Yediemin deposundan araç teslimi ve başka il mahkeme kararı',
    summary:
        'İlgili mevzuata göre adli emanetteki aracın teslimi, hükmü veren '
        'mahkemenin veya kararın infazına yetkili merciin görev alanı ile '
        'bağlantılıdır. Başka il mahkemesinin kararının infazında genellikle '
        'dosya/infaz koordinasyonu ve kararın usulüne uygun tebliği esastır; '
        'savcı talimatı ihtiyacı somut dosya türüne ve teslim hükmünün '
        'niteliğine göre değişir.',
    fullText:
        'Yediemin ve adli emanet uygulamasında aracın iadesi/teslimi için '
        'mahkeme kararının infaza elverişli olması, teslim veya iadeye ilişkin '
        'açık hüküm bulunması ve emanetteki aracın kimlik bilgilerinin '
        'eşleşmesi birlikte değerlendirilir. Başka ilde verilmiş karar '
        'infazında yetkili mahkeme/savcılık ile işlem yapan birim arasında '
        'yazışma yapılır. Savcı talimatı her teslim işleminde şart değildir; '
        'kararın niteliği (önleme, delil, müsadere, iade) ve dosya safahati '
        'belirleyicidir. Kesinleşmemiş veya infazı durdurulan kararlarla '
        'teslim yapılmamalıdır.',
    keywords: [
      'yediemin',
      'yedieminden arac',
      'yedieminden cikarma',
      'adli emanet',
      'arac teslimi',
      'mahkeme karari',
      'baska il mahkeme',
      'savci talimati',
      'infaz',
      'teslim',
      'emanet arac',
    ],
    synonyms: [
      'otopark',
      'yediemin odasi',
      'aracin iadesi',
      'karar infazi',
    ],
    tags: [
      'yediemin',
      'adli_emanet',
      'cmk',
      'infaz',
      'mahkeme_karari',
      'arac',
    ],
    topics: [
      'yediemin',
      'arac_teslimi',
      'mahkeme_karari_infazi',
      'yetki',
      'savci_talimati',
    ],
    subtopics: [
      'baska_il_karari',
      'infaz_koordinasyonu',
      'teslim_sarti',
    ],
    exampleQuestions: [
      'Yedieminden araç çıkaracağız ancak başka ilin mahkeme kararı var. '
          'Kendi bulunduğum ilde savcı talimatı almaya gerek var mı?',
      'Adli emanetteki aracı yedieminden teslim ederken savcı talimatı şart mı?',
      'Başka şehir mahkemesinin kararıyla yediemin aracı verilir mi?',
    ],
    riskLevel: LegalRiskLevel.high,
    explanation:
        'İşlem öncesi karar metninde teslim/iade hükmü, kesinleşme şerhi ve '
        'dosya numarası kontrol edilir. Başka il kararı ise infaz yazışması '
        'yapılır; yerel Cumhuriyet savcılığı/mahkeme koordinasyonu dosya '
        'türüne göre gündeme gelir.',
    riskNote:
        'Karar infaza elverişli değilse veya emanetteki araçla uyuşmazlık '
        'varsa teslim yapılmamalı; keyfi teslim hukuki sorumluluk doğurabilir.',
    isPriority: true,
  ),
  LegalKnowledgeRecord(
    id: 'scenario_kimlik_vermeyen',
    sourceName: '2559 sayılı PVSK · CMK (bilgilendirme özeti)',
    articleNo: 'Kimlik ve durdurma',
    title: 'Kimlik vermeyen şahıs — durdurma ve tespit',
    summary:
        'Durdurma makul sebebe dayanmalıdır. Kimlik ibraz etmeyen şahısta '
        'tespit ve gerekirse yakalama/gözaltı CMK usulü ile birlikte '
        'değerlendirilir; zor kullanımı orantılı olmalıdır.',
    fullText:
        'PVSK md. 4/A kapsamında durdurma gerekçesi yazılı hale getirilir. '
        'Kimlik tespit tutanağı düzenlenir. Gözaltı ve müdafi bildirimi CMK '
        'hükümlerine tabidir. Keyfi veya süresiz durdurma hukuka aykırıdır.',
    keywords: [
      'kimlik vermeyen',
      'kimlik vermiyor',
      'kimlik sorma',
      'durdurma',
      'tespit',
      'mukavemet',
    ],
    synonyms: ['kimlik ibraz', 'nufus', 'kimlik tespit'],
    tags: ['pvsk', 'cmk', 'kimlik', 'durdurma'],
    topics: ['pvsk', 'yetki'],
    exampleQuestions: [
      'Kimlik vermeyen şahsa ne yapılır?',
      'Durdurduğum kişi kimliğini göstermiyor.',
    ],
    riskLevel: LegalRiskLevel.high,
    entryId: 'kanun-pvsk',
    sectionId: 'pvsk-4a',
    explanation: 'Araçlar → Emsal özetleri ve Tutanak şablonlarını kullanın.',
    riskNote: 'Orantısız müdahale disiplin ve tazminat riski doğurabilir.',
    isPriority: true,
  ),
  LegalKnowledgeRecord(
    id: 'scenario_alkol_trafik',
    sourceName: 'Trafik ve disiplin (bilgilendirme özeti)',
    articleNo: 'Alkollü sürücü',
    title: 'Alkollü sürücü — trafik işlemi ve personel disiplini',
    summary:
        'Trafik/adli işlem ile memur disiplin süreci ayrı yürütülür. '
        'Ölçüm kaydı, tutanak ve idari yaptırım dosyası tamamlanmalıdır.',
    fullText:
        'Alkol ölçümü cihaz ve saat bilgisiyle kayıt altına alınır. '
        'İdari para ceza ve gerekirse adli süreç açılır. Görevli personel '
        'ise 7068 kapsamında ayrı disiplin değerlendirmesi yapılır.',
    keywords: [
      'alkol',
      'alkollu',
      'alkollu surucu',
      'trafik',
      'promil',
    ],
    tags: ['trafik', 'disiplin', 'idari_para'],
    topics: ['idari_para_ceza', 'disiplin'],
    exampleQuestions: [
      'Alkollü araç kullandım disiplin cezası nedir?',
      'Trafik kontrolünde alkollü sürücü işlemi nasıl yapılır?',
    ],
    riskLevel: LegalRiskLevel.high,
    moduleRoute: 'trafik',
    explanation: 'Araçlar → Trafik rehberi ve İdari para cezaları.',
    isPriority: true,
  ),
  LegalKnowledgeRecord(
    id: 'scenario_gec_kalma',
    sourceName: '7068 sayılı Genel Kolluk Disiplin Kanunu (özet)',
    articleNo: 'Geç kalma',
    title: 'İşe geç kalma — disiplin değerlendirmesi',
    summary:
        'Tekrarlayan geç kalmalarda fiilin niteliğine göre uyarma, kınama '
        'veya aylıktan kesme gündeme gelebilir; savunma hakkı tanınmalıdır.',
    fullText:
        '7068 md. 8 kapsamında geç kalma fiilleri derecelendirilir. '
        'Ön rapor, savunma ve delil toplama usulüne uyulur. '
        'Dilekçe Merkezi savunma taslağı hazırlamaya yardımcı olur.',
    keywords: [
      'gec kaldim',
      'gec kalma',
      'ise gec',
      'disiplin cezasi',
      'uyarma',
    ],
    tags: ['disiplin', 'dmk'],
    topics: ['disiplin'],
    exampleQuestions: [
      'İşe geç kaldım cezası nedir?',
      'Geç kalma disiplin cezası kaç kez olunca kınama?',
    ],
    riskLevel: LegalRiskLevel.medium,
    entryId: 'kanun-disiplin',
    moduleRoute: 'dilekce',
    explanation: 'Profilim → Disiplin ve Araçlar → Dilekçe Merkezi.',
    isPriority: true,
  ),
];

List<LegalKnowledgeRecord> buildLegalKnowledgeIndex({
  required Iterable<({MevzuatEntry entry, MevzuatSection section})> mevzuatItems,
  required List<IdariParaCezaKayit> cezaKayitlar,
}) {
  final legacy = buildFullLegalIndex(
    mevzuatItems: mevzuatItems,
    cezaKayitlar: cezaKayitlar,
  );
  return [
    ...kScenarioKnowledgeRecords,
    ...legacy.map(LegalKnowledgeRecord.fromIndexRecord),
  ];
}
