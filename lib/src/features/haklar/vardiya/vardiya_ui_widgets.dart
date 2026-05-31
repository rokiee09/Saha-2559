import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/theme/police_colors.dart';

/// Vardiya ekranları için ortak koyu tema yüzeyleri.
class VardiyaUi {
  VardiyaUi._();

  static const pageBackground = PoliceColors.backgroundDark;

  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? PoliceColors.outlineMuted.withValues(alpha: 0.55),
        ),
      );

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            color: PoliceColors.titleOnDark,
            fontWeight: FontWeight.w800,
          );

  static TextStyle bodyMuted(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            color: PoliceColors.textMuted,
            height: 1.42,
          );
}

class VardiyaSectionCard extends StatelessWidget {
  const VardiyaSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VardiyaUi.cardDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: VardiyaUi.sectionTitle(context)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: VardiyaUi.bodyMuted(context)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class VardiyaRadioOption extends StatelessWidget {
  const VardiyaRadioOption({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    required this.selected,
    required this.onTap,
    this.accentColor = PoliceColors.primaryBlue,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? accentColor.withValues(alpha: 0.12)
            : PoliceColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? accentColor.withValues(alpha: 0.75)
                    : PoliceColors.outlineMuted.withValues(alpha: 0.45),
                width: selected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? accentColor : PoliceColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 10),
                if (icon != null)
                  Icon(icon, color: accentColor.withValues(alpha: 0.9), size: 22)
                else if (emoji != null)
                  Text(emoji!, style: const TextStyle(fontSize: 20)),
                if (icon != null || emoji != null) const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: PoliceColors.textMuted,
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VardiyaChipChoice extends StatelessWidget {
  const VardiyaChipChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accentColor = PoliceColors.primaryBlue,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: selected
              ? accentColor.withValues(alpha: 0.22)
              : PoliceColors.surfaceDarkElevated,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? accentColor
                      : PoliceColors.outlineMuted.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) ...[
                    Icon(Icons.check_rounded, size: 16, color: accentColor),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VardiyaPrimaryButton extends StatelessWidget {
  const VardiyaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: PoliceColors.primaryBlue,
        disabledBackgroundColor:
            PoliceColors.outlineMuted.withValues(alpha: 0.35),
        foregroundColor: PoliceColors.titleOnDark,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4),
      ),
    );
  }
}

class VardiyaInfoBanner extends StatelessWidget {
  const VardiyaInfoBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PoliceColors.gold.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: PoliceColors.gold.withValues(alpha: 0.95),
          fontSize: 12.5,
          height: 1.42,
        ),
      ),
    );
  }
}
