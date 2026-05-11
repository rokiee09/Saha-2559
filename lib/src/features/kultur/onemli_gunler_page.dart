import 'package:flutter/material.dart';

/// Gün detayında hangi görsel kullanılacak (PNG eşlemesi).
enum OnemliGunGorseli {
  ataturkMatem,
  temmuz15,
  cumhuriyet,
  polisKurulus,
  genclik,
  zafer,
  egemenlik,
}

/// `assets/images/` altındaki önemli gün görselleri (PNG).
String _bannerAsset(OnemliGunGorseli g) {
  switch (g) {
    case OnemliGunGorseli.ataturkMatem:
      return 'assets/images/onemli_gun_10_kasim.png';
    case OnemliGunGorseli.temmuz15:
      return 'assets/images/onemli_gun_15_temmuz.png';
    case OnemliGunGorseli.cumhuriyet:
      return 'assets/images/onemli_gun_29_ekim.png';
    case OnemliGunGorseli.polisKurulus:
      return 'assets/images/onemli_gun_10_nisan.png';
    case OnemliGunGorseli.genclik:
      return 'assets/images/onemli_gun_19_mayis.png';
    case OnemliGunGorseli.zafer:
      return 'assets/images/onemli_gun_30_agustos.png';
    case OnemliGunGorseli.egemenlik:
      return 'assets/images/onemli_gun_23_nisan.png';
  }
}

/// Önemli günler listesinde ve detayda kullanılan kayıt.
class OnemliGunKaydi {
  final String date;
  final String title;
  final String shortDescription;
  final String fullContent;
  final OnemliGunGorseli gorsel;

  const OnemliGunKaydi(
    this.date,
    this.title,
    this.shortDescription,
    this.fullContent,
    this.gorsel,
  );

  String get bannerAsset => _bannerAsset(gorsel);
}

class OnemliGunlerPage extends StatelessWidget {
  const OnemliGunlerPage({super.key});

  static final List<OnemliGunKaydi> _days = [
    const OnemliGunKaydi(
      '10 Nisan',
      'Polis Teşkilatı Kuruluş Günü',
      '1845\'te polis teşkilatının kuruluşu anılır.',
      '10 Nisan 1845 tarihinde İstanbul\'da ilk modern polis teşkilatı kurulmuştur. '
          'Bu tarih, Emniyet Genel Müdürlüğü ve tüm polis camiası tarafından Polis Teşkilatı Kuruluş Günü olarak kutlanır. '
          'Merkez ve taşra birimlerinde törenler, mesajlar ve etkinliklerle anılır; polis personelinin vazife şuuru ve teşkilat bağlılığı vurgulanır.',
      OnemliGunGorseli.polisKurulus,
    ),
    const OnemliGunKaydi(
      '23 Nisan',
      'Ulusal Egemenlik ve Çocuk Bayramı',
      'TBMM\'nin açılışı ve milli egemenlik.',
      '23 Nisan 1920\'de Türkiye Büyük Millet Meclisi açılmış, milli egemenlik ilan edilmiştir. '
          'Gazi Mustafa Kemal Atatürk bu günü çocuklara armağan etmiştir. '
          'Ulusal Egemenlik ve Çocuk Bayramı olarak resmî törenler ve çocuk şenlikleriyle kutlanır.',
      OnemliGunGorseli.egemenlik,
    ),
    const OnemliGunKaydi(
      '19 Mayıs',
      'Atatürk\'ü Anma, Gençlik ve Spor Bayramı',
      '1919\'da Samsun\'a çıkış ve Kurtuluş mücadelesinin başlangıcı.',
      '19 Mayıs 1919\'da Mustafa Kemal Paşa\'nın Samsun\'a çıkışı, Millî Mücadele\'nin başlangıcı kabul edilir. '
          'Atatürk bu günü gençliğe armağan etmiştir. Atatürk\'ü Anma, Gençlik ve Spor Bayramı olarak stadyum törenleri ve spor etkinlikleriyle kutlanır.',
      OnemliGunGorseli.genclik,
    ),
    const OnemliGunKaydi(
      '30 Ağustos',
      'Zafer Bayramı',
      'Büyük Taarruz\'un zaferle sonuçlanması.',
      '30 Ağustos 1922\'de Dumlupınar\'da Başkomutanlık Meydan Muharebesi kazanılmış, Millî Mücadele zaferle sonuçlanmıştır. '
          'Zafer Bayramı, resmî törenler ve askerî geçitlerle kutlanır; şehit ve gaziler anılır.',
      OnemliGunGorseli.zafer,
    ),
    const OnemliGunKaydi(
      '29 Ekim',
      'Cumhuriyet Bayramı',
      'Cumhuriyetin ilanı.',
      '29 Ekim 1923\'te Cumhuriyet ilan edilmiş, Türkiye Cumhuriyeti\'nin temeli atılmıştır. '
          'Cumhuriyet Bayramı resmî tatil olup, yurt genelinde törenler, konuşmalar ve bayrak törenleriyle kutlanır.',
      OnemliGunGorseli.cumhuriyet,
    ),
    const OnemliGunKaydi(
      '10 Kasım',
      'Atatürk\'ü Anma Günü',
      'Atatürk\'ün ebediyete intikali.',
      '10 Kasım 1938\'de Gazi Mustafa Kemal Atatürk, Dolmabahçe Sarayı\'nda ebediyete intikal etmiştir. '
          'Her yıl 10 Kasım\'da saat 09.05\'te sirenlerle birlikte iki dakikalık saygı duruşu yapılır; anıt ve kabirlerde törenler düzenlenir. '
          'Atatürk\'ün ilke ve inkılapları, vatan ve millet sevgisi anılır.',
      OnemliGunGorseli.ataturkMatem,
    ),
    const OnemliGunKaydi(
      '15 Temmuz',
      'Demokrasi ve Milli Birlik Günü',
      '15 Temmuz hain darbe girişimine karşı mücadele ve şehitler anılır.',
      '15 Temmuz 2016\'da Türkiye Cumhuriyeti\'ne yönelik hain darbe girişimi, milletin meydanlara inmesi ve kahraman güvenlik güçlerinin direnişiyle bertaraf edilmiştir. '
          'Demokrasi ve Milli Birlik Günü, şehitlerimizin ve gazilerimizin anıldığı resmî törenlerle idrak edilir; demokrasi ve milli irade vurgulanır.',
      OnemliGunGorseli.temmuz15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Önemli Günler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Polis teşkilatı ve milli değerlerimizle ilgili önemli tarihler. Bir güne dokunun, detay ve anlamını görün.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ..._days.map((d) => _DayCard(day: d)),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final OnemliGunKaydi day;

  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OnemliGunDetayPage(day: day),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset(
                    day.bannerAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.calendar_month_rounded,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day.date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.shortDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detay sayfası: üstte kompakt görsel, altında metin.
class OnemliGunDetayPage extends StatelessWidget {
  final OnemliGunKaydi day;

  const OnemliGunDetayPage({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(day.date)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GunBanner(assetPath: day.bannerAsset),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    day.fullContent,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detay sayfası: kompakt gün görseli (kırpma yok; metin rahat görünsün).
class _GunBanner extends StatelessWidget {
  final String assetPath;

  const _GunBanner({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Ekranın ~%18–22’si; mutlak üst sınır — büyük banner metni ezer.
    final maxH = (MediaQuery.sizeOf(context).height * 0.2).clamp(120.0, 168.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => SizedBox(
            height: 72,
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 40,
              color: scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
