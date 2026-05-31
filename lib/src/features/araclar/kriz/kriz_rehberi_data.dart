import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Kriz rehberi: kritik olaylarda adım adım kontrol listeleri.
/// Bilgilendirme amaçlıdır; resmî protokol, birim talimatı ve mevzuat esastır.

class KrizSenaryo {
  const KrizSenaryo({
    required this.id,
    required this.title,
    required this.icon,
    required this.ozet,
    required this.adimlar,
    this.yapma = const [],
    this.numaralar = const [],
  });

  final String id;
  final String title;
  final IconData icon;
  final String ozet;

  /// Sırayla yapılacak adımlar (kontrol listesi).
  final List<String> adimlar;

  /// Kaçınılması gereken davranışlar.
  final List<String> yapma;

  /// İlgili acil/destek hatları.
  final List<String> numaralar;
}

const List<KrizSenaryo> kKrizSenaryolari = [
  KrizSenaryo(
    id: 'intihar',
    title: 'İntihar girişimi',
    icon: PhosphorIconsRegular.lifebuoy,
    ozet:
        'Amaç kişinin güvenliğini sağlamak ve zaman kazanmak. Sakin, yargılamayan bir iletişim kur.',
    adimlar: [
      'Çevre güvenliğini al; meraklıları ve riski artıran unsurları uzaklaştır.',
      '112 sağlık ve gerekiyorsa itfaiyeyi yönlendir; ambulans hazır bulunsun.',
      'Kişiyle sakin, alçak sesle ve ismiyle konuş; aceleci hareket etme.',
      'Onu dinle, yargılama; "yanındayım, konuşalım" mesajını ver.',
      'Tehlikeli cisimleri (silah, ilaç, ip vb.) güvenle uzaklaştırmaya çalış.',
      'Pencere/yükseklik/su gibi durumlarda ani hamleden kaçın, mesafeyi koru.',
      'Yakınlarına ve varsa ruh sağlığı ekibine haber ver.',
      'Kişi güvenceye alındığında sağlık kuruluşuna sevki sağla ve tutanak tut.',
    ],
    yapma: [
      '"Yapmazsın zaten" gibi küçümseyici ifadeler kullanma.',
      'Aniden üzerine yürüme veya bağırma.',
      'Yalnız ve teyitsiz söz verme (tutamayacağın vaatler).',
    ],
    numaralar: ['Acil: 112'],
  ),
  KrizSenaryo(
    id: 'aile_ici',
    title: 'Aile içi şiddet',
    icon: PhosphorIconsRegular.house,
    ozet:
        'Önce can güvenliği. Mağduru failden ayır, delili koru, koruyucu tedbir yollarını işlet (6284).',
    adimlar: [
      'Olay yerinde tarafları fiziksel olarak ayır; saldırıyı durdur.',
      'Yaralı varsa 112’yi çağır, ilk yardımı önceliklendir.',
      'Mağdurla failden uzakta, güvenli bir alanda görüş.',
      'Çocuk varsa güvenliğini ayrıca değerlendir.',
      'Delilleri koru: darp izleri, kırık eşya, mesaj/kayıtlar, tanıklar.',
      '6284 sayılı Kanun kapsamında koruyucu/önleyici tedbir bilgisini ver.',
      'Mağdura ŞÖNİM ve sığınma evi seçeneklerini hatırlat.',
      'Olay ve ifade tutanaklarını eksiksiz düzenle; gerekiyorsa gözaltı işlemini başlat.',
    ],
    yapma: [
      'Tarafları "barıştırıp" olayı kapatma; bu bir suçtur.',
      'Mağduru failin yanında ifade vermeye zorlama.',
      'Delil ve şikâyet olmadan da resen işlem yapılabileceğini unutma.',
    ],
    numaralar: ['Acil: 112', 'ALO 183 Sosyal Destek'],
  ),
  KrizSenaryo(
    id: 'cocuk_istismari',
    title: 'Çocuk istismarı şüphesi',
    icon: PhosphorIconsRegular.baby,
    ozet:
        'Çocuğun üstün yararı esas. İkincil örselenmeyi önle; uzman birime ve adli süreçlere yönlendir.',
    adimlar: [
      'Çocuğun acil güvenliğini sağla; şüpheliden uzaklaştır.',
      'Sağlık kontrolü için 112 / sağlık kuruluşuna yönlendir.',
      'Çocukla tekrarlı ifade alma; tek ve uzman eşliğinde (adli görüşme odası) esas.',
      'Çocuk İzlem Merkezi (ÇİM) ve çocuk şube/uzman birimi devreye al.',
      'Cumhuriyet savcısını bilgilendir; talimat doğrultusunda hareket et.',
      'Delilleri koru; ortamı ve eşyaları muhafaza altına al.',
      'Aile/koruyucu hakkında risk değerlendirmesi yap, koruma tedbiri öner.',
      'İşlemleri gizlilik içinde ve çocuğun mahremiyetini koruyarak yürüt.',
    ],
    yapma: [
      'Çocuğa olayı defalarca anlattırma.',
      'Şüpheliyle çocuğu yüzleştirme.',
      'Olayı çevreye/medyaya ifşa etme; gizlilik esastır.',
    ],
    numaralar: ['Acil: 112', 'ALO 183'],
  ),
  KrizSenaryo(
    id: 'trafik_kazasi',
    title: 'Ölümlü/yaralı trafik kazası',
    icon: PhosphorIconsRegular.car,
    ozet: 'Önce can kurtarma ve ikincil kaza önleme; sonra delil ve tespit.',
    adimlar: [
      'Olay yerini koru; reflektör/işaretle ikincil kazayı önle.',
      '112 sağlık ve gerekiyorsa itfaiyeyi çağır.',
      'Yaralılara müdahale önceliği; gereksiz yere araç/yaralı oynatma.',
      'Trafiği yönet, güvenli geçiş sağla.',
      'Tanık ve sürücü bilgilerini al; kaçan araç varsa eşkâl/plaka tespiti.',
      'Kaza yeri krokisi, fotoğraf ve iz-delilleri belgele.',
      'Alkol/uyuşturucu kontrolünü uygula.',
      'Kaza tespit tutanağını düzenle, ilgili birimlere bildir.',
    ],
    yapma: [
      'Yeterli koruma almadan yola çıkma.',
      'Ağır yaralıyı zorunlu olmadıkça hareket ettirme.',
    ],
    numaralar: ['Acil: 112'],
  ),
  KrizSenaryo(
    id: 'supheli_paket',
    title: 'Şüpheli paket / cisim',
    icon: PhosphorIconsRegular.package,
    ozet: 'Dokunma, açma, taşıma. Mesafe-tahliye-uzman ekip mantığı.',
    adimlar: [
      'Cisme dokunma, açma, koklama; konumunu not et.',
      'Telsiz/telefonu cismin yakınında kullanma.',
      'Geniş güvenlik çemberi oluştur, bölgeyi tahliye et.',
      'Bomba imha / TEM uzman ekibini çağır.',
      'Görgü tanıklarını ve cismi bırakan kişiye dair bilgiyi topla.',
      'Olay yeri giriş-çıkışını kontrol altına al.',
      'Uzman ekip gelene kadar kimseyi yaklaştırma.',
    ],
    yapma: [
      'Cismi kendin incelemeye/taşımaya çalışma.',
      'Yakınında telsiz/cep telefonu ile sinyal verme.',
    ],
    numaralar: ['Acil: 112'],
  ),
];
