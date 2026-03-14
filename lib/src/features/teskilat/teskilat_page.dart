import 'package:flutter/material.dart';

import '../contacts/contacts_page.dart';
import '../martyrs/martyrs_page.dart';
import '../saha/trafik_ceza_page.dart';
import '../settings/settings_page.dart';

class TeskilatPage extends StatelessWidget {
  const TeskilatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teşkilat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teşkilat Yapısı ve İletişim',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trafik ceza hesaplayıcı, il emniyet müdürlükleri, şehitlerimiz ve uygulama ayarlarına buradan ulaşabilirsiniz. '
                    '81 il iletişim bilgileri ve saygı listesi güncel tutulmaktadır.',
                  ),
                ],
              ),
            ),
          ),
          _TeskilatCard(
            icon: Icons.traffic,
            title: 'Trafik Ceza Hesaplayıcı',
            subtitle: 'Ceza maddesi seç → Para cezası, puan ve araç bağlama bilgisi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrafikCezaPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.map,
            title: 'İl İletişim',
            subtitle: '81 il listesi, tek dokunuşla ara ve kaynak gör',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactsPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.shield,
            title: 'Şehitler',
            subtitle:
                'İl filtresi ve isim arama ile saygı odaklı şehitler listesi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MartyrsPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.settings,
            title: 'Ayarlar',
            subtitle:
                'Gizlilik, disclaimer, offline paket ve tema ayarlarını yönet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeskilatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TeskilatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
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

