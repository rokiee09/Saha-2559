import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/app_branding.dart';
import '../theme/police_colors.dart';

/// Pasif gri, aktif birincil mavi + ince alt çizgi.
class PolisMainNavigationBar extends StatelessWidget {
  const PolisMainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static final List<({IconData icon, String label})> _items = [
    (icon: PhosphorIconsRegular.squaresFour, label: kNavHomeLabel),
    (icon: PhosphorIconsRegular.books, label: 'Mevzuat'),
    (icon: PhosphorIconsRegular.buildings, label: 'Teşkilat'),
    (icon: PhosphorIconsRegular.scales, label: 'Haklar'),
    (icon: PhosphorIconsRegular.palette, label: 'Kültür'),
  ];

  @override
  Widget build(BuildContext context) {
    final shadowAlpha =
        Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.14;

    return Material(
      color: PoliceColors.navBarBackground,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: shadowAlpha),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: PoliceColors.navTopDivider, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: List.generate(_items.length, (i) {
              final d = _items[i];
              final active = currentIndex == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onDestinationSelected(i),
                    borderRadius: BorderRadius.circular(12),
                    splashColor:
                        PoliceColors.primaryBlue.withValues(alpha: 0.14),
                    highlightColor:
                        PoliceColors.primaryBlue.withValues(alpha: 0.08),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: active ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: PhosphorIcon(
                              d.icon,
                              size: 24,
                              color: active
                                  ? PoliceColors.navActive
                                  : PoliceColors.navInactive,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                              letterSpacing: 0.08,
                              color: active
                                  ? PoliceColors.navActive
                                  : PoliceColors.navInactive,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            height: 2,
                            width: active ? 28 : 0,
                            decoration: BoxDecoration(
                              color: active
                                  ? PoliceColors.accentMix(0.55)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
