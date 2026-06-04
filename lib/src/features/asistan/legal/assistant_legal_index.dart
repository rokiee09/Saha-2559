import '../../mevzuat/mevzuat_provider.dart';
import '../../araclar/idari_para_ceza/idari_para_ceza_data.dart';

/// Mevzuat kaynak türü.
enum LegalSourceType {
  kanun,
  yonetmelik,
  tuzuk,
  idariParaCeza,
  rehber,
}

extension LegalSourceTypeX on LegalSourceType {
  String get label => switch (this) {
        LegalSourceType.kanun => 'Kanun',
        LegalSourceType.yonetmelik => 'Yönetmelik',
        LegalSourceType.tuzuk => 'Tüzük',
        LegalSourceType.idariParaCeza => 'İdari Para Cezası',
        LegalSourceType.rehber => 'Mevzuat Haritası',
      };
}

/// Asistan mevzuat indeks kaydı.
class LegalIndexRecord {
  const LegalIndexRecord({
    required this.id,
    required this.sourceType,
    required this.sourceName,
    required this.articleNo,
    required this.title,
    required this.summary,
    required this.fullText,
    required this.keywords,
    required this.synonyms,
    required this.tags,
    this.entryId,
    this.sectionId,
    this.riskNote = '',
    this.explanation = '',
    this.isPriority = false,
  });

  final String id;
  final LegalSourceType sourceType;
  final String sourceName;
  final String articleNo;
  final String title;
  final String summary;
  final String fullText;
  final List<String> keywords;
  final List<String> synonyms;
  final List<String> tags;
  final String? entryId;
  final String? sectionId;
  final String riskNote;
  final String explanation;
  final bool isPriority;

  String get sourceLabel => '$sourceName · $articleNo';

  Map<String, dynamic> toJson() => {
        'sourceType': sourceType.name,
        'sourceName': sourceName,
        'articleNo': articleNo,
        'title': title,
        'keywords': keywords,
        'tags': tags,
        'summary': summary,
      };
}

