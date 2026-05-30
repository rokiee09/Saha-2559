// Disiplin rehberi verisi — 7068 sayılı Kanun ve 657 atıflarından özet/derleme.
// Bilgilendirme amaçlıdır; kesin ceza ve eşleştirme için yürürlükteki Resmî
// Gazete metni, Emniyet Teşkilatı Disiplin Tüzüğü ve kurum onayı esastır.

/// Ceza türü (artan ağırlık) ve özet ceza puanı.
enum DisiplinCezaTuru {
  uyarma,
  kinama,
  ayliktanKesme,
  kisaDurdurma,
  uzunDurdurma,
  meslektenCikarma,
}

extension DisiplinCezaTuruX on DisiplinCezaTuru {
  String get label => switch (this) {
        DisiplinCezaTuru.uyarma => 'Uyarma',
        DisiplinCezaTuru.kinama => 'Kınama',
        DisiplinCezaTuru.ayliktanKesme => 'Aylıktan kesme',
        DisiplinCezaTuru.kisaDurdurma => 'Kısa süreli durdurma',
        DisiplinCezaTuru.uzunDurdurma => 'Uzun süreli durdurma',
        DisiplinCezaTuru.meslektenCikarma => 'Meslekten çıkarma',
      };

  /// Özet ceza puanı (emniyet uygulama çizelgesi atfı). Çıkarmada puan yok.
  int? get puan => switch (this) {
        DisiplinCezaTuru.uyarma => 1,
        DisiplinCezaTuru.kinama => 2,
        DisiplinCezaTuru.ayliktanKesme => 3,
        DisiplinCezaTuru.kisaDurdurma => 4,
        DisiplinCezaTuru.uzunDurdurma => 5,
        DisiplinCezaTuru.meslektenCikarma => null,
      };

  String get aciklama => switch (this) {
        DisiplinCezaTuru.uyarma =>
          'Daha dikkatli olunması gerektiğinin yazı ile bildirilmesi.',
        DisiplinCezaTuru.kinama =>
          'Görevde veya hâl ve hareketlerde kusurlu olunduğunun yazı ile bildirilmesi.',
        DisiplinCezaTuru.ayliktanKesme =>
          'Brüt aylıktan (zam/tazminat hariç) en fazla 15 güne kadar kesinti.',
        DisiplinCezaTuru.kisaDurdurma =>
          'Kademe ilerlemesinin 4, 6 veya 10 ay durdurulması.',
        DisiplinCezaTuru.uzunDurdurma =>
          'Kademe ilerlemesinin 12, 16, 20 veya 24 ay durdurulması.',
        DisiplinCezaTuru.meslektenCikarma =>
          'Emniyet teşkilatından (veya memuriyetten) çıkarma.',
      };
}

class DisiplinFiil {
  const DisiplinFiil({
    required this.id,
    required this.baslik,
    required this.ceza,
    required this.dayanak,
    this.detay = '',
    this.anahtarlar = const [],
  });

  final String id;
  final String baslik;
  final DisiplinCezaTuru ceza;

  /// Yasal dayanak (ör. "7068 m. 8/1").
  final String dayanak;

  /// Kısa ek açıklama / değişebilirlik notu.
  final String detay;

  /// Arama için ek anahtar kelimeler.
  final List<String> anahtarlar;
}

