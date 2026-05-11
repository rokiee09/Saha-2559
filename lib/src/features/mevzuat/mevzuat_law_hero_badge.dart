import 'package:flutter/material.dart';

import '../../common/theme/police_colors.dart';

/// Mevzuat liste kartı ve detay üst çubuğunda aynı görsel — Hero uçuşu için.
class MevzuatLawHeroBadge extends StatelessWidget {
  const MevzuatLawHeroBadge({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(
          category == 'kanun'
              ? Icons.balance_rounded
              : Icons.rule_folder_rounded,
          size: 22,
          color: PoliceColors.primaryBlue.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}
