import 'assistant_models.dart';

/// Uygulama modülü yardım metinleri — arama havuzuna dahil.
class AssistantHelpEntry {
  const AssistantHelpEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.keywords,
    required this.shortAnswer,
    required this.source,
    required this.appContext,
    this.nav,
  });

  final String id;
  final AssistantCategory category;
  final String title;
  final List<String> keywords;
  final String shortAnswer;
  final String source;
  final String appContext;
  final SearchResultNav? nav;
}

const kAssistantHelpEntries = <AssistantHelpEntry>[
  AssistantHelpEntry(
    id: 'help_kimlik_vermeyen',
    category: AssistantCategory.mevzuat,
    title: 'Kimlik vermeyen şahıs',
    keywords: [
      'kimlik vermeyen',
      'kimlik vermez',
      'kimlik ibraz etmeyen',
      'huviyet vermeyen',
      'kimlik gostermeyen',
    ],
    shortAnswer:
        'İlgili mevzuata göre durdurma ve kimlik sorma PVSK md. 4/A kapsamında '
        'makul sebebe dayanmalıdır. Kimlik ibraz etmeme ayrıca Kabahatler Kanunu '
        'kapsamında değerlendirilebilir; somut olayda tam metin esas alınmalıdır.',
    source: 'PVSK md. 4/A · Kabahatler Kanunu',
    appContext:
        'Mevzuat\'tan PVSK md. 4/A ve ilgili kabahat hükümlerini açın. '
        'Olay tutanağında sebep, süre ve yapılan işlemleri net yazın.',
    nav: const SearchResultNav(
      mevzuatEntryId: 'kanun-pvsk',
      mevzuatSectionId: 'pvsk-4a',
    ),
  ),
  AssistantHelpEntry(
    id: 'help_atis_kayit',
    category: AssistantCategory.atis,
    title: 'Atış kaydı nasıl girilir?',
    keywords: [
      'atis kaydet',
      'atisimi',
      'atis takibi',
      'atis izni',
      'atis puani',
      'atış izni kullandim',
      'atışımı nereye',
    ],
    shortAnswer:
        'Atış Takibim bölümünden yıl ve dönem seçerek atış tarihi, puan, '
        'atış izni durumu ve not ekleyebilirsiniz.',
    source: 'SAHA 2559 · Atış Takibim modülü',
    appContext:
        'Profilim → Atış Takibim menüsünden ilgili yılı ve dönemi (1–4) '
        'seçin. Atış izni kullandıysanız bunu işaretleyin; puan ve tarihi kaydedin.',
    nav: SearchResultNav(moduleRoute: 'atis_takip'),
  ),
  AssistantHelpEntry(
    id: 'help_basari_ustun',
    category: AssistantCategory.basari,
    title: 'Kaç başarı belgesi üstün başarı hakkı verir?',
    keywords: [
      'basari belgesi',
      'ustun basari',
      '3 basari',
      'kac basari',
      'basari odul',
      'basari ve odullerim',
    ],
    shortAnswer:
        '3 başarı belgesi, 1 üstün başarı belgesi hakkı anlamına gelir '
        '(bilgilendirme amaçlı takip). Üstün belge alındığında ayrıca kaydedilmelidir.',
    source: 'SAHA 2559 · Başarı ve Ödüllerim',
    appContext:
        'Profilim → Başarı ve Ödüllerim bölümünde otomatik sayaç görünür. '
        'Başarı ve üstün başarı belgelerini ayrı listelerde tutabilirsiniz.',
    nav: SearchResultNav(moduleRoute: 'basari_oduller'),
  ),
  AssistantHelpEntry(
    id: 'help_taltif',
    category: AssistantCategory.basari,
    title: 'Taltif kaydı',
    keywords: ['taltif', 'taltif tutari', 'odul parasi'],
    shortAnswer:
        'Taltifler Başarı ve Ödüllerim → Taltiflerim bölümünden tarih, tutar '
        've belge ile kaydedilir.',
    source: 'SAHA 2559 · Taltiflerim',
    appContext:
        'Taltif tarihi, tutarı, veren makam ve varsa belge görseli/PDF '
        'cihazınızda saklanır.',
    nav: SearchResultNav(moduleRoute: 'basari_oduller'),
  ),
  AssistantHelpEntry(
    id: 'help_saglik_rapor',
    category: AssistantCategory.saglik,
    title: 'Sağlık raporu nereden takip edilir?',
    keywords: [
      'saglik raporu',
      'rapor takip',
      'istirahat',
      'heyet',
      'saglik ve sosyal',
    ],
    shortAnswer:
        'Sağlık ve Sosyal Haklar bölümünden rehber, mevzuat metinleri ve '
        'sağlık asistanına erişebilirsiniz.',
    source: 'SAHA 2559 · Sağlık ve Sosyal Haklar',
    appContext:
        'Ana menü veya drawer → Sağlık ve Sosyal Haklar. İstirahat, heyet, '
        'elverişlilik konuları rehber kartlarında özetlenir.',
    nav: SearchResultNav(moduleRoute: 'saglik'),
  ),
  AssistantHelpEntry(
    id: 'help_tutanak',
    category: AssistantCategory.tutanak,
    title: 'Tutanak şablonu',
    keywords: [
      'tutanak',
      'tutanak ornegi',
      'tutanak sablon',
      'evrak sablon',
      'belge lazim',
    ],
    shortAnswer:
        'Araçlar → Tutanak Merkezi\'nde kimlik tespit, teslim-tesellüm, olay '
        've diğer şablon taslakları bulunur.',
    source: 'SAHA 2559 · Tutanak Merkezi',
    appContext:
        'Şablonu seçin, alanları doldurun; PDF paylaşımı veya kopyalama '
        'yapabilirsiniz. Taslak resmî form değildir.',
    nav: SearchResultNav(moduleRoute: 'tutanak'),
  ),
  AssistantHelpEntry(
    id: 'help_kariyer',
    category: AssistantCategory.kariyer,
    title: 'Kariyer bilgileri',
    keywords: [
      'kariyer',
      'profilim',
      'emeklilik takibi',
      'gorev puani',
      'tayin',
    ],
    shortAnswer:
        'Profilim sekmesinden kariyer özeti, emeklilik, eğitim ve görev '
        'kayıtlarına ulaşırsınız.',
    source: 'SAHA 2559 · Profilim / Kariyerim',
    appContext:
        'Profilim → Kariyer özeti veya Kariyerim hub\'ından alt modüllere geçin.',
    nav: SearchResultNav(moduleRoute: 'kariyer'),
  ),
  AssistantHelpEntry(
    id: 'help_egitim',
    category: AssistantCategory.egitim,
    title: 'Eğitim ve sertifika kaydı',
    keywords: ['egitim', 'sertifika', 'kurs', 'diploma', 'egitimlerim'],
    shortAnswer:
        'Profilim → Eğitimlerim bölümünden kurs, sertifika ve belge '
        'kayıtlarını tutabilirsiniz.',
    source: 'SAHA 2559 · Eğitimlerim',
    appContext:
        'Eğitim adı, kurum, tarih ve belge görseli cihazda saklanır.',
    nav: SearchResultNav(moduleRoute: 'egitim'),
  ),
  AssistantHelpEntry(
    id: 'help_idari_para',
    category: AssistantCategory.idariParaCeza,
    title: 'İdari para cezaları arama',
    keywords: [
      'idari para cezasi',
      'ipc',
      'kabahat cezasi',
      'ceza ne kadar',
      'para cezasi',
    ],
    shortAnswer:
        'Araçlar → İdari Para Cezaları bölümünde 2026 kabahat tutarlarını '
        'arayabilir ve filtreleyebilirsiniz.',
    source: 'SAHA 2559 · İdari Para Cezaları (2026)',
    appContext:
        'Kabahat adı, kanun veya madde ile arama yapın. Asistan\'da da '
        'doğrudan sorabilirsiniz (ör. dilencilik cezası ne kadar).',
    nav: SearchResultNav(moduleRoute: 'idari_para_ceza'),
  ),
];
