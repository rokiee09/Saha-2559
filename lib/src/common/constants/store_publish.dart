/// Google Play ve mağaza hazırlığı sabitleri.
const String kPrivacyPolicyUrl = 'https://rokiee09.github.io/Saha-2559/';

const String kPlayStorePackageId = 'com.coderipple.saha2559';

/// Play Console kısa açıklama (≤80 karakter).
const String kStoreShortDescription =
    'Mevzuat asistanı, güvenli kasa ve saha araçları — tamamen çevrimdışı.';

/// Play Console tam açıklama özeti (panoya kopyalanır).
const String kStoreFullDescription = '''
SAHA 2559, polis mevzuatı ve görev referanslarını internet bağlantısı olmadan
sunan BAĞIMSIZ bir bilgilendirme uygulamasıdır. Resmî kurum uygulaması değildir.

ÖNE ÇIKANLAR
• Mevzuat Asistanı: Olay anlatımına göre kaynaklı ön değerlendirme ve netleştirici sorular.
• Mevzuat: Kanun/yönetmelik, arama, favoriler, kişisel madde notları.
• Güvenlik merkezi: 6 haneli PIN, biyometrik, AES-256-GCM şifreli yerel veri, JSON yedek.
• Araçlar: Tutanak/dilekçe taslağı, emsal özetleri, trafik rehberi, idari para cezaları.
• Profilim: İzin takibi, kariyer, vardiya ve hesaplayıcılar.

GİZLİLİK
• Sunucuya kişisel veri gönderilmez; reklam/analitik yoktur.
• Hassas notlar ve şifre kasası yalnızca cihazda şifrelenir.

UYARI
Bilgilendirme amaçlıdır. Güncel mevzuat için mevzuat.gov.tr esas alınmalıdır.
''';

/// Mağaza ekran görüntüsü öneri listesi (Play Console yükleme rehberi).
const List<StoreScreenshotHint> kStoreScreenshotHints = [
  StoreScreenshotHint('01-anasayfa', 'Ana sayfa — hızlı geçiş ve günün maddesi'),
  StoreScreenshotHint('02-asistan', 'Mevzuat Asistanı — soru ve dayanaklı cevap'),
  StoreScreenshotHint('03-mevzuat', 'Mevzuat arama ve madde detayı'),
  StoreScreenshotHint('04-guvenlik', 'Güvenlik merkezi — şifreli veri listesi'),
  StoreScreenshotHint('05-araclar', 'Araçlar — tutanak, trafik, dilekçe'),
  StoreScreenshotHint('06-vardiya', 'Vardiya / izin veya profilim'),
];

class StoreScreenshotHint {
  const StoreScreenshotHint(this.fileName, this.caption);
  final String fileName;
  final String caption;
}
