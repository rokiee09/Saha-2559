import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../saha/saha_category_page.dart';
import 'tutanak_page.dart';
import 'tutanak_ses_page.dart';

/// Tutanak Merkezi: şablonlar, sesle yazım, kayıtlar.
class TutanakMerkeziPage extends StatelessWidget {
  const TutanakMerkeziPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Tutanak Merkezi'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _HubCard(
            icon: PhosphorIconsRegular.files,
            color: PoliceColors.primaryBlue,
            title: 'Hazır şablonlar',
            subtitle: '5 tutanak şablonu; doldur, kontrol et, PDF al.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const TutanakPage())),
          ),
          _HubCard(
            icon: PhosphorIconsRegular.microphone,
            color: const Color(0xFF38BDF8),
            title: 'Sesle tutanak',
            subtitle: 'Konuş; metin yazılsın, şablona aktar.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const TutanakSesPage())),
          ),
          _HubCard(
            icon: PhosphorIconsRegular.archive,
            color: PoliceColors.gold,
            title: 'Kaydedilen taslaklar',
            subtitle: 'Bu cihazda saklanan tutanak notları.',
            onTap: () => Navigator.of(context).push(
              fadeRoute(const SahaCategoryPage(categoryId: 'tutanak')),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Üretilen metinler bilgilendirme taslağıdır; resmî tutanak değildir. '
            'Kontrol edip birim formatına göre düzenleyin. Veri cihazdan çıkmaz.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  color: PoliceColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
