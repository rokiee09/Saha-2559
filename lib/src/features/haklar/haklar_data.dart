/// Haklar sekmesi için statik içerik. Her hak kartı ve detay sayfası bu veriyi kullanır.
class RightItem {
  final String title;
  final String shortDescription;
  final String fullContent;
  final List<String> legalRefs;
  final List<String> keyPoints;
  final String iconKey;

  const RightItem({
    required this.title,
    required this.shortDescription,
    required this.fullContent,
    this.legalRefs = const [],
    this.keyPoints = const [],
    this.iconKey = 'info',
  });
}

const List<RightItem> rightsData = [
  RightItem(
    title: 'Maaş ve Özlük Hakları',
    shortDescription:
        'Personelin maaş, ikramiye, ek ödeme ve diğer mali hakları 2559 sayılı Kanun ve ilgili mevzuatla korunur.',
    fullContent: '''Polis personelinin maaş, ek gösterge, ikramiye ve diğer mali hakları 2559 sayılı Polis Vazife ve Salahiyet Kanunu ile 657 sayılı Devlet Memurları Kanunu hükümlerine tabidir.

• Maaş ve ek ödemeler: Gösterge, kıdem, taban aylığı ve ek ödemeler Bütçe Kanunu ve ilgili genelgelere göre ödenir.
• Ödeme tarihi: Aylık ödemeler genelde her ayın belirli günlerinde yapılır; tarih Maliye Bakanlığı ve İçişleri Bakanlığı düzenlemeleriyle belirlenir.
• İkramiye: Yılda iki kez (bayram ikramiyesi) ödenir; oran ve koşullar mevzuatla düzenlenir.
• Ek ödeme: Görev türü, bölge ve özel koşullara göre ek ödeme yapılabilir; detaylar yönetmelik ve genelgelerde yer alır.

Değişiklik ve güncellemeler için Bütçe Kanunu, 657 sayılı Kanun ve İçişleri Bakanlığı personel mevzuatı takip edilmelidir.''',
    legalRefs: [
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu',
      '657 sayılı Devlet Memurları Kanunu',
      'Bütçe Kanunu (yıllık)',
      'İçişleri Bakanlığı Personel Genelgesi / Yönetmelikleri',
    ],
    keyPoints: [
      'Maaş ve ek ödemeler kanun ve bütçe ile sabittir.',
      'Ödeme tarihleri genelge ile duyurulur.',
      'İkramiye yılda iki kez ödenir.',
    ],
    iconKey: 'wallet',
  ),
  RightItem(
    title: 'İzin Hakları',
    shortDescription:
        'Yıllık izin, mazeret izni, doğum izni ve özel izin hakları mevzuatla belirlenmiştir.',
    fullContent: '''Polis personelinin izin hakları 657 sayılı Devlet Memurları Kanunu ve Polis Personeli İzin Yönetmeliği ile düzenlenir.

• Yıllık izin: Hizmet süresine göre yıllık izin süresi belirlenir (1–5 yıl, 5–10 yıl, 10–15 yıl, 15 yıl ve üzeri farklı gün sayıları). İzin kullanımı amir onayı ile yapılır.
• Mazeret izni: Evlenme, vefat, doğum, taşınma vb. hallerde mazeret izni verilir; süreler yönetmelikte belirtilir.
• Doğum izni: Analık ve babalık izin süreleri kanun ve yönetmelikle düzenlenir; güncel süreler mevzuatta yer alır.
• Özel izin: Zorunlu ve olağanüstü hallerde özel izin amir tarafından verilebilir.
• Hastalık izni: Sağlık raporu ile hastalık izni kullanılır; süre ve usul mevzuata tabidir.

İzin talepleri yazılı yapılır; reddedilmesi halinde üst makama itiraz edilebilir.''',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu (İzin maddeleri)',
      'Polis Personeli İzin Yönetmeliği',
      'Analık/Babalık izni mevzuatı',
    ],
    keyPoints: [
      'Yıllık izin hizmet süresine göre artar.',
      'Mazeret ve doğum izni süreleri yönetmelikte yazılıdır.',
      'İzin talebi yazılı yapılır; redde itiraz mümkündür.',
    ],
    iconKey: 'calendar',
  ),
  RightItem(
    title: 'Sağlık ve Emeklilik',
    shortDescription:
        'Sağlık hizmetleri, tedavi yardımı ve emeklilik hakları güvence altındadır.',
    fullContent: '''Polis personeli, 657 sayılı Kanun ve Sosyal Güvenlik mevzuatı kapsamında sağlık ve emeklilik haklarına sahiptir.

• Sağlık hizmeti: Memur ve bakmakla yükümlü olduğu kişiler, genel sağlık sigortası ve devlet sağlık tesisleri üzerinden sağlık hizmeti alır; özel sağlık kurumları ile protokol kapsamında da hizmet verilebilir.
• Tedavi yardımı: Yatarak tedavi, ilaç ve protez gibi giderler mevzuat çerçevesinde karşılanır; katılım payı ve sınırlar yönetmelikle belirlenir.
• Maluliyet ve şehit ailesi: Görev sırasında malul kalan veya vefat eden personel ve aileleri için özel haklar kanunla düzenlenir.
• Emeklilik: Yaş, hizmet süresi ve prim ödeme koşulları 5434 sayılı T.C. Emekli Sandığı Kanunu (ve ilgili düzenlemeler) ile belirlenir. Emekli aylığı hesaplaması ve yaş haddi güncel mevzuata göre uygulanır.

Sağlık ve emeklilik işlemleri kurum personel birimi ve SGK/Emekli Sandığı birimleri üzerinden yürütülür.''',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu',
      '5434 sayılı T.C. Emekli Sandığı Kanunu',
      'Genel Sağlık Sigortası mevzuatı',
      'Malul ve şehit ailesi hakları (ilgili kanunlar)',
    ],
    keyPoints: [
      'Sağlık hizmeti devlet ve protokol kapsamında sağlanır.',
      'Emeklilik yaş ve hizmet süresi mevzuata tabidir.',
      'Malul ve şehit ailesi için özel haklar kanunda düzenlenir.',
    ],
    iconKey: 'health',
  ),
  RightItem(
    title: 'Mesleki Gelişim',
    shortDescription:
        'Hizmet içi eğitim, kurs ve kariyer gelişimi için fırsatlar sunulur.',
    fullContent: '''Polis personelinin mesleki gelişimi, hizmet içi eğitim ve kariyer yönetimi mevzuatı ile desteklenir.

• Hizmet içi eğitim: Polis Akademisi ve EGM Eğitim Dairesi Başkanlığı bünyesinde zorunlu ve isteğe bağlı eğitimler düzenlenir; konular asayiş, trafik, kriminal, insan hakları vb. alanları kapsar.
• Kurs ve sertifikasyon: Uzmanlık kursları, dil kursları ve sertifika programlarına katılım usul ve esasları yönetmelikle belirlenir.
• Kariyer ve terfi: Rütbe ilerlemesi, sınav ve değerlendirme kriterleri 2559 ve 657 sayılı Kanun ile Polis Kariyer Yönetmeliği hükümlerine tabidir.
• Atama ve yer değişikliği: İl içi ve il dışı atamalar, açık kadro ve tercih usulü yönetmelikle düzenlenir; zorunlu çalışma süreleri ve tazminat koşulları mevzuatta yer alır.

Eğitim ve kariyer başvuruları resmi yazı ile yapılır; sonuçlar duyuru ile ilan edilir.''',
    legalRefs: [
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu',
      '657 sayılı Devlet Memurları Kanunu',
      'Polis Kariyer Yönetmeliği',
      'Hizmet İçi Eğitim Yönetmeliği',
    ],
    keyPoints: [
      'Hizmet içi eğitim zorunlu ve isteğe bağlı modülleri kapsar.',
      'Terfi ve atama sınav ve değerlendirme ile yapılır.',
      'Atama ve yer değişikliği yönetmelik usulüne tabidir.',
    ],
    iconKey: 'school',
  ),
  RightItem(
    title: 'Sendika ve Grev Yasağı',
    shortDescription:
        'Emniyet personeli sendika kuramaz ve sendikaya üye olamaz; grev yasaktır. Hak arama bireysel idari ve yargı yoluyla yapılır.',
    fullContent: '''Polis personeli (emniyet hizmetleri sınıfı ve emniyet teşkilatında çalışan diğer hizmet sınıfları), 4688 sayılı Kamu Görevlileri Sendikaları ve Toplu Sözleşme Kanunu'nun 15. maddesine göre sendika kurma ve sendikaya üye olma hakkından yasal olarak istisnadır.

• 4688 sayılı Kanun Md. 15 (j): Emniyet hizmetleri sınıfı ve emniyet teşkilatında çalışan diğer hizmet sınıflarına dahil personel sendika kuramaz ve üye olamaz.
• Grev: Polis personeli için grev yasağı Anayasa ve kanunla kesindir; kamu düzeni ve güvenlik hizmetinin kesintisiz yürütülmesi gerekçesiyle düzenlenmiştir.
• Toplu sözleşme: Emniyet personeli 4688 kapsamında toplu sözleşme tarafları değildir; ücret ve sosyal haklar Bütçe Kanunu, 657 sayılı DMK ve 2559 sayılı PVSK ile belirlenir.
• Bireysel başvuru: Hak arama için bireysel idari başvuru, şikâyet, disiplin itirazı ve idari yargı yolu açıktır; personel dernekleri sendika niteliği taşımaz ve toplu sözleşme yetkisi yoktur.

Uluslararası metinler (AİHS m. 11, ILO 151) kolluk mensuplarına sendika hakkında ulusal mevzuatla sınırlama konulmasına izin verir.''',
    legalRefs: [
      '4688 sayılı Kanun Md. 15 (j) – Sendika üyeliği yasağı',
      'Anayasa (Grev yasağı – kamu düzeni)',
      '2559 sayılı PVSK, 657 sayılı DMK (Özlük hakları)',
    ],
    keyPoints: [
      'Polis personeli sendika kuramaz ve sendikaya üye olamaz.',
      'Grev yasağı kesindir.',
      'Hak arama bireysel idari ve yargı yollarıyla yapılır.',
    ],
    iconKey: 'group',
  ),
  RightItem(
    title: 'Disiplin ve İtiraz',
    shortDescription:
        'Disiplin cezalarına itiraz, idari ve yargısal başvuru hakları mevzuatla düzenlenmiştir.',
    fullContent: '''Disiplin cezalarına karşı itiraz ve yargı yolu, 657 sayılı Devlet Memurları Kanunu ile 2559 sayılı Polis Vazife ve Salahiyet Kanunu’ndaki disiplin hükümleri ve ilgili yönetmeliklerle düzenlenir.

• Disiplin cezaları: Uyarma, kınama, aylıktan kesme, kademe ilerlemesinin durdurulması, memuriyetten çıkarma gibi cezalar kanunda sayılmıştır; fiil-ceza orantılılığı esastır.
• Savunma hakkı: Cezadan önce yazılı veya sözlü savunma alınır; süre yönetmelikle belirtilir.
• İtiraz: Cezaya karşı belirli süre içinde (genelde 7–15 gün) üst disiplin amirine veya yetkili kurula itiraz edilebilir; süre tebliğ tarihinden işler.
• İdari yargı: İdari itiraz sonrası veya doğrudan idari yargı yoluna başvurulabilir; süre Danıştay/İdare Mahkemesi mevzuatına tabidir.
• Süre aşımı: İtiraz ve dava süreleri aşılmamalıdır; süreler kanun ve yönetmelikte açıkça yazılıdır.

Hukuki destek için baro veya avukat ile iletişime geçilebilir.''',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu (Disiplin hükümleri)',
      '2559 sayılı PVSK (Polis disiplin)',
      'Disiplin Soruşturma Yönetmeliği',
      'İdari Yargılama Usulü Kanunu',
    ],
    keyPoints: [
      'Savunma hakkı ceza öncesi kullanılır.',
      'İtiraz süresi tebliğden itibaren işler; süre aşımına dikkat.',
      'İdari yargı yolu açıktır.',
    ],
    iconKey: 'gavel',
  ),
  RightItem(
    title: 'Görev ve Yetki',
    shortDescription:
        'Görev tanımı, yetki sınırları ve sorumluluklar kanun ve yönetmeliklerle belirlenir.',
    fullContent: '''Polisin görev ve yetkileri 2559 sayılı Polis Vazife ve Salahiyet Kanunu (PVSK) ile 5271 sayılı CMK ve diğer kanunlarda tanımlıdır.

• Görev alanı: Kamu düzeni, can ve mal güvenliği, suçun önlenmesi ve soruşturma yardımı; görev süresi ve coğrafi sınır mevzuatta belirtilir.
• Yetki kaynağı: Her yetki (kimlik sorma, yakalama, arama, zor kullanma vb.) kanun maddesine dayanır; yetki aşımı hukuki ve cezai sorumluluk doğurur.
• Emir ve itaat: Amirinin kanuna uygun emirlerini yerine getirmekle yükümlüdür; hukuka aykırı emir verilmemeli, verilirse yerine getirilmez ve üst makama bildirilir (PVSK m.17).
• Sorumluluk: Görev sırasında işlenen kusurlu fiiller disiplin ve ceza hukuku kapsamında değerlendirilir; masumiyet karinesi ve savunma hakkı esastır.
• Görev dışı talep: Görev ve yetki dışındaki talepler yerine getirilmez; zorlama ve baskı şikâyet konusu yapılabilir.

Detay için Mevzuat sekmesinde PVSK ve CMK maddelerine bakınız.''',
    legalRefs: [
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu',
      '5271 sayılı Ceza Muhakemesi Kanunu',
      'Polis Görev ve Yetki Yönetmelikleri',
    ],
    keyPoints: [
      'Yetki kanunda yazılı olmalıdır; yetki aşımı sorumluluk doğurur.',
      'Hukuka aykırı emir yerine getirilmez, üste bildirilir.',
      'Görev dışı taleplere itaat zorunluluğu yoktur.',
    ],
    iconKey: 'badge',
  ),
];
