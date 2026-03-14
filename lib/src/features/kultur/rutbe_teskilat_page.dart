import 'package:flutter/material.dart';

class RutbeTeskilatPage extends StatelessWidget {
  const RutbeTeskilatPage({super.key});

  /// EGM resmî rütbe sırası (alttan üste): Meslek derecesi 12 (en alt) → Derece üstü (en üst).
  static final _ranks = [
    _RankItem('Polis Memuru', 'En alt rütbe (derece 12). Büro, ekip, tim, karakol, nokta, devriye, koruma, trafik memuru.', 1),
    _RankItem('Başpolis Memuru', 'Derece 11. Ekip/tim amiri, devriye amiri, grup amiri, büro amir yardımcısı.', 2),
    _RankItem('Kıdemli Başpolis Memuru', 'Derece 10. Ekip/tim/grup amiri, büro amir yardımcısı.', 3),
    _RankItem('Komiser Yardımcısı', 'Derece 9. Grup/ekip/tim amiri, büro amiri, karakol amir yardımcısı, sınıf komiseri.', 4),
    _RankItem('Komiser', 'Derece 8. Grup/ekip/tim amiri, büro amiri, karakol amir yardımcısı.', 5),
    _RankItem('Başkomiser', 'Derece 7. Karakol amiri, büro amiri, çevik kuvvet grup amiri, ilçe emniyet komiseri.', 6),
    _RankItem('Emniyet Amiri', 'Derece 6. İlçe emniyet amiri, büro/birlik amiri, çevik kuvvet grup amiri, tim amiri.', 7),
    _RankItem('4. Sınıf Emniyet Müdürü', 'Derece 5. Şube müdürü, ilçe emniyet müdürü/müdür yardımcısı.', 8),
    _RankItem('3. Sınıf Emniyet Müdürü', 'Derece 4. Şube müdürü, ilçe emniyet müdürü.', 9),
    _RankItem('2. Sınıf Emniyet Müdürü', 'Derece 3. Daire başkan yardımcısı, il emniyet müdür yardımcısı, ilçe emniyet müdürü.', 10),
    _RankItem('1. Sınıf Emniyet Müdürü', 'Derece 1–2. Daire başkanı, il emniyet müdürü, genel müdür yardımcısı, teftiş kurulu başkanı.', 11),
    _RankItem('Emniyet Genel Müdürü', 'Derece üstü. Teşkilatın en üst amiri.', 12),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rütbe ve Teşkilat Yapısı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Polis teşkilatında rütbeler, görev ve sorumluluk hiyerarşisini belirler. '
              'Rütbe ilerlemesi kıdem, eğitim ve sınav esasına göre düzenlenir.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Rütbeler (alttan üste, EGM resmî sıra)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._ranks.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        '${r.order}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(r.description),
                  ),
                )),
            const SizedBox(height: 16),
            Text(
              'Teşkilat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Emniyet Genel Müdürlüğü; merkezde daire başkanlıkları, taşrada il emniyet müdürlükleri ve ilçe emniyet müdürlükleri/amirlikleri ile örgütlenir. '
              'Asayiş, trafik, terörle mücadele (TEM), narkotik suçlarla mücadele, kriminal, istihbarat, özel harekat, KOM, teftiş kurulu ve eğitim birimleri merkez ve il/ilçe düzeyinde görev yapar.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RankItem {
  final String title;
  final String description;
  final int order;
  _RankItem(this.title, this.description, this.order);
}