/// Sık karşılaşılan disiplinsizlik örnekleri (7068 m. 8 sütunlarından derleme).
const List<DisiplinFiil> kDisiplinFiilleri = [
  // Uyarma (8/1)
  DisiplinFiil(
    id: 'mesaiye_gec',
    baslik: 'Mesaiye geç gelmek veya erken ayrılmak',
    ceza: DisiplinCezaTuru.uyarma,
    dayanak: '7068 m. 8/1',
    detay: 'Tekrarı ve mazeretsizliği ağırlaştırıcı değerlendirilebilir.',
    anahtarlar: ['geç kalma', 'mesai', 'erken çıkma'],
  ),
  DisiplinFiil(
    id: 'kilik_kiyafet',
    baslik: 'Silah, araç-gereç, giyim ve kuşamı temiz tutmamak',
    ceza: DisiplinCezaTuru.uyarma,
    dayanak: '7068 m. 8/1',
    anahtarlar: ['kıyafet', 'temizlik', 'üniforma'],
  ),
  DisiplinFiil(
    id: 'nezaket',
    baslik: 'Nezaket kurallarına aykırı davranmak',
    ceza: DisiplinCezaTuru.uyarma,
    dayanak: '7068 m. 8/1',
    anahtarlar: ['nezaket', 'kaba'],
  ),
  DisiplinFiil(
    id: 'emre_itiraz_alenen',
    baslik: 'Emri uygun bulmadığını alenen söylemek / itiraz etmek',
    ceza: DisiplinCezaTuru.uyarma,
    dayanak: '7068 m. 8/1',
    anahtarlar: ['emir', 'itiraz'],
  ),
  // Kınama (8/2)
  DisiplinFiil(
    id: 'nobet_gec_donme',
    baslik: 'Nöbet sonrası göreve geç dönmek',
    ceza: DisiplinCezaTuru.kinama,
    dayanak: '7068 m. 8/2',
    anahtarlar: ['nöbet', 'geç dönme'],
  ),
  DisiplinFiil(
    id: 'gorevi_savsaklamak',
    baslik: 'Görevi savsaklamak / sorumluluktan kaçınmak',
    ceza: DisiplinCezaTuru.kinama,
    dayanak: '7068 m. 8/2',
    anahtarlar: ['savsaklama', 'ihmal'],
  ),
  DisiplinFiil(
    id: 'saygisiz_arkadas',
    baslik: 'Mesai arkadaşlarına saygısız davranmak',
    ceza: DisiplinCezaTuru.kinama,
    dayanak: '7068 m. 8/2',
    anahtarlar: ['saygısızlık'],
  ),
  DisiplinFiil(
    id: 'usulsuz_sikayet',
    baslik: 'Usule aykırı şikâyet veya müracaat yapmak',
    ceza: DisiplinCezaTuru.kinama,
    dayanak: '7068 m. 8/2',
    anahtarlar: ['şikayet', 'müracaat'],
  ),
  // Aylıktan kesme (8/3)
  DisiplinFiil(
    id: 'gore_gelmeme_24',
    baslik: '24 saate kadar göreve gelmemek / nöbete gelmemek',
    ceza: DisiplinCezaTuru.ayliktanKesme,
    dayanak: '7068 m. 8/3',
    detay: 'Üç güne kadar kesme grubunda örneklenir.',
    anahtarlar: ['göreve gelmeme', 'devamsızlık', 'nöbet'],
  ),
  DisiplinFiil(
    id: 'izinsiz_il_disi',
    baslik: 'İzinsiz il dışına çıkmak',
    ceza: DisiplinCezaTuru.ayliktanKesme,
    dayanak: '7068 m. 8/3',
    anahtarlar: ['izinsiz', 'il dışı'],
  ),
  DisiplinFiil(
    id: 'hakaret',
    baslik: 'Hakaret etmek',
    ceza: DisiplinCezaTuru.ayliktanKesme,
    dayanak: '7068 m. 8/3',
    detay: 'Dört–on güne kadar kesme grubunda; muhatap/şekle göre ağırlaşabilir.',
    anahtarlar: ['hakaret', 'küfür'],
  ),
  DisiplinFiil(
    id: 'kamu_araci_ozel',
    baslik: 'Kamu araçlarını özel işte kullanmak',
    ceza: DisiplinCezaTuru.ayliktanKesme,
    dayanak: '7068 m. 8/3',
    anahtarlar: ['araç', 'özel iş'],
  ),
  DisiplinFiil(
    id: 'kimlik_kaybi',
    baslik: 'Kimlik kartını kaybetmek',
    ceza: DisiplinCezaTuru.ayliktanKesme,
    dayanak: '7068 m. 8/3',
    anahtarlar: ['kimlik', 'kayıp'],
  ),
  // Kısa süreli durdurma (8/4)
  DisiplinFiil(
    id: 'amire_yalan',
    baslik: 'Amirine yalan söylemek',
    ceza: DisiplinCezaTuru.kisaDurdurma,
    dayanak: '7068 m. 8/4',
    detay: 'Dört ay grubunda örneklenir.',
    anahtarlar: ['yalan', 'amir'],
  ),
  DisiplinFiil(
    id: 'gore_gelmeme_3_5',
    baslik: '3–5 gün göreve gelmemek',
    ceza: DisiplinCezaTuru.kisaDurdurma,
    dayanak: '7068 m. 8/4',
    anahtarlar: ['devamsızlık', 'göreve gelmeme'],
  ),
  DisiplinFiil(
    id: 'telsiz_uygunsuz',
    baslik: 'Telsizle uygunsuz konuşmak',
    ceza: DisiplinCezaTuru.kisaDurdurma,
    dayanak: '7068 m. 8/4',
    detay: 'Altı ay grubunda örneklenir.',
    anahtarlar: ['telsiz', 'muhabere'],
  ),
  DisiplinFiil(
    id: 'yetkisiz_basin',
    baslik: 'Yetkisiz basına konuşmak',
    ceza: DisiplinCezaTuru.kisaDurdurma,
    dayanak: '7068 m. 8/4',
    detay: 'On ay grubunda örneklenir.',
    anahtarlar: ['basın', 'medya'],
  ),
  // Uzun süreli durdurma (8/5)
  DisiplinFiil(
    id: 'gorevde_uyumak',
    baslik: 'Görevde uyumak',
    ceza: DisiplinCezaTuru.uzunDurdurma,
    dayanak: '7068 m. 8/5',
    detay: 'On altı ay grubunda örneklenir.',
    anahtarlar: ['uyumak', 'nöbet'],
  ),
  DisiplinFiil(
    id: 'amire_hakaret',
    baslik: 'Amirine hakaret etmek',
    ceza: DisiplinCezaTuru.uzunDurdurma,
    dayanak: '7068 m. 8/5',
    detay: 'Yirmi dört ay grubunda örneklenir.',
    anahtarlar: ['amir', 'hakaret'],
  ),
  DisiplinFiil(
    id: 'gorev_yeri_terk',
    baslik: 'Görev yerini terk etmek / emre itaatsizlik',
    ceza: DisiplinCezaTuru.uzunDurdurma,
    dayanak: '7068 m. 8/5',
    anahtarlar: ['görev terk', 'itaatsizlik'],
  ),
  DisiplinFiil(
    id: 'supheli_kacirma',
    baslik: 'Şüphelinin kaçmasına sebep olmak',
    ceza: DisiplinCezaTuru.uzunDurdurma,
    dayanak: '7068 m. 8/5',
    detay: 'Yirmi ay grubunda örneklenir.',
    anahtarlar: ['kaçırma', 'şüpheli'],
  ),
  // Meslekten çıkarma (8/6)
  DisiplinFiil(
    id: 'rusvet',
    baslik: 'Rüşvet / menfaat sağlamak',
    ceza: DisiplinCezaTuru.meslektenCikarma,
    dayanak: '7068 m. 8/6',
    anahtarlar: ['rüşvet', 'menfaat'],
  ),
  DisiplinFiil(
    id: 'uyusturucu',
    baslik: 'Uyuşturucu kullanmak',
    ceza: DisiplinCezaTuru.meslektenCikarma,
    dayanak: '7068 m. 8/6',
    anahtarlar: ['uyuşturucu', 'madde'],
  ),
  DisiplinFiil(
    id: 'delil_yok',
    baslik: 'Delil yok etmek',
    ceza: DisiplinCezaTuru.meslektenCikarma,
    dayanak: '7068 m. 8/6',
    anahtarlar: ['delil', 'karartma'],
  ),
  DisiplinFiil(
    id: 'kisisel_veri',
    baslik: 'Kişisel verileri hukuka aykırı kullanmak',
    ceza: DisiplinCezaTuru.meslektenCikarma,
    dayanak: '7068 m. 8/6',
    anahtarlar: ['kişisel veri', 'sorgu', 'pol-net'],
  ),
];

