import 'package:flutter/material.dart';

import '../theme/police_colors.dart';

/// Koyu lacivert yüzey (#0F172A → #0A1F44), ince ışık sınırı, gölge; basılı iken ölçek 0.98.
class PoliceSurfaceCard extends StatefulWidget {
  const PoliceSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    this.padding = const EdgeInsets.all(16),
    this.selected = false,
    this.borderRadius = 16,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final double borderRadius;

  static const Color cTop = Color(0xFF0F172A);
  static const Color cBot = Color(0xFF0A1F44);
  static final Color borderSubtle = const Color.fromRGBO(255, 255, 255, 0.05);

  @override
  State<PoliceSurfaceCard> createState() => _PoliceSurfaceCardState();
}

class _PoliceSurfaceCardState extends State<PoliceSurfaceCard> {
  bool _pressed = false;

  Color _lerpTowardWhite(Color a, double t) =>
      Color.lerp(a, const Color(0xFFFFFFFF), t) ?? a;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final br = widget.borderRadius;
    final g0 = _lerpTowardWhite(PoliceSurfaceCard.cTop, _pressed ? 0.045 : 0);
    final g1 = _lerpTowardWhite(PoliceSurfaceCard.cBot, _pressed ? 0.06 : 0);

    final left = widget.selected
        ? const BorderSide(color: PoliceColors.gold, width: 3)
        : BorderSide(color: PoliceSurfaceCard.borderSubtle, width: 1);
    final side = BorderSide(
      color: PoliceSurfaceCard.borderSubtle,
      width: 1,
    );

    final surface = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(br),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [g0, g1],
        ),
        border: Border(
          left: left,
          top: side,
          right: side,
          bottom: side,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: interactive
            ? InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(br),
                splashColor: Colors.white.withValues(alpha: 0.08),
                highlightColor: Colors.white.withValues(alpha: 0.04),
                child: Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              )
            : Padding(
                padding: widget.padding,
                child: widget.child,
              ),
      ),
    );

    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
        child: Listener(
          behavior: HitTestBehavior.deferToChild,
          onPointerDown: interactive
              ? (_) => setState(() => _pressed = true)
              : null,
          onPointerUp: interactive
              ? (_) => setState(() => _pressed = false)
              : null,
          onPointerCancel: interactive
              ? (_) => setState(() => _pressed = false)
              : null,
          child: AnimatedScale(
            scale: interactive && _pressed ? 0.98 : 1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: surface,
          ),
        ),
      ),
    );
  }
}
