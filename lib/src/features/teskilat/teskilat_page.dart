import 'package:flutter/material.dart';

import '../kultur/rutbe_teskilat_page.dart';
import 'birimler_page.dart';
import '../contacts/contacts_page.dart';
import 'teskilat_yapisi_page.dart';

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
                    'Emniyet Teşkilatı',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu bölümde Emniyet Genel Müdürlüğü yapısı, birimler, rütbeler ve il emniyet müdürlüklerinin iletişim bilgileri yer alır.',
                  ),
                ],
              ),
            ),
          ),
          _TeskilatCard(
            icon: Icons.account_balance,
            title: 'EGM Yapısı',
            subtitle: 'Merkez, taşra ve eğitim teşkilatı hakkında genel bilgi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeskilatYapisiPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.apartment,
            title: 'Birimler',
            subtitle: 'Temel hizmet birimleri ve kurumsal görev alanları',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BirimlerPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.badge,
            title: 'Rütbeler',
            subtitle: 'Emniyet teşkilatındaki rütbe sıralaması ve genel yapı',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RutbeTeskilatPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.map,
            title: 'İl Emniyet Müdürlükleri',
            subtitle: '81 il için iletişim bilgileri ve resmî kaynak bağlantıları',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactsPage()),
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

