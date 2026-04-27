import 'package:flutter/material.dart';

import 'police_surface_card.dart';

/// Tıklanabilir koyu yüzeyli kart (gradient, gölge, basma animasyonu).
class PrimaryCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final bool selected;

  const PrimaryCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return PoliceSurfaceCard(
      onTap: onTap,
      margin: margin,
      padding: const EdgeInsets.all(8),
      selected: selected,
      child: child,
    );
  }
}
