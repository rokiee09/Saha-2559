import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../../common/widgets/police_module_icon.dart';
import '../saglik_sosyal_haklar_page.dart';

/// Ana sayfa — Sağlık ve Sosyal Haklar kısayolu.
class SaglikDashboardCard extends StatelessWidget {
  const SaglikDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            fadeRoute(const SaglikSosyalHaklarPage()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.saglikAccent.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                PoliceModuleIconBadge(
                  style: PoliceModules.saglik,
                  size: 22,
                  padding: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sağlık ve Sosyal Haklar',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: PoliceColors.titleOnDark,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rapor, heyet, elverişlilik, maluliyet — mevzuat rehberi',
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
            ),
          ),
        ),
      ),
    );
  }
}
