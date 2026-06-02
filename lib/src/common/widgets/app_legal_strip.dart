import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../constants/app_disclaimer.dart';
import '../routing/transitions.dart';
import '../theme/police_colors.dart';
import '../../features/settings/settings_page.dart';

/// Alt navigasyon üstünde ince yasal özet; tam metin Ayarlar’da.
class AppLegalStrip extends StatelessWidget {
  const AppLegalStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: InkWell(
          onTap: () => Navigator.of(context).push(fadeRoute(const SettingsPage())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                PhosphorIcon(
                  PhosphorIconsRegular.info,
                  size: 14,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    kAppShortDisclaimer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          height: 1.2,
                          fontSize: 10.5,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.92),
                        ),
                  ),
                ),
                PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  size: 14,
                  color: PoliceColors.textMuted.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
