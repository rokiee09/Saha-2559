import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/police_colors.dart';
import '../theme/saha_module_theme.dart';
import 'police_module_icon.dart';

/// Boş veya sonuç yok ekranları için ortak bileşen.
class SahaEmptyState extends StatelessWidget {
  const SahaEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = PhosphorIconsRegular.magnifyingGlass,
    this.theme,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final SahaModuleTheme? theme;
  final String? actionLabel;
  final VoidCallback? onAction;

  bool get _usesCustomIcon =>
      icon != PhosphorIconsRegular.magnifyingGlass;

  @override
  Widget build(BuildContext context) {
    final accent = theme?.accentColor ?? PoliceColors.primaryBlue;
    final showModuleBadge = theme != null && !_usesCustomIcon;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showModuleBadge)
              PoliceModuleIconBadge(
                style: theme!.style,
                size: 32,
                padding: 14,
                borderRadius: 16,
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                  ),
                ),
                child: icon.fontFamily == 'MaterialIcons'
                    ? Icon(icon, color: accent, size: 32)
                    : PhosphorIcon(icon, color: accent, size: 32),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.92),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: PoliceColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
