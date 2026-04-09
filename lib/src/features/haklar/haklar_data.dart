/// Haklar: Polis personeline yönelik özet açıklamalar.
/// Teredditte güncel mevzuat, yönetmelik ve Emniyet duyuruları esas alınır.
enum HaklarCategory {
  tumu,
  izinHaklari,
  disiplinYonetmeligi,
  rutbeSinavlari,
  tayinAtama,
}

extension HaklarCategoryLabel on HaklarCategory {
  String get chipLabel {
    switch (this) {
      case HaklarCategory.tumu:
        return 'TÜMÜ';
      case HaklarCategory.izinHaklari:
        return 'İZİN HAKLARI';
      case HaklarCategory.disiplinYonetmeligi:
        return 'DİSİPLİN';
      case HaklarCategory.rutbeSinavlari:
        return 'RÜTBE SINAVLARI';
      case HaklarCategory.tayinAtama:
        return 'TAYİN / ATAMA';
    }
  }

  String get listSubtitle {
    switch (this) {
      case HaklarCategory.tumu:
        return 'Tümü';
      case HaklarCategory.izinHaklari:
        return 'İzin hakları';
      case HaklarCategory.disiplinYonetmeligi:
        return 'Disiplin yönetmeliği';
      case HaklarCategory.rutbeSinavlari:
        return 'Polis rütbe sınavları';
      case HaklarCategory.tayinAtama:
        return 'Tayin ve atama';
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
    category: HaklarCategory.izinHaklari,
    title: 'İzin hakları (yıllık, mazeret, hastalık)',
    shortDescription:
        '657 sayılı Kanun ve Polis Personeli İzin Yönetmeliği: yıllık süreler, mazeretler, rapor, nöbet ve amir onayı birlikte işler.',
    fullContent:
        'Polis personelinin izinleri esas olarak 657 sayılı Devlet Memurları Kanununun izinle ilgili maddeleri ve Polis Personeli İzin Yönetmeliği ile düzenlenir. Yıllık izin süreleri hizmet yılına göre (örneğin bir–on yıl arası ile on yıldan fazla) farklıdır; kanunda yazılı gün sayısı esastır.\n\n'
        'Mazeret izinleri (evlilik, vefat, doğum, babalık vb.) 104 üncü maddede olay türüne göre süreleriyle birlikte gösterilir. Hastalık ve raporlu izinler sağlık kuruluşu raporuna dayanır; tek hekim ve heyet süreleri sağlık mevzuatına göre belirlenir.\n\n'
        'Poliste nöbet, operasyon ve asayiş önceliği nedeniyle izin kullanımı çoğu zaman yazılı talep ve amir onayı ile planlanır. Yol süreleri ve birleştirme kuralları yönetmelik ve kurum uygulamasına bağlıdır. Kesin gün sayısı, mesafe tablosu ve onay mercii için güncel yönetmelik ile biriminizin izin yazısını esas alınız.',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu — m. 102–108: yıllık izin, mazeret, hastalık, ücretsiz izin çerçevesi.',
      'Polis Personeli İzin Yönetmeliği — Poliste talep, onay, yol ve kullanım usulü.',
    ],
    keyPoints: [
      'Yıllık izin süresi hizmet yılına göre kanunda belli olur.',
      'Mazeret süreleri olay türüne göre 104 üncü maddede ayrı ayrıdır.',
      'Hastalık izni rapora dayanır; heyet gereği sürelere dikkat.',
      'Nöbet ve görev nedeniyle onay ve planlama zorunludur.',
    ],
    iconKey: 'calendar',
  ),
  RightItem(
    category: HaklarCategory.disiplinYonetmeligi,
    title: 'Disiplin yönetmeliği (Emniyet ve genel çerçeve)',
    shortDescription:
        'Emniyet Teşkilatı Disiplin Tüzüğü, 7068 ve 657: suç–ceza eşlemesi, soruşturma, savunma ve ceza türleri.',
    fullContent:
        'Emniyet personelinin disiplin sorumluluğu; 657 sayılı Kanunun genel disiplin hükümleri, 7068 sayılı Genel Kolluk Disiplin Hükümleri ve Emniyet Teşkilatı Disiplin Tüzüğü ile birlikte değerlendirilir. Tüzükte polis özelinde sayılan fiiller ve öngörülen disiplin cezaları (uyarmadan çıkarmaya kadar) tablolar halinde düzenlenir.\n\n'
        'Disiplin soruşturmasında isnat, delil toplama ve savunma hakkı usule bağlıdır; savunma alınmadan veya süre kaçırılarak verilen ceza yargı denetiminde iptal edilebilir. İdari soruşturma ile disiplin soruşturması farklı süreçler olabilir; karıştırılmamalıdır.\n\n'
        'Ceza türü ve süresi için yürürlükteki tüzük metni ve güncel değişiklikler esas alınmalıdır. Teredditte hukuk müşaviri veya disiplin birimine başvurunuz.',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu — Disiplin cezaları ve soruşturma usulü (ör. m. 125 ve ilgili maddeler).',
      '7068 sayılı Kanun — Genel kolluk disiplin çerçevesi.',
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu — Emniyet disiplinine ilişkin genel düzenleme.',
      'Emniyet Teşkilatı Disiplin Tüzüğü — Suç ve ceza tabloları (güncel metin).',
    ],
    keyPoints: [
      'Polise özel fiiller ve ceza skalası Disiplin Tüzüğünde.',
      'Savunma hakkı ve süreler usule bağlıdır.',
      '657 ve 7068 genel hatları; somut ceza tüzükte.',
      'Güncel tüzük metni ve genelge değişikliklerini takip edin.',
    ],
    iconKey: 'gavel',
  ),
  RightItem(
    category: HaklarCategory.rutbeSinavlari,
    title: 'Polis rütbe sınavları ve terfi',
    shortDescription:
        'Sınav duyurusu, başvuru şartları, konu müfredatı ve sıra–kadro Emniyet yönetmelikleri ve ilanlarla belirlenir.',
    fullContent:
        'Rütbe yükselmesi ve unvan değişikliği süreçleri; 657 sayılı Kanundaki terfi ve sınav esasları ile Emniyet Genel Müdürlüğünün terfi, sınav ve yarışma sınavlarına ilişkin yönetmelikleri çerçevesinde yürür. Hangi rütbe için hangi sınavın (yazılı, sözlü, mülakat vb.) yapılacağı, başvuru tarihleri ve baraj puanları her dönem ayrı ilan edilir.\n\n'
        'Genelde aranan unsurlar: hizmet süresi, sicil durumu, eğitim şartı, yaş üst sınırı ve boş kadro. Sınav konuları ve kaynak listesi duyuruda yayımlanır; hazırlıkta güncel yönetmelik ve son ilan metni esas alınmalıdır.\n\n'
        'Sınav ve terfi sonuçları itiraza açılabilir; süre ve şekil ilanda belirtilir. Kesin bilgi için Emniyet resmi duyuruları ve özlük biriminiz kullanılır.',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu — Terfi, sınav ve sicil genel çerçevesi.',
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu — Emniyet personel özlüğü.',
      'Emniyet Genel Müdürlüğü terfi ve sınav yönetmelikleri — Başvuru, sınav ve sıra (güncel ilanlar).',
    ],
    keyPoints: [
      'Şartlar ve sınav takvimi ilanla gelir; sabit tek tablo yoktur.',
      'Sicil, süre, yaş ve eğitim şartları birlikte aranır.',
      'Konu ve kaynak listesi duyuruda yayımlanır.',
      'İtiraz süresi ve mercii ilan metninde yazılır.',
    ],
    iconKey: 'school',
  ),
  RightItem(
    category: HaklarCategory.tayinAtama,
    title: 'Tayin ve atama (yer değiştirme, nakil)',
    shortDescription:
        'İlk atama, nakil ve geçici görev: hizmet ihtiyacı, kadro, sıra ve idare takdiri; yazılı gerekçe ve itiraz yolları usule bağlı.',
    fullContent:
        'Atama, personelin bir kadroya ilk kez veya başka bir görev yerine tayini; nakil ise bir birimden diğerine yer değiştirmedir. Esaslar 657 sayılı Kanunda; emniyette ek olarak 2559 sayılı Kanun ve ilgili yönetmelikler uygulanır. Geçici görevlendirme süreli ve genelde geri dönüşlüdür.\n\n'
        'Nakil ve tayinlerde hizmetin gerekleri, boş kadro, sıra ve bazen sınav veya ihale usulü söz konusu olabilir. Kararlarda yazılı gerekçe gösterme ve dosya inceleme hakkı usule bağlıdır. İşlemin hukuka aykırı olduğu düşünülüyorsa (yetki, usul, keyfilik) idari yargı yoluna başvurulabilir; süre çoğunlukla tebliğden başlar.\n\n'
        'Adaylık döneminde nakil kısıtları ve özel tayin usulleri ayrıca kanunda düzenlenir. Güncel atama ve nakil genelgelerini kurum duyurularından izleyiniz.',
    legalRefs: [
      '657 sayılı Devlet Memurları Kanunu — Atama, nakil ve geçici görev.',
      '2559 sayılı Polis Vazife ve Salahiyet Kanunu — Emniyet atama ve yer değiştirme.',
      'İlgili Emniyet atama ve nakil yönetmelikleri / genelgeler — Güncel duyurular.',
    ],
    keyPoints: [
      'Atama ve nakil hizmet, kadro ve sıraya bağlıdır.',
      'Yazılı gerekçe ve tebliğ süreleri önemlidir.',
      'Hukuka aykırılıkta idari yargı; süre kaçırılmamalı.',
      'Adaylık ve özel haller kanunda ayrı düzenlenir.',
    ],
    iconKey: 'badge',
  ),
];