/// Öncelikli konular — elle hazırlanmış mevzuat haritası.
const kPriorityLegalRecords = <LegalIndexRecord>[
  LegalIndexRecord(
    id: 'priority_refakat_izni',
    sourceType: LegalSourceType.kanun,
    sourceName: '657 sayılı Devlet Memurları Kanunu',
    articleNo: 'Madde 104',
    title: 'Refakat izni',
    summary:
        'İlgili mevzuata göre, bakmakla yükümlü olunan veya refakatine muhtaç '
        'hasta yakını için refakat izni verilebilir. Süre ve şartlar rapor ve '
        'birim onayına bağlıdır.',
    fullText:
        'Engelli yakını mazeret izni ve refakat izni hükümleri DMK m. 104 '
        'kapsamında düzenlenir. Rapor, yakınlık derecesi ve bakım ihtiyacı '
        'birlikte değerlendirilir.',
    keywords: [
      'refakat izni',
      'refakat',
      'refakat iznim',
      'kac gun refakat',
      'hasta yakini',
    ],
    synonyms: ['refakat', 'bakmakla yukumlu', 'saglik izni'],
    tags: ['izinler', 'saglik', 'refakat', 'dmk'],
    entryId: 'kanun-dmk',
    sectionId: 'dmk-104',
    explanation:
        'Refakat izni, hastanın taburcu edilinceye veya başka bir sağlık '
        'kuruluşuna sevk edilinceye kadar verilebilir. İzin süresi raporda '
        'belirtilir; üst sınır mevzuat ve iç yönetmelikle sınırlıdır.',
    riskNote:
        'Rapor ve yakınlık şartları sağlanmadan izin kullanımı disiplin '
        've özlük açısından sorun doğurabilir.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_yillik_izin',
    sourceType: LegalSourceType.kanun,
    sourceName: '657 sayılı Devlet Memurları Kanunu',
    articleNo: 'Madde 53 ve izin hükümleri',
    title: 'Yıllık izin',
    summary:
        'İlgili mevzuata göre hizmet süresine göre yıllık izin hakkı doğar. '
        'Polis personelinde uygulama, DMK ile birlikte Polis Personeli İzin '
        'Yönetmeliği ve kurum içi usullere tabidir.',
    fullText:
        'Yıllık izin süreleri hizmet yılına göre artar. İzin planlaması '
        'hizmetin aksamaması esasına göre birim amirince yapılır.',
    keywords: [
      'yillik izin',
      'yillik iznim',
      'kac gun yillik',
      'izin hakki',
    ],
    synonyms: ['yillik', 'senelik izin', 'tatil izni'],
    tags: ['izinler', 'dmk', 'personel'],
    entryId: 'kanun-dmk',
    sectionId: 'dmk-53',
    explanation:
        'Yıllık izin talebi birim amirine yazılı yapılır; onay ve planlama '
        'kurum izin sistemine işlenir.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_mazeret_izni',
    sourceType: LegalSourceType.kanun,
    sourceName: '657 sayılı Devlet Memurları Kanunu',
    articleNo: 'Madde 104 ve mazeret izinleri',
    title: 'Mazeret izni',
    summary:
        'İlgili mevzuata göre evlilik, ölüm, doğum gibi hallerde mazeret izni '
        'verilebilir. Süreler olayın niteliğine göre mevzuatta belirlenir.',
    fullText: 'Mazeret izinleri kısa süreli izinlerdir; belge ve bildirim şartları vardır.',
    keywords: ['mazeret izni', 'mazeret', 'evlilik izni', 'olum izni'],
    synonyms: ['mazeret', 'olagan disi izin'],
    tags: ['izinler', 'dmk'],
    entryId: 'kanun-dmk',
    sectionId: 'dmk-104',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_gec_kalma',
    sourceType: LegalSourceType.kanun,
    sourceName: '7068 sayılı Genel Kolluk Disiplin Hükümleri Kanunu',
    articleNo: 'Uyarma / kınama fiilleri',
    title: 'Göreve geç gelme',
    summary:
        'İlgili mevzuata göre özürsüz veya izinsiz mesaiye geç gelmek, '
        'erken ayrılmak veya günlük mesai saatlerine riayet etmemek uyarma '
        'veya kınama cezasını gerektirebilir.',
    fullText:
        '7068 sayılı Kanun uyarma cezası kapsamında geç kalma fiillerini '
        'sayar. Tekerrür ve ağırlık halinde üst cezalar gündeme gelebilir.',
    keywords: [
      'gec kalma',
      'ise gec kaldim',
      'goreve gec gelme',
      'mesaiye gec kalma',
      'nobete gec gelme',
    ],
    synonyms: ['gec kalmak', 'mesai disi', 'nobet gecikme'],
    tags: ['disiplin', 'mesai', '7068'],
    entryId: 'kanun-disiplin',
    sectionId: 'dis-uyarma',
    explanation:
        'Geç kalma olayı disiplin soruşturması konusu olabilir; savunma '
        'hakkı ve süreler disiplin mevzuatına göre yürütülür.',
    riskNote: 'Tekerrür halinde kınama veya aylıktan kesme gündeme gelebilir.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_goreve_gelmeme',
    sourceType: LegalSourceType.kanun,
    sourceName: '7068 sayılı Genel Kolluk Disiplin Hükümleri Kanunu',
    articleNo: 'Kınama ve üstü fiiller',
    title: 'Göreve gelmeme / devamsızlık',
    summary:
        'İlgili mevzuata göre özürsüz göreve gelmemek veya görev mahallini '
        'terk etmek disiplin cezası doğurur. Süreklilik ceza ağırlığını artırır.',
    fullText:
        'Devamsızlık ve görevi terk fiilleri kınama ve aylıktan kesme '
        'kapsamında değerlendirilir.',
    keywords: [
      'goreve gelmeme',
      'goreve gelmezsem',
      'devamsizlik',
      'is basi yok',
    ],
    synonyms: ['devamsiz', 'gorev terk', 'gelmemek'],
    tags: ['disiplin', 'mesai'],
    entryId: 'kanun-disiplin',
    isPriority: true,
    riskNote: 'Uzun süreli devamsızlık memuriyetten çıkarmayı gerektirebilir.',
  ),
  LegalIndexRecord(
    id: 'priority_icra',
    sourceType: LegalSourceType.kanun,
    sourceName: '657 DMK ve İcra İflas Kanunu (özlük kesintileri)',
    articleNo: 'Maaş haczi / borç kesintisi',
    title: 'İcra ve maaş haczi',
    summary:
        'İlgili mevzuata göre haciz ve borç kesintileri kanuni sırada ve '
        'oransal sınırlarla uygulanır. İcra dosyası disiplin değil, mali '
        'yükümlülük konusudur; ancak mali disiplin soruşturması ayrıca açılabilir.',
    fullText:
        'Maaşın haczi nafaka, icra ve vergi borçlarında öncelik sırasına '
        'tabidir. Kesinti oranları kanunla sınırlıdır.',
    keywords: [
      'icra',
      'icram var',
      'maas haczi',
      'borc',
      'kesinti',
      'haciz',
    ],
    synonyms: ['icra takibi', 'maas kesintisi', 'borclu'],
    tags: ['icra', 'maas', 'personel'],
    explanation:
        'İcra bildirimi mali işler birimine iletilir; kesinti planı kanuni '
        'sınırlara uygun hazırlanır.',
    riskNote:
        'Mali yükümlülüklerin gizlenmesi veya usulsüz işlem disiplin konusu olabilir.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_alkollu_arac',
    sourceType: LegalSourceType.kanun,
    sourceName: '7068 GKDH · 2918 KTK · TCK',
    articleNo: 'Disiplin ve adli süreç',
    title: 'Alkollü araç kullanma',
    summary:
        'İlgili mevzuata göre alkollü araç kullanımı hem trafik/adli hem '
        'disiplin sürecini tetikleyebilir. Soruşturma ayrı kanallarda yürür.',
    fullText:
        'Trafik suçu ve disiplin soruşturması birbirinden bağımsız '
        'yürütülebilir. Disiplin cezası türü fiilin ağırlığına göre belirlenir.',
    keywords: [
      'alkollu arac',
      'alkol',
      'trafik',
      'disiplin sorusturmasi',
      'sarhos arac',
    ],
    synonyms: ['alkol', 'trafik guvenligi', 'ust sinir asimi'],
    tags: ['disiplin', 'trafik', 'tck'],
    explanation:
        'Olay tutanağı, alkol raporu ve trafik evrakı tamamlanır; '
        'disiplin dosyası ayrıca açılır.',
    riskNote:
        'Ağır hallerde kınama üstü cezalar, tekerrürde memuriyetten çıkarma riski.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_atis_izni',
    sourceType: LegalSourceType.rehber,
    sourceName: 'Polis Personeli İzin ve Atış Mevzuatı (özet)',
    articleNo: 'Atış / görev izni',
    title: 'Atış izni ve atış eğitimi',
    summary:
        'İlgili mevzuata göre atış eğitimi ve poligon günleri görev izni '
        'kapsamında planlanır. Süre ve usul kurum yönergesi ve hizmet içi '
        'eğitim planına bağlıdır.',
    fullText:
        'Atış izni, hizmet içi eğitim ve poligon uygulaması için verilir. '
        'Kayıt ve onay birim amirinden alınır.',
    keywords: [
      'atis izni',
      'atis iznim',
      'poligon',
      'atis egitimi',
      'kac gun atis',
    ],
    synonyms: ['atis', 'hizmet ici egitim', 'gorev izni'],
    tags: ['atis', 'egitim', 'izinler'],
    explanation:
        'Atış günü planı birimden duyurulur; izin ve görevlendirme yazısı '
        'saklanır.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_kimlik_sorma',
    sourceType: LegalSourceType.kanun,
    sourceName: '2559 sayılı PVSK',
    articleNo: 'Madde 4/A',
    title: 'Kimlik sorma ve durdurma',
    summary:
        'İlgili mevzuata göre durdurma makul sebebe dayanmalıdır. Kimlik '
        'sorma, durdurma sebebi ortadan kalkınca veya kimlik tespit edilince '
        'sona erer.',
    fullText:
        'Kimlik vermemek ayrı kabahat veya suç konusu olabilir; müdahale '
        'orantılılık ve kanuni sınırlar içinde olmalıdır.',
    keywords: [
      'kimlik vermeyen',
      'kimlik sorma',
      'huviyet',
      'durdurma',
    ],
    synonyms: ['kimlik kontrol', 'durdur', 'huviyet sorma'],
    tags: ['pvsk', 'kimlik', 'durdurma'],
    entryId: 'kanun-pvsk',
    sectionId: 'pvsk-4a',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_zor_kullanma',
    sourceType: LegalSourceType.kanun,
    sourceName: '2559 sayılı PVSK',
    articleNo: 'Madde 16',
    title: 'Zor ve silah kullanma',
    summary:
        'İlgili mevzuata göre zor ve silah kullanımı kanunda sayılı hallerde, '
        'orantılılık ve son çare ilkesine uygun olarak mümkündür.',
    fullText: 'PVSK md. 16 ve devamı maddeleri zor kullanma şartlarını düzenler.',
    keywords: [
      'zor kullanma',
      'silah kullanma',
      'pvsk 16',
      'orantili guc',
    ],
    synonyms: ['guc kullanma', 'mukavemet', 'silah'],
    tags: ['pvsk', 'zor kullanma'],
    entryId: 'kanun-pvsk',
    sectionId: 'pvsk-16',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_ust_arama',
    sourceType: LegalSourceType.yonetmelik,
    sourceName: 'Adli ve Önleme Aramaları Yönetmeliği · PVSK',
    articleNo: 'Üst arama / adli arama',
    title: 'Üst araması',
    summary:
        'İlgili mevzuata göre üst araması adli veya önleme araması usulüne '
        'tabidir; karar veya yazılı emir şartları arama türüne göre değişir.',
    fullText:
        'Önleme araması ile adli arama farklı usul ve yetkilere tabidir. '
        'Tutanak ve hak ihlali önlemleri esastır.',
    keywords: [
      'ust aramasi',
      'ust arama',
      'arama karari',
      'onleme aramasi',
      'adli arama',
    ],
    synonyms: ['arama', 'el koyma', 'ust arama'],
    tags: ['pvsk', 'arama', 'cmk'],
    entryId: 'yonetmelik-adli_arama',
    sectionId: 'aay-1',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_arac_arama',
    sourceType: LegalSourceType.yonetmelik,
    sourceName: 'Adli ve Önleme Aramaları Yönetmeliği',
    articleNo: 'Araç araması',
    title: 'Araç araması',
    summary:
        'İlgili mevzuata göre araç araması için arama türüne uygun karar '
        'veya yetki şartları aranır. Tutanak ve el koyma usulü ayrıca düzenlenir.',
    fullText: 'Araç içi ve dışı arama önleme veya adli arama kapsamında yapılır.',
    keywords: ['arac aramasi', 'arac arama', 'aracta arama'],
    synonyms: ['arac', 'ust arama', 'arama karari'],
    tags: ['arama', 'arac', 'pvsk'],
    entryId: 'yonetmelik-adli_arama',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_dilencilik',
    sourceType: LegalSourceType.idariParaCeza,
    sourceName: '5326 sayılı Kabahatler Kanunu',
    articleNo: 'Dilencilik kabahati',
    title: 'Dilencilik idari para cezası',
    summary:
        'İlgili mevzuata göre dilencilik kabahati için idari para cezası '
        'uygulanır. Güncel tutar yerel idari para cezası veri setinden '
        'okunmalıdır.',
    fullText:
        'Dilencilik fiili Kabahatler Kanunu kapsamında idari yaptırıma '
        'tabidir. Karar veren makam ve itiraz mercii kanunda gösterilir.',
    keywords: [
      'dilencilik',
      'dilencilik cezasi',
      'dilenci',
      'kabahat',
      'idari para cezasi',
    ],
    synonyms: ['dilenci', 'para cezasi', 'kabahatler kanunu'],
    tags: ['idari_para_ceza', 'kabahatler'],
    explanation:
        'Olay tutanağı ve tespit raporu düzenlenir; ceza tutarı güncel '
        'tarife ile belirlenir.',
    isPriority: true,
  ),
  LegalIndexRecord(
    id: 'priority_basari_belgesi',
    sourceType: LegalSourceType.rehber,
    sourceName: 'Emniyet personeli ödül ve başarı uygulamaları',
    articleNo: 'Başarı / üstün başarı',
    title: 'Başarı ve üstün başarı belgesi',
    summary:
        'İlgili mevzuata göre başarı belgeleri ödül ve takdir sürecine '
        'tabidir. Üç başarı belgesi üstün başarı belgesi hakkı doğurabilir '
        '(kurum uygulaması ve yönetmelik esas alınmalıdır).',
    fullText:
        'Başarı belgesi verilmesi takdir ve sicil sürecine bağlıdır; '
        'üstün başarı ayrı işlemle tesis edilir.',
    keywords: [
      'basari belgesi',
      'ustun basari',
      'kac basari',
      'odul',
    ],
    synonyms: ['basari', 'ustun basari belgesi', 'taltif'],
    tags: ['personel', 'basari', 'odul'],
    isPriority: true,
  ),
];

