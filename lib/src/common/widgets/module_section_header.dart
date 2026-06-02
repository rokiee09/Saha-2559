import 'package:flutter/material.dart';

import '../theme/police_colors.dart';

/// Araçlar / Profilim gibi uzun listelerde bölüm başlığı.
class ModuleSectionHeader extends StatelessWidget {
  const ModuleSectionHeader(
    this.title, {
    super.key,
    this.subtitle,
    this.topGap = 0,
  });

  final String title;
  final String? subtitle;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topGap, bottom: 10),
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
    );
  }
}
