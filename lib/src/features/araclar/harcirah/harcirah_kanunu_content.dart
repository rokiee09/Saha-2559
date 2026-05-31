/// 6245 Harcırah Kanunu — uygulama içi özet (resmî metin esas alınmalıdır).
const String kHarcirahKanunuBaslik = '6245 sayılı Harcırah Kanunu (özet)';

const String kHarcirahKanunuMetin = '''
Bu bölüm, yol harcırahı hesaplamasında dikkate alınan başlıca ilkeleri hatırlatır. Kesin hak ve miktar, yürürlükteki kanun, yönetmelik, Cumhurbaşkanlığı kararnameleri ve kurum duyuruları ile belirlenir.

Günlük harcırah
• Görev veya tayin nedeniyle yapılan yolculuklarda, gidilecek yer ile memuriyet merkezi arasındaki mesafe ve yol süresi dikkate alınır.
• Günlük harcırah gün sayısı, uygulamada mesafe ve yol koşullarına göre belirlenir; bu hesaplayıcı örnek modelde mesafe / 60 formülünü kullanır.

Mesafe harcırahı
• Memur kendisi için mesafe harcırahı: günlük harcırah ücreti × 0,05 × mesafe (km).
• Eşi memur olanlar için mesafe harcırahı: 6245 sayılı Kanunun 45 inci maddesi uyarınca yarı oranda (× 0,025) hesaplanır.
• Eşin özel sektörde çalışması, harcırah hesabında “eş” statüsünü tek başına değiştirmez; kurum uygulaması esastır.

Eş ve çocuk
• Evli memurun eşi için günlük harcırah, eşin çalışma durumuna göre kurallara tabidir.
• Çocuklar için günlük harcırah gün sayısı, örnek modelde yetişkin gün sayısının yarısına yuvarlanır.
• Çocuklar için mesafe harcırahı satırı bu örnek tabloda yer almaz; kesin uygulama kurum işlemine bağlıdır.

Otobüs / taşıt ücreti
• Gerçek ve belgelendirilmiş yol ücreti ayrıca gösterilir; bilet veya kurum onaylı tarife esas alınmalıdır.

Mesafe
• Mesafeler il merkezleri arasında hesaplanır; ilçe–ilçe veya ilçe–il merkezi arası ek mesafe oluşabilir.
• Uygulamadaki km tahmini kuş uçuşu koordinat + karayolu katsayısıdır; resmî karayolu cetveli farklı olabilir (± %5 marj).

Derece / katsayı
• Harcırah ücreti, memurun derece ve görev türüne göre yıllık güncellenir. Bu uygulama varsayılan örnek ücret (850 TL) ile çalışır; güncel tabloyu kurum duyurusundan girin.

Uyarı
Bu metin ve hesap sonucu bilgilendirme amaçlıdır; ödeme, tahakkuk ve itiraz işlemleri yalnızca yetkili birimlerce yapılır.
''';

const List<String> kHarcirahNotlar = [
  'Hesaplamalar 2026 örnek ücretlerine göre yapılır; ücretler her yıl değişebilir.',
  'Eşin özel sektörde çalışması tek başına statü değiştirmez; kurum uygulaması esas alınır.',
  'Eşi memur olanlar için mesafe harcırahı 6245 s.45 uyarınca yarı oranda hesaplanır.',
  'Mesafeler il merkezleri arası tahmindir; ilçe güzergâhı ek mesafe doğurabilir.',
  'Km ve ücret için ± %5 marj uygulanabilir; kesin değer kurum işlemindedir.',
];