/// Tüm fiiller için ortak savunma süreci özeti.
const List<String> kDisiplinSavunmaAdimlari = [
  'Savunman alınmadan disiplin cezası verilemez (657 m. 130).',
  'Disiplinsizlik tespit edilir; yetkili amir/kurul soruşturma başlatır (7068 m. 14).',
  'Deliller toplanır; soruşturmacı ifade alabilir, tanık dinleyebilir, belge inceleyebilir.',
  'Senden yazılı savunma istenir; bunun için süre (genelde en az 7 gün) verilir.',
  'Savunman ve geçmiş disiplin durumun değerlendirilerek karar verilir (7068 m. 6).',
];

/// İtiraz yolu özeti.
const List<String> kDisiplinItirazAdimlari = [
  'Ceza sana yazılı tebliğ edilir; tebliğden itibaren süre (genelde 7 gün) içinde itiraz edebilirsin (657 m. 135).',
  'İtiraz, cezayı veren amirin bir üstüne ya da yetkili disiplin kuruluna yapılır.',
  'İtiraz mercii kararı; cezayı kaldırabilir, hafifletebilir ya da onaylayabilir.',
  'Kesinleşen cezalara karşı idari yargıda dava açma hakkın saklıdır (süreler 2577 sayılı Kanun’a tabidir).',
];
