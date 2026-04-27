import 'package:flutter/material.dart';

import '../theme/police_colors.dart';

/// Pasif gri, aktif lacivert tonu + altın alt çizgi (altın sadece vurgu).
class PolisMainNavigationBar extends StatelessWidget {
  const PolisMainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.menu_book_outlined, label: 'Mevzuat'),
    (icon: Icons.apartment_outlined, label: 'Teşkilat'),
    (icon: Icons.description_outlined, label: 'Haklar'),
    (icon: Icons.auto_stories_outlined, label: 'Kültür'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.navBarBackground,
      child: SafeArea(
        top: false,
        child: Container(
          height: 62,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: PoliceColors.navTopDivider, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: List.generate(_items.length, (i) {
              final d = _items[i];
              final active = currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => onDestinationSelected(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        d.icon,
                        size: 24,
                        color: active
                            ? PoliceColors.gold
                            : PoliceColors.navInactive,
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
                          letterSpacing: 0.1,
                          color: active
                              ? PoliceColors.gold
                              : PoliceColors.navInactive,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        height: 3,
                        width: active ? 32 : 0,
                        decoration: BoxDecoration(
                          color: active ? PoliceColors.gold : Colors.transparent,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ],
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
