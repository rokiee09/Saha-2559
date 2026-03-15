import 'package:flutter/material.dart';

import '../../common/routing/transitions.dart';
import '../../common/widgets/primary_card.dart';
import '../martyrs/martyrs_page.dart';
import 'onemli_gunler_page.dart';
import 'polis_andi_page.dart';
import 'polis_tarihi_page.dart';

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
              'Polis tarihine ve meslek kültürüne ilişkin temel içerikler.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          _cultureCard(
            context,
            title: 'Polis Tarihi',
            subtitle: 'Kuruluş süreci, Cumhuriyet dönemi ve kurumsal gelişim',
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
