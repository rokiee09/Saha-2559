import 'package:flutter/material.dart';

import '../../common/theme/police_colors.dart';
import '../../common/widgets/police_surface_card.dart';
import '../home/root_drawer_scope.dart';
import '../kultur/rutbe_teskilat_page.dart';
import 'birimler_page.dart';
import '../contacts/contacts_page.dart';
import 'teskilat_yapisi_page.dart';

const _kCardMuted = PoliceColors.onDarkMuted;
const _kCardIcon = Color(0xFF94A3B8);

class TeskilatPage extends StatelessWidget {
  const TeskilatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Teşkilat',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PoliceSurfaceCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emniyet Teşkilatı',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: PoliceColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu bölümde Emniyet Genel Müdürlüğü yapısı, birimler, rütbeler ve il emniyet müdürlüklerinin iletişim bilgileri yer alır.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _kCardMuted,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
          _TeskilatCard(
            icon: Icons.account_balance_outlined,
            title: 'EGM Yapısı',
            subtitle:
                'Teşkilat şeması özet, başkanlıklar ve merkez/taşra (egm.gov.tr ile uyumlu)',
            isPrimary: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeskilatYapisiPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.apartment_outlined,
            title: 'Daire Başkanlıkları',
            subtitle:
                'EGM merkez teşkilatı daire başkanlıkları; harf ve arama ile listeleme',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BirimlerPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.groups_outlined,
            title: 'Rütbeler',
            subtitle: 'Emniyet teşkilatındaki rütbe sıralaması ve genel yapı',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RutbeTeskilatPage()),
              );
            },
          ),
          _TeskilatCard(
            icon: Icons.list_alt_outlined,
            title: 'İl Emniyet Müdürlükleri (Liste)',
            subtitle: 'Adres, telefon; detay ve arama',
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
  final bool isPrimary;

  const _TeskilatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isPrimary ? 32.0 : 28.0;
    final titleStyle = isPrimary
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            )
        : Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w600,
            );

    return PoliceSurfaceCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(isPrimary ? 18 : 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: _kCardIcon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _kCardMuted,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: _kCardIcon,
          ),
        ],
      ),
    );
  }
}
