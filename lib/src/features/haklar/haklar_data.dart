import 'haklar_disiplin_savunma_content.dart';
import 'haklar_vatandaslik_content.dart';

/// Haklar: Polis personeline yönelik özet açıklamalar.
/// Teredditte güncel mevzuat, yönetmelik ve Emniyet duyuruları esas alınır.
enum HaklarCategory {
  tumu,
  izinHakki,
  disiplinVeSavunmaHakki,
  vatandaslikHaklari,
}

extension HaklarCategoryLabel on HaklarCategory {
  String get chipLabel {
    switch (this) {
      case HaklarCategory.tumu:
        return 'TÜMÜ';
      case HaklarCategory.izinHakki:
        return 'İZİN HAKLARI';
      case HaklarCategory.disiplinVeSavunmaHakki:
        return 'DİSİPLİN / SAVUNMA';
      case HaklarCategory.vatandaslikHaklari:
        return 'VATANDAŞLIK';
    }
  }

  String get listSubtitle {
    switch (this) {
      case HaklarCategory.tumu:
        return 'Tümü';
      case HaklarCategory.izinHakki:
        return 'İzin hakları';
      case HaklarCategory.disiplinVeSavunmaHakki:
        return 'Disiplin ve savunma hakkı';
      case HaklarCategory.vatandaslikHaklari:
        return 'Vatandaşlık hakları';
    }
  }
}

class RightItem {
  final String title;
  final String shortDescription;
  final String fullContent;
  final List<String> legalRefs;
  final List<String> keyPoints;
  final String iconKey;
  final HaklarCategory category;

  const RightItem({
    required this.title,
    required this.shortDescription,
    required this.fullContent,
    this.legalRefs = const [],
    this.keyPoints = const [],
    this.iconKey = 'info',
    required this.category,
  });
}

