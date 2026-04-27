import 'package:flutter/material.dart';

import '../../common/widgets/rutbe_level_icon.dart';

/// Rütbe sırası ve meslek dereceleri, [EGM Rütbeler](https://www.egm.gov.tr/rutbeler) sayfasındaki
/// tablo ile uyumludur; ayrıca 3201 sayılı Kanun m. 13 çerçevesindedir.
class RutbeTeskilatPage extends StatelessWidget {
  const RutbeTeskilatPage({super.key});

  static const _sourceKisa =
      'Emniyet Genel Müdürlüğü — Rütbeler (egm.gov.tr/rutbeler); 3201 s. K. m. 13.';

  static const _kaynakDialog =
      'Ayrıntılı görev unvanları ve tablo, aynı kanunun m. 13’teki düzenlemede yer alır.\n\n'
      'Resmî kaynak satırı aşağıdadır.';

  static final _ranks = <_RankItem>[
    const _RankItem(
      'Polis Memuru',
      '12. meslek derecesi',
      'Örnek görev unvanları: Büro Memuru, Ekip Memuru, Tim Memuru, Karakol Memuru, Nokta Memuru, Devriye Memuru, Koruma Memuru, Trafik Memuru, Telsiz Memuru, Memur.',
    ),
    const _RankItem(
      'Başpolis Memuru',
      '11. meslek derecesi',
      'Örnek görev unvanları: Ekip Amiri, Tim Amiri, Devriye Amiri, Grup Amiri, Grup Amir Yardımcısı, Ekip Amir Yardımcısı, Büro Amir Yardımcısı, Büro Memuru, Ekip Memuru.',
    ),
    const _RankItem(
      'Kıdemli Başpolis Memuru',
      '10. meslek derecesi',
      'Örnek görev unvanları: Ekip Amiri, Tim Amiri, Grup Amiri, Büro Amir Yardımcısı, Grup Amir Yardımcısı, Büro Memuru, Ekip Memuru.',
    ),
    const _RankItem(
      'Komiser Yardımcısı',
      '9. meslek derecesi',
      'Örnek görev unvanları: Grup Amiri, Ekip Amiri, Tim Amiri, Büro Amiri, Karakol Amir Yardımcısı, Sınıflar Amiri Yardımcısı, Sınıf Komiseri, Öğretim Görevlisi, Pilot.',
    ),
    const _RankItem(
      'Komiser',
      '8. meslek derecesi',
      'Örnek görev unvanları: Grup Amiri, Ekip Amiri, Tim Amiri, Büro Amiri, Karakol Amir Yardımcısı, Sınıflar Amiri Yardımcısı, Sınıf Komiseri, Trafik İstasyonu Amir Yardımcısı, Öğretim Görevlisi, Pilot.',
    ),
    const _RankItem(
      'Başkomiser',
      '7. meslek derecesi',
      'Örnek görev unvanları: Karakol Amiri, Büro Amiri, Çevik Kuvvet Grup Amiri, İlçe Emniyet Komiseri, Birlik Amiri, Tim Amiri, Trafik İstasyon Amiri, Trafik Kayıt ve Tescil Büro Amiri, Karakol Amir Yardımcısı, Sınıflar Amiri, Grup Amiri, Öğretim Görevlisi, Pilot.',
    ),
    const _RankItem(
      'Emniyet Amiri',
      '6. meslek derecesi',
      'Örnek görev unvanları: İlçe Emniyet Amiri, Bürolar Amiri, Birlik Amiri, Çevik Kuvvet Grup Amiri, Ekipler Amiri, Tim Amiri, İlçe Emniyet Müdür Yardımcısı, Büro Amiri, Trafik İstasyon Amiri, Sınıflar Amiri, Öğretim Görevlisi, Pilot.',
    ),
    const _RankItem(
      '4. Sınıf Emniyet Müdürü',
      '5. meslek derecesi',
      'Örnek görev unvanları: Şube Müdürü, İlçe Emniyet Müdür Yardımcısı, Hukuk Müşaviri, Şube Müdür Yardımcısı, Öğretim Görevlisi, Pilot, İlçe Emniyet Müdürü.',
    ),
    const _RankItem(
      '3. Sınıf Emniyet Müdürü',
      '4. meslek derecesi',
      'Örnek görev unvanları: Moral Eğitim Merkezi Müdür Yardımcısı, Hukuk Müşaviri, Şube Müdürü, İlçe Emniyet Müdürü, Öğretim Görevlisi, Pilot.',
    ),
    const _RankItem(
      '2. Sınıf Emniyet Müdürü',
      '3. meslek derecesi',
      'Örnek görev unvanları: Kriminal Polis Laboratuvarı Müdürü, Daire Başkan Yardımcısı, İl Emniyet Müdür Yardımcısı, Polis Müfettişi, Hukuk Müşaviri, İlçe Emniyet Müdürü, Polis Akademisi Bölüm Başkanı, Polis Amirleri Eğitimi Merkezi Müdür Yardımcısı, Polis Meslek Yüksek Okulu Müdür Yardımcısı, Polis Meslek Eğitim Merkezi Müdür Yardımcısı, Polis Eğitim Merkezi Müdür Yardımcısı, Enstitü Sekreteri, Öğretim Görevlisi, Uçuş Kıymetlendirme Kurulu Üyesi, Havacılık Müdürü, Pilot.',
    ),
    const _RankItem(
      '1. Sınıf Emniyet Müdürü',
      '1. ve 2. meslek derecesi (özet)',
      'EGM tablosuna göre bu rütbeye ilişkin örnek görev unvanları iki grupta toplanır: (1) Genel Müdür Yardımcısı, Teftiş Kurulu Başkanı, Özel Güvenlik Denetleme Başkanı, Polis Akademisi Başkanı, Merkez Emniyet Müdürü, Emniyet Müşaviri. (2) Daire Başkanı, Birinci Hukuk Müşaviri, İl Emniyet Müdürü, Polis Başmüfettişi, Öğretim Görevlisi, Merkez Emniyet Müdürü, Polis Moral Eğitim Merkezi Müdürü, Polis Akademisi Başkan Yardımcısı, Polis Amirleri Eğitimi Merkezi Müdürü, Teftiş Kurulu Başkan Yardımcısı, Teftiş Kurulu Grup Amiri, Emniyet Müşaviri, Polis Meslek Yüksek Okulu Müdürü, Polis Meslek Eğitim Merkezi Müdürü, Polis Eğitim Merkezi Müdürü, Uçuş Kıymetlendirme Kurulu Üyesi, Pilot.',
    ),
    const _RankItem(
      'Sınıf Üstü Emniyet Müdürü',
      'Sınıf üstü kademe',
      '1. sınıf emniyet müdürlüğü ile genel müdürlük arasındaki sınıf üstü sütununda yer alan rütbe (EGM, Rütbeler sayfası).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rütbeler')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Rütbeler (en alt → en üst)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _sourceKisa,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ..._ranks.asMap().entries.map(
            (e) {
              final i = e.key;
              final r = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: RutbeRankIcon(levelIndex: i),
                    title: Text(
                      r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(r.meslekDerece),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Row(
                            children: [
                              RutbeRankIcon(levelIndex: i, size: 36),
                              const SizedBox(width: 12),
                              Expanded(child: Text(r.title)),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              '${r.body}\n\n$_kaynakDialog\n\n$_sourceKisa',
                              style: Theme.of(ctx).textTheme.bodyMedium,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Kapat'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RankItem {
  const _RankItem(this.title, this.meslekDerece, this.body);

  final String title;
  final String meslekDerece;
  final String body;
}
