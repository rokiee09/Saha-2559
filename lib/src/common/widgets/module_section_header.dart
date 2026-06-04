import 'package:flutter/material.dart';

import '../theme/police_colors.dart';
import '../theme/saha_module_theme.dart';

/// Araçlar / Profilim gibi uzun listelerde bölüm başlığı.
class ModuleSectionHeader extends StatelessWidget {
  const ModuleSectionHeader(
    this.title, {
    super.key,
    this.subtitle,
    this.topGap = 0,
    this.area,
    this.accentColor,
  });

  final String title;
  final String? subtitle;
  final double topGap;
  final SahaModuleArea? area;
  final Color? accentColor;

  Color? get _stripeColor =>
      accentColor ?? (area != null ? SahaModuleTheme.forArea(area!).accentColor : null);

  @override
  Widget build(BuildContext context) {
    final stripe = _stripeColor;

    return Padding(
      padding: EdgeInsets.only(top: topGap, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stripe != null)
            Container(
              width: 3,
              height: subtitle != null ? 40 : 22,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration: BoxDecoration(
                color: stripe.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.88),
                      fontSize: 12.5,
                      height: 1.32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
