import 'package:flutter/material.dart';

class TeskilatYapisiPage extends StatelessWidget {
  const TeskilatYapisiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EGM Yapısı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emniyet Genel Müdürlüğü, İçişleri Bakanlığına bağlı genel müdürlük düzeyinde bir kamu kurumudur. '
              'Merkez, taşra ve eğitim birimleriyle teşkilatlanır.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Merkez Teşkilatı',
              body:
                  'Merkez teşkilatında genel müdür, genel müdür yardımcıları, başkanlıklar, daire başkanlıkları ve yardımcı hizmet birimleri bulunur. '
                  'Politika, koordinasyon, personel, eğitim, denetim ve kurumsal yönetim işleri bu yapıda yürütülür.',
            ),
            _SectionCard(
              title: 'Taşra Teşkilatı',
              body:
                  'Taşra teşkilatı; il emniyet müdürlükleri, ilçe emniyet müdürlükleri ve bağlı birimlerden oluşur. '
                  'İllerdeki yapı, hizmet ihtiyacı ve teşkilat büyüklüğüne göre farklılık gösterebilir.',
            ),
            _SectionCard(
              title: 'Eğitim Yapısı',
              body:
                  'Polis Akademisi Başkanlığı, polis meslek eğitim merkezleri ve diğer eğitim birimleri mesleğe hazırlık, hizmet içi eğitim ve kariyer gelişimi süreçlerini destekler.',
            ),
            _SectionCard(
              title: 'Dayanak',
              body:
                  'Teşkilat yapısının temel dayanakları arasında 3201 sayılı Emniyet Teşkilatı Kanunu, 2559 sayılı Polis Vazife ve Salahiyet Kanunu ve ilgili yönetmelikler yer alır.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String body;

  const _SectionCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
