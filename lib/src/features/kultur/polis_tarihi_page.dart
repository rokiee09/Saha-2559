import 'package:flutter/material.dart';

class PolisTarihiPage extends StatelessWidget {
  const PolisTarihiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polis Tarihi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Kuruluş (1845)',
              'Türk Polis Teşkilatı\'nın temelleri 1845 yılında atıldı. '
              'Osmanlı döneminde "Zaptiye Nezareti" ile başlayan yapı, Cumhuriyet\'in ilanından sonra '
              'Emniyet Umum Müdürlüğü adıyla yeniden teşkilatlandırıldı.',
            ),
            _buildSection(
              context,
              'Cumhuriyet Dönemi',
              '1923 sonrası polis teşkilatı modern bir yapıya kavuşturuldu. '
              'Kanunlar ve yönetmeliklerle görev ve yetkiler netleştirildi. '
              '1937\'de 3201 sayılı Emniyet Teşkilatı Kanunu ile teşkilat yasası düzenlendi.',
            ),
            _buildSection(
              context,
              'Önemli Reformlar',
              '• 2559 sayılı Polis Vazife ve Salahiyet Kanunu (1937) – Görev ve yetkilerin çerçevesi.\n'
              '• Polis Koleji ve Polis Akademisi – Eğitim yapısının kurulması.\n'
              '• Bölge ve il teşkilatlarının güçlendirilmesi.\n'
              '• Teknoloji ve istihbarat altyapısının geliştirilmesi.',
            ),
            _buildSection(
              context,
              'Terörle Mücadele',
              '1980\'lerden itibaren terörle mücadele polis teşkilatının öncelikli görev alanlarından biri oldu. '
              'Özel Harekat birimleri, istihbarat ve görev yerinde yürütülen operasyonlarla bu alan kurumsal bir deneyim kazandı. '
              'Şehitlerimiz bu süreçte vazife uğruna canlarını feda eden kahramanlardır.',
            ),
            _buildSection(
              context,
              'Teşkilat Evrimi',
              'Günümüzde Emniyet Genel Müdürlüğü; asayiş, trafik, terörle mücadele, narkotik, siber suçlar, '
              'istihbarat ve diğer daire başkanlıklarıyla çok yönlü bir yapıdadır. '
              'İl ve ilçe emniyet müdürlükleri, 81 ilde vatandaşın huzur ve güvenliğini sağlamakla görevlidir.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
