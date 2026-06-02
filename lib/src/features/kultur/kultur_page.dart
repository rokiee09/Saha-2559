import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/police_module_icon.dart';
import '../home/root_drawer_scope.dart';
import '../../common/widgets/primary_card.dart';
import '../martyrs/martyrs_page.dart';
import 'ataturk_ve_turk_polisi_page.dart';
import 'onemli_gunler_page.dart';
import 'polis_andi_page.dart';
import 'polis_tarihi_page.dart';
import 'tesekkur_vefa_page.dart';

class KulturPage extends StatelessWidget {
  const KulturPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Kültür',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
            style: PoliceModules.gazilik,
            title: 'Atatürk ve Türk Polisi',
            subtitle:
                'Gazi’den anlatım, Polis Koleji ve Enstitü emri; EGM resmî metin',
            isPrimary: true,
            onTap: () => Navigator.of(context).push(
              fadeRoute(const AtaturkVeTurkPolisiPage()),
            ),
          ),
          _cultureCard(
            context,
            style: PoliceModules.kultur,
            title: 'Polis Tarihi',
            subtitle: 'Kuruluş süreci, Cumhuriyet dönemi ve kurumsal gelişim',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const PolisTarihiPage())),
          ),
          _cultureCard(
            context,
            style: PoliceModules.sehitler,
            title: 'Şehitlerimiz',
            subtitle: 'Ad, il, tarih (anı metni yok; resmî kaynaklara bakınız)',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MartyrsPage()),
            ),
          ),
          _cultureCard(
            context,
            style: PoliceModules.kultur,
            title: 'Polis Andı',
            subtitle: 'Göreve başlarken edilen yemin metni',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const PolisAndiPage())),
          ),
          _cultureCard(
            context,
            style: PoliceModules.onemliGunler,
            title: 'Önemli Günler',
            subtitle: '10 Nisan Polis Günü, 15 Temmuz ve diğer tarihler',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const OnemliGunlerPage())),
          ),
          _cultureCard(
            context,
            style: PoliceModules.tesekkurVefa,
            title: 'Şükran ve Vefa',
            subtitle: 'Şehitlerimiz, kahramanlarımız ve görevdekilere',
            onTap: () => Navigator.of(context).push(
              fadeRoute(const TesekkurVefaPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cultureCard(
    BuildContext context, {
    required PoliceModuleStyle style,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final titleStyle = isPrimary
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.15,
            )
        : Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w600,
            );
    final pad = isPrimary ? 14.0 : 12.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PrimaryCard(
        onTap: onTap,
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isPrimary ? 8 : 6,
        ),
        child: Row(
          children: [
            PoliceModuleIconBadge(
              style: style,
              size: isPrimary ? 30 : 26,
              padding: pad,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PoliceColors.onDarkMuted,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
            PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
