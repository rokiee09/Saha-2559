import 'package:flutter/material.dart';

import '../../common/routing/transitions.dart';
import '../../common/widgets/primary_card.dart';
import '../martyrs/martyrs_page.dart';
import 'ataturk_page.dart';
import 'mesleki_etik_page.dart';
import 'onemli_gunler_page.dart';
import 'polis_andi_page.dart';
import 'kariyer_rehberi_page.dart';
import 'polis_tarihi_page.dart';
import 'rutbe_teskilat_page.dart';

class KulturPage extends StatelessWidget {
  const KulturPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kültür')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Text(
              'Polis tarihi, teşkilat, değerler ve önemli günler.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          _cultureCard(
            context,
            title: 'Atatürk Köşesi',
            subtitle: 'Atatürk\'ün polislikle ilgili sözleri ve hatırası',
            icon: Icons.flag,
            color: Colors.red,
            onTap: () => Navigator.of(context).push(fadeRoute(const AtaturkPage())),
          ),
          _cultureCard(
            context,
            title: 'Polis Tarihi',
            subtitle: '1845 kuruluş, reformlar, terörle mücadele, teşkilat evrimi',
            icon: Icons.history_edu,
            color: Colors.indigo,
            onTap: () => Navigator.of(context).push(fadeRoute(const PolisTarihiPage())),
          ),
          _cultureCard(
            context,
            title: 'Şehitlerimiz',
            subtitle: 'İl bazlı liste, saygıyla anıyoruz',
            icon: Icons.shield,
            color: Colors.brown,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MartyrsPage()),
            ),
          ),
          _cultureCard(
            context,
            title: 'Rütbe ve Teşkilat Yapısı',
            subtitle: 'Polis memurundan Emniyet Genel Müdürüne, teşkilat hiyerarşisi',
            icon: Icons.badge,
            color: Colors.blue,
            onTap: () => Navigator.of(context).push(fadeRoute(const RutbeTeskilatPage())),
          ),
          _cultureCard(
            context,
            title: 'Rütbe & Kariyer Rehberi',
            subtitle: 'Terfi şartları, sınav sistemi, branş birimleri – aday polisler için',
            icon: Icons.trending_up,
            color: Colors.deepPurple,
            onTap: () => Navigator.of(context).push(fadeRoute(const KariyerRehberiPage())),
          ),
          _cultureCard(
            context,
            title: 'Mesleki Etik & Değerler',
            subtitle: 'Vatanseverlik, dürüstlük, adalet, cesaret, etik, takım ruhu',
            icon: Icons.handshake,
            color: Colors.purple,
            onTap: () => Navigator.of(context).push(fadeRoute(const MeslekiEtikPage())),
          ),
          _cultureCard(
            context,
            title: 'Polis Andı',
            subtitle: 'Göreve başlarken edilen yemin metni',
            icon: Icons.menu_book,
            color: Colors.teal,
            onTap: () => Navigator.of(context).push(fadeRoute(const PolisAndiPage())),
          ),
          _cultureCard(
            context,
            title: 'Önemli Günler',
            subtitle: '10 Nisan Polis Günü, 15 Temmuz ve diğer tarihler',
            icon: Icons.calendar_today,
            color: Colors.orange,
            onTap: () => Navigator.of(context).push(fadeRoute(const OnemliGunlerPage())),
          ),
        ],
      ),
    );
  }

  Widget _cultureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PrimaryCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