List<LegalIndexRecord> legalIndexFromMevzuat(
  Iterable<({MevzuatEntry entry, MevzuatSection section})> items,
) {
  return items.map((item) {
    final text = item.section.text.trim();
    final title = item.section.title.trim().isNotEmpty
        ? item.section.title.trim()
        : item.section.article.trim();
    final article = item.section.article.trim();
    final isKanun = item.entry.catalogTag.toLowerCase().contains('kanun');
    return LegalIndexRecord(
      id: 'mevzuat_${item.section.id}',
      sourceType: isKanun ? LegalSourceType.kanun : LegalSourceType.yonetmelik,
      sourceName: item.entry.displayTitle,
      articleNo: article.isNotEmpty ? article : 'Madde',
      title: title.isNotEmpty ? title : item.entry.name,
      summary: text.length > 280 ? '${text.substring(0, 277)}…' : text,
      fullText: text,
      keywords: _extractKeywords(title, article, text),
      synonyms: const [],
      tags: _inferTags(item.entry, title, text),
      entryId: item.entry.id,
      sectionId: item.section.id,
      explanation:
          'Maddenin tam metnini Mevzuat sekmesinden okuyup görev kaydınızla karşılaştırın.',
    );
  }).toList();
}

List<LegalIndexRecord> legalIndexFromIdariParaCeza(List<IdariParaCezaKayit> kayitlar) {
  return kayitlar.map((k) {
    return LegalIndexRecord(
      id: 'ceza_${k.id}',
      sourceType: LegalSourceType.idariParaCeza,
      sourceName: '${k.kanun} (${k.kanunSayisi})',
      articleNo: k.madde,
      title: k.kabahatAdi,
      summary:
          'İlgili mevzuata göre ${k.kabahatAdi} için 2026 idari para ceza '
          'tutarı ${k.cezaMetni}.',
      fullText: k.aramaMetni,
      keywords: [
        k.kabahatAdi,
        k.kanun,
        k.madde,
        'idari para cezasi',
        'ceza miktari',
      ],
      synonyms: ['kabahat', 'para cezasi', 'ipc'],
      tags: ['idari_para_ceza', 'kabahatler'],
      explanation:
          'Ceza tutarı, itiraz mercii (${k.itirazMercii}) ve ödeme süresi '
          '(${k.odemeSuresi}) birlikte değerlendirilir.',
    );
  }).toList();
}

