import 'package:flutter/material.dart';

import 'police_module_icon.dart';
import 'saha_module_card.dart';

/// Profilim / Araçlar / Kariyer listelerinde ortak renkli modül satırı.
class PoliceModuleListTile extends StatelessWidget {
  const PoliceModuleListTile({
    super.key,
    required this.style,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.footer,
  });

  final PoliceModuleStyle style;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return SahaModuleCard.row(
      style: style,
      title: title,
      subtitle: subtitle,
      footer: footer,
      onTap: onTap,
    );
  }
}