const List<RightItem> rightsData = [
  RightItem(
    category: HaklarCategory.izinHakki,
    title: 'İzin hakları',
    shortDescription:
        '657 sayılı DMK: yıllık, mazeret, doğum, süt, hastalık, refakat, ücretsiz izin. Polis özelinde Polis Personeli İzin Yönetmeliği, nöbet ve amir onayı da uygulanır.',
    fullContent:
        'Aşağıdaki özet, esasen 657 sayılı Devlet Memurları Kanununa (DMK) dayanır. Emniyet personelinde ayrıca Polis Personeli İzin Yönetmeliği, nöbet, operasyon ve amir onayı gibi uygulamalar birlikte gözetilmelidir. Kesin süre, birleştirme ve onay mercii için güncel kanun, yönetmelik ve biriminizin yazısını esas alınız.\n\n'
        'Yıllık izin\n\n'
        'Hizmet süresine göre yıllık izin hakkı vardır. Bir yıldan on yıla kadar (on yıl dahil): 20 gün. On yıldan fazla: 30 gün. Yıllık izinler, amirin uygun bulacağı zamanlarda kullanılabilir.\n\n'
        'Dayanak: 657 sayılı DMK Madde 102 ve 103.\n\n'
        'Mazeret izinleri\n\n'
        'Aşağıdaki hallerde mazeret izni verilir (örnekler):\n\n'
        'Eşin doğum yapması: 10 gün\n\n'
        'Memurun evlenmesi: 7 gün\n\n'
        'Çocuğunun evlenmesi: 7 gün\n\n'
        'Ana, baba, eş, çocuk veya kardeşin ölümü: 7 gün\n\n'
        'Dayanak: 657 sayılı DMK Madde 104.\n\n'
        'Doğum izni\n\n'
        'Kadın memur için: doğumdan önce 8 hafta, doğumdan sonra 8 hafta (toplam 16 hafta). Çoğul gebelikte, doğum öncesine 2 hafta eklenir.\n\n'
        'Dayanak: 657 sayılı DMK Madde 104.\n\n'
        'Süt izni\n\n'
        'Kadın memura doğum sonrası: ilk altı ay günde 3 saat, ikinci altı ay günde 1,5 saat (kanundaki oranlara göre).\n\n'
        'Dayanak: 657 sayılı DMK Madde 104.\n\n'
        'Hastalık izni\n\n'
        'Sağlık raporuna dayalı izin. On güne kadar: tek hekim raporu. Tek hekim raporları bir defada en fazla 10 gün verilebilir. Aynı hastalık için toplam süre 20 günü aşarsa sağlık kurulu (heyet) raporu gerekir.\n\n'
        'Kanser, verem, akıl hastalığı gibi uzun süreli hâllerde, kanunda öngörüldüğü üzere 18 aya kadar izin söz konusu olabilir (kesin sınır ve şartlar için güncel m. 105 metni ve sağlık mevzuatı).\n\n'
        'Dayanak: 657 sayılı DMK Madde 105.\n\n'
        'Refakat izni\n\n'
        'Memur; ağır hastalık şartlarında (hayati tehlike) sağlık kurulu raporu ile eşi, çocukları, ana veya babası için refakat izni alabilir. Süre: üç aya kadar; gerekirse bir kat uzatılabilir (toplam altı aya varan uygulama, kanun ve rapora göre).\n\n'
        'Dayanak: 657 sayılı DMK Madde 105.\n\n'
        'Ücretsiz izin (aylıksız izin)\n\n'
        'Belirli hâllerde aylıksız izin: doğum sonrası kadın memur için 24 aya kadar; eşin doğumunda erkek memura da; evlat edinmede 24 aya kadar; askerlik süresince; hizmet süresi beş yılını dolduran memurun isteği üzerine bir yıla kadar (ve diğer kanunî hâller) DMK’da düzenlenir.\n\n'
        'Dayanak: 657 sayılı DMK Madde 108.\n\n'
        'Polis teşkilatında izin talebi, onay, yol ve kullanım usulü için Polis Personeli İzin Yönetmeliğini ve kurum içi genelgeleri de kontrol ediniz.',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu — m. 102–103: yıllık izin süreleri ve kullanım.',
      '657 sayılı DMK — m. 104: mazeret, doğum ve süt izinleri (güncel gün/hafta oranları metinde).',
      '657 sayılı DMK — m. 105: hastalık, refakat ve sağlık raporları (tek hekim, heyet, süreler).',
      '657 sayılı DMK — m. 108: ücretsiz (aylıksız) izin hâlleri.',
      'Polis Personeli İzin Yönetmeliği — Emniyet uygulaması: talep, onay, nöbet ve yol usulü.',
    ],
    keyPoints: [
      'Yıllık: 1–10 yıl (dahil) 20 gün, 10 yıldan sonra 30 gün; kullanım amirin uygun gördüğü zamanda (m. 102–103).',
      'Mazeret, doğum ve süt: m. 104; vaka başına gün/hafta oranları kanunda (güncel metin).',
      'Hastalık: tek hekim, bir defada en fazla 10 gün; aynı hastalıkta toplam 20 gün aşımında kurul raporu; m. 105.',
      'Refakat: ağır hasta eş, çocuk, ana, baba; hayati tehlike ve kurul raporu; m. 105.',
      'Ücretsiz izin: m. 108; ayrıntılı hâl ve süreler güncel madde metnine bağlıdır.',
    ],
    iconKey: 'calendar',
  ),
  RightItem(
    category: HaklarCategory.disiplinVeSavunmaHakki,
    title: 'Disiplin ve savunma hakkı',
    shortDescription:
        '7068: m. 7–8 cezalar ve fiil tabloları, ek puanlar, m. 12–18 yetki ve onay. 657: savunma, zamanaşımı, itiraz. Tüzük ve genelgelerle birlikte okuyunuz.',
    fullContent: haklarDisiplinVeSavunmaFullContent,
    legalRefs: [
      '7068 sayılı Kanun — m. 5, 6, 7, 8 (alt bentler), 12, 13, 14, 15, 17, 18; Ek (ceza puanı çizelgesi, emniyet).',
      '657 sayılı Devlet Memurları Kanunu — m. 127 (zamanaşımı), 130 (savunma usulü), 135 (itiraz; güncel süreler).',
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu — Emniyet personelinin özlüğü ve disipline ilişkin genel çerçeve.',
      'Emniyet Teşkilatı Disiplin Tüzüğü ve kurum genelgeleri — 7068 ile birlikte uygulama ayrıntıları.',
    ],
    keyPoints: [
      'Cezalar: uyarma, kınama, aylıktan kesme, kısa/uzun süreli durdurma, meslekten ve memuriyetten çıkarma (7068/7).',
      'Fiil–ceza eşlemeleri 7068/8; kesin sütunlar yürürlükteki metin ve tablolarla doğrulanmalı.',
      'Puan: uyarma 1, kınama 2, aylık kesme 3, kısa durdurma 4, uzun durdurma 5; m. 12 eşikleri (20/40 puan, 12/25 amir cezası vb.).',
      'Yetki: disiplin amiri, il/merkez/yüksek disiplin kurulları, onay (vali, EGM, Bakan) m. 13–15, 17, 18.',
      'Savunma alınmadan ceza yok; süre 657/130; soruşturma 7068/14; 657/127–135 süreler ve itiraz.',
    ],
    iconKey: 'gavel',
  ),
  RightItem(
    category: HaklarCategory.vatandaslikHaklari,
    title: 'Vatandaşlık hakları',
    shortDescription:
        'Temel hak ve özgürlükler: yaşam, hürriyet, tutuklanmada bilgilendirme, özel hayat, konut, avukat, delil, geçersiz ifade, susma. Anayasa ve CMK ile birlikte değerlendirin.',
    fullContent: haklarVatandaslikFullContent,
    legalRefs: [
      'Türkiye Cumhuriyeti Anayasası — temel hak ve ödevler (kişinin dokunulmazlığı, özel hayat, konut dokunulmazlığı vb.; güncel metin).',
      '5237 sayılı Türk Ceza Kanunu — Ceza sorumluluğuna ilişkin genel ilkeler (güncel metin).',
      '5271 sayılı Ceza Muhakemesi Kanunu — soruşturma, ifade, gözaltı, tutuklama, savunma, delil ve usul (güncel metin).',
    ],
    keyPoints: [
      'Özgürlük ve güvenlik: yalnızca kanunda öngörülen haller ve usule uygun müdahale.',
      'Tutuklama ve bilgilendirme: sebep, haklar, yakınlara haber ve yargı önüne çıkma.',
      'Avukat ve susma: soruşturma aşamalarında yardım ve açıklama vermeme hakkı.',
      'İşkence ve yasa dışı baskıyla alınan ifade delil sayılamaz; delil toplama talebi.',
    ],
    iconKey: 'citizen',
  ),
];
