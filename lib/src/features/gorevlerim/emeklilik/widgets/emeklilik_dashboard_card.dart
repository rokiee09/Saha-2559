import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../common/routing/transitions.dart';
import '../../../../common/theme/police_colors.dart';
import '../../../../common/widgets/police_module_icon.dart';
import '../emeklilik_calculator.dart';
import '../emeklilik_provider.dart';
import '../emeklilik_takip_page.dart';

/// Ana sayfada emeklilik özeti.
class EmeklilikDashboardCard extends ConsumerWidget {
  const EmeklilikDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(emeklilikDurumProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            fadeRoute(const EmeklilikTakipPage()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.emeklilikAccent.withValues(alpha: 0.4),
              ),
            ),
            child: durum == null ? _eksikProfil(context) : _ozet(context, durum),
          ),
        ),
      ),
    );
  }

  Widget _eksikProfil(BuildContext context) {
    return Row(
      children: [
        PoliceModuleIconBadge(style: PoliceModules.emeklilik, size: 22, padding: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emeklilik takibi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Profilim’de rütbe, mesleğe giriş ve doğum tarihini girin.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PoliceColors.textMuted,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
        PhosphorIcon(
          PhosphorIconsRegular.caretRight,
          color: PoliceColors.textMuted.withValues(alpha: 0.85),
          size: 18,
        ),
      ],
    );
  }

  Widget _ozet(BuildContext context, EmeklilikDurum durum) {
    final z = durum.zorunluHizmet;
    final y = durum.yasHaddi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PoliceModuleIconBadge(style: PoliceModules.emeklilik, size: 22, padding: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emeklilik takibi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              size: 18,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _satir(
          'Zorunlu hizmet (20 yıl)',
          z.tamamlandi ? 'Tamamlandı' : z.kalan.kalanMetin(),
          formatYuzde(z.yuzde),
          PoliceColors.primaryBlue,
        ),
        const SizedBox(height: 6),
        _satir(
          'Yaş haddi (${durum.yasHaddiYas})',
          y.tamamlandi ? 'Tamamlandı' : y.kalan.kalanMetin(),
          formatYuzde(y.yuzde),
          PoliceColors.emeklilikAccent,
        ),
        const SizedBox(height: 8),
        Text(
          'Önce dolacak: ${formatTrTarih(durum.emeklilikTarihi)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PoliceColors.gold.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _satir(String baslik, String kalan, String yuzde, Color renk) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 36,
          margin: const EdgeInsets.only(right: 8, top: 2),
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baslik,
                style: TextStyle(
                  color: renk.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                kalan,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          yuzde,
          style: TextStyle(
            color: renk,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
