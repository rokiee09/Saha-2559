import 'package:flutter/material.dart';

/// Gün detayında gösterilecek görsel türü (10 Kasım matem + Atatürk, 15 Temmuz simgesi vb.)
enum _GunGorsel {
  ataturkMatem,
  temmuz15,
  cumhuriyet,
  polisKurulus,
  genclik,
  zafer,
  egemenlik,
}

class _Day {
  final String date;
  final String title;
  final String shortDescription;
  final String fullContent;
  final _GunGorsel gorsel;

  _Day(
    this.date,
    this.title,
    this.shortDescription,
    this.fullContent,
    this.gorsel,
  );
}

class OnemliGunlerPage extends StatelessWidget {
  const OnemliGunlerPage({super.key});

  static final List<_Day> _days = [
    _Day(
      '10 Nisan',
      'Polis Teşkilatı Kuruluş Günü',
      '1845\'te polis teşkilatının kuruluşu anılır.',
      '10 Nisan 1845 tarihinde İstanbul\'da ilk modern polis teşkilatı kurulmuştur. '
          'Bu tarih, Emniyet Genel Müdürlüğü ve tüm polis camiası tarafından Polis Teşkilatı Kuruluş Günü olarak kutlanır. '
          'Merkez ve taşra birimlerinde törenler, mesajlar ve etkinliklerle anılır; polis personelinin vazife şuuru ve teşkilat bağlılığı vurgulanır.',
      _GunGorsel.polisKurulus,
    ),
    _Day(
      '23 Nisan',
      'Ulusal Egemenlik ve Çocuk Bayramı',
      'TBMM\'nin açılışı ve milli egemenlik.',
      '23 Nisan 1920\'de Türkiye Büyük Millet Meclisi açılmış, milli egemenlik ilan edilmiştir. '
          'Gazi Mustafa Kemal Atatürk bu günü çocuklara armağan etmiştir. '
          'Ulusal Egemenlik ve Çocuk Bayramı olarak resmî törenler ve çocuk şenlikleriyle kutlanır.',
      _GunGorsel.egemenlik,
    ),
    _Day(
      '19 Mayıs',
      'Atatürk\'ü Anma, Gençlik ve Spor Bayramı',
      '1919\'da Samsun\'a çıkış ve Kurtuluş mücadelesinin başlangıcı.',
      '19 Mayıs 1919\'da Mustafa Kemal Paşa\'nın Samsun\'a çıkışı, Millî Mücadele\'nin başlangıcı kabul edilir. '
          'Atatürk bu günü gençliğe armağan etmiştir. Atatürk\'ü Anma, Gençlik ve Spor Bayramı olarak stadyum törenleri ve spor etkinlikleriyle kutlanır.',
      _GunGorsel.genclik,
    ),
    _Day(
      '30 Ağustos',
      'Zafer Bayramı',
      'Büyük Taarruz\'un zaferle sonuçlanması.',
      '30 Ağustos 1922\'de Dumlupınar\'da Başkomutanlık Meydan Muharebesi kazanılmış, Millî Mücadele zaferle sonuçlanmıştır. '
          'Zafer Bayramı, resmî törenler ve askerî geçitlerle kutlanır; şehit ve gaziler anılır.',
      _GunGorsel.zafer,
    ),
    _Day(
      '29 Ekim',
      'Cumhuriyet Bayramı',
      'Cumhuriyetin ilanı.',
      '29 Ekim 1923\'te Cumhuriyet ilan edilmiş, Türkiye Cumhuriyeti\'nin temeli atılmıştır. '
          'Cumhuriyet Bayramı resmî tatil olup, yurt genelinde törenler, konuşmalar ve bayrak törenleriyle kutlanır.',
      _GunGorsel.cumhuriyet,
    ),
    _Day(
      '10 Kasım',
      'Atatürk\'ü Anma Günü',
      'Atatürk\'ün ebediyete intikali.',
      '10 Kasım 1938\'de Gazi Mustafa Kemal Atatürk, Dolmabahçe Sarayı\'nda ebediyete intikal etmiştir. '
          'Her yıl 10 Kasım\'da saat 09.05\'te sirenlerle birlikte iki dakikalık saygı duruşu yapılır; anıt ve kabirlerde törenler düzenlenir. '
          'Atatürk\'ün ilke ve inkılapları, vatan ve millet sevgisi anılır.',
      _GunGorsel.ataturkMatem,
    ),
    _Day(
      '15 Temmuz',
      'Demokrasi ve Milli Birlik Günü',
      '15 Temmuz hain darbe girişimine karşı mücadele ve şehitler anılır.',
      '15 Temmuz 2016\'da Türkiye Cumhuriyeti\'ne yönelik hain darbe girişimi, milletin meydanlara inmesi ve kahraman güvenlik güçlerinin direnişiyle bertaraf edilmiştir. '
          'Demokrasi ve Milli Birlik Günü, şehitlerimizin ve gazilerimizin anıldığı resmî törenlerle idrak edilir; demokrasi ve milli irade vurgulanır.',
      _GunGorsel.temmuz15,
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
  final _Day day;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day.date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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

/// Detay sayfası: başta günün simgesi/resmi (10 Kasım matem + Atatürk, 15 Temmuz simgesi vb.), altında metin.
class OnemliGunDetayPage extends StatelessWidget {
  final _Day day;

  const OnemliGunDetayPage({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(day.date)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 220,
              child: _buildHero(context),
            ),
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

  Widget _buildHero(BuildContext context) {
    switch (day.gorsel) {
      case _GunGorsel.ataturkMatem:
        return _AtaturkMatemHero();
      case _GunGorsel.temmuz15:
        return _Temmuz15Hero();
      case _GunGorsel.cumhuriyet:
        return _CumhuriyetHero();
      case _GunGorsel.polisKurulus:
        return const _PolisKurulusHero();
      case _GunGorsel.genclik:
        return const _GenclikHero();
      case _GunGorsel.zafer:
        return const _ZaferHero();
      case _GunGorsel.egemenlik:
        return const _EgemenlikHero();
    }
  }
}

/// 10 Kasım: matem havasında Atatürk resmi (koyu overlay).
class _AtaturkMatemHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/atatürk.jpg',
          fit: BoxFit.cover,
        ),
        // Matem için koyu overlay
        Container(
          color: Colors.black.withOpacity(0.6),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '10 KASIM',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ATATÜRK\'Ü ANMA',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.access_time,
                color: Colors.white.withOpacity(0.8),
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                '09.05\'te 2 dakika saygı duruşu',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 15 Temmuz: Demokrasi ve Milli Birlik simgesi (kırmızı zemin, beyaz yıldız/ay veya metin).
class _Temmuz15Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC41E3A), // Kırmızı
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_rounded,
              size: 72,
              color: Colors.white.withOpacity(0.95),
            ),
            const SizedBox(height: 12),
            Text(
              '15 TEMMUZ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.98),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Demokrasi ve Milli Birlik Günü',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 29 Ekim: Cumhuriyet / bayrak renkleri.
class _CumhuriyetHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC41E3A),
            Color(0xFFE30A17),
            Color(0xFFC41E3A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.95),
            ),
            const SizedBox(height: 12),
            Text(
              '29 EKİM',
              style: TextStyle(
                color: Colors.white.withOpacity(0.98),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cumhuriyet Bayramı',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 10 Nisan: Polis teşkilatı (kalkan/şapka simgesi).
class _PolisKurulusHero extends StatelessWidget {
  const _PolisKurulusHero();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      color: color.withOpacity(0.15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 80,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              '10 NİSAN',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Polis Teşkilatı Kuruluş Günü',
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 19 Mayıs: Gençlik ve spor.
class _GenclikHero extends StatelessWidget {
  const _GenclikHero();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run_rounded,
              size: 72,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              '19 MAYIS',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gençlik ve Spor Bayramı',
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 30 Ağustos: Zafer.
class _ZaferHero extends StatelessWidget {
  const _ZaferHero();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech_rounded,
              size: 72,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              '30 AĞUSTOS',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Zafer Bayramı',
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 23 Nisan: Egemenlik ve çocuk.
class _EgemenlikHero extends StatelessWidget {
  const _EgemenlikHero();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Container(
      color: color.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 72,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              '23 NİSAN',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ulusal Egemenlik ve Çocuk Bayramı',
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