List<LegalIndexRecord> buildFullLegalIndex({
  required Iterable<({MevzuatEntry entry, MevzuatSection section})> mevzuatItems,
  required List<IdariParaCezaKayit> cezaKayitlar,
}) {
  final dynamicRecords = [
    ...legalIndexFromMevzuat(mevzuatItems),
    ...legalIndexFromIdariParaCeza(cezaKayitlar),
  ];
  // Öncelik kayıtları aynı konuda dinamik kaydın önüne geçsin diye önce dinamik sonra priority değil -
  // search'te priority boost kullanılacak; listeye priority önce ekle
  return [...kPriorityLegalRecords, ...dynamicRecords];
}

List<String> _extractKeywords(String title, String article, String text) {
  final raw = '$title $article ${text.substring(0, text.length.clamp(0, 400))}';
  final folded = raw.toLowerCase();
  final words = folded.split(RegExp(r'[^a-zçğıöşü0-9]+'));
  final seen = <String>{};
  final out = <String>[];
  for (final w in words) {
    if (w.length < 4 || seen.contains(w)) continue;
    seen.add(w);
    out.add(w);
    if (out.length >= 12) break;
  }
  return out;
}

List<String> _inferTags(MevzuatEntry entry, String title, String text) {
  final blob = '${entry.code} ${entry.name} $title $text'.toLowerCase();
  final tags = <String>[];
  void add(String t) {
    if (!tags.contains(t)) tags.add(t);
  }

  if (blob.contains('disiplin') || entry.id.contains('disiplin')) add('disiplin');
  if (blob.contains('izin')) add('izinler');
  if (blob.contains('pvsk') || entry.code == '2559') add('pvsk');
  if (blob.contains('cmk') || entry.code == '5271') add('cmk');
  if (blob.contains('tck') || entry.code == '5237') add('tck');
  if (blob.contains('657') || entry.id.contains('dmk')) add('dmk');
  if (blob.contains('arama')) add('arama');
  if (blob.contains('kabahat')) add('idari_para_ceza');
  return tags;
}
