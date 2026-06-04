import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/police_colors.dart';
import '../theme/saha_module_theme.dart';
import 'police_module_icon.dart';

/// Kart düzeni: liste, grid, ana sayfa özeti.
enum SahaModuleCardLayout {
  row,
  compact,
  feature,
}

/// Standart modül kartı — sol ikon, başlık, açıklama, sağ ok.
class SahaModuleCard extends StatefulWidget {
  const SahaModuleCard({
    super.key,
    required this.theme,
    required this.title,
    this.subtitle,
    this.footer,
    this.layout = SahaModuleCardLayout.row,
    this.onTap,
    this.showTrailing = true,
    this.pressScale = false,
    this.margin,
  });

  final SahaModuleTheme theme;
  final String title;
  final String? subtitle;
  final String? footer;
  final SahaModuleCardLayout layout;
  final VoidCallback? onTap;
  final bool showTrailing;
  final bool pressScale;
  final EdgeInsetsGeometry? margin;

  factory SahaModuleCard.row({
    required PoliceModuleStyle style,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? footer,
    EdgeInsetsGeometry? margin,
  }) {
    return SahaModuleCard(
      theme: SahaModuleTheme.fromStyle(style),
      title: title,
      subtitle: subtitle,
      footer: footer,
      layout: SahaModuleCardLayout.row,
      onTap: onTap,
      margin: margin ?? const EdgeInsets.only(bottom: 10),
    );
  }

  factory SahaModuleCard.compact({
    required PoliceModuleStyle style,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return SahaModuleCard(
      theme: SahaModuleTheme.fromStyle(style),
      title: title,
      subtitle: subtitle,
      layout: SahaModuleCardLayout.compact,
      onTap: onTap,
      showTrailing: false,
    );
  }

  factory SahaModuleCard.feature({
    required SahaModuleArea area,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SahaModuleCard(
      theme: SahaModuleTheme.forArea(area),
      title: title,
      subtitle: subtitle,
      layout: SahaModuleCardLayout.feature,
      onTap: onTap,
      showTrailing: false,
      pressScale: true,
    );
  }

  @override
  State<SahaModuleCard> createState() => _SahaModuleCardState();
}

class _SahaModuleCardState extends State<SahaModuleCard> {
  double _scale = 1;

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.layout) {
      SahaModuleCardLayout.row => _buildRow(),
      SahaModuleCardLayout.compact => _buildCompact(),
      SahaModuleCardLayout.feature => _buildFeature(),
    };

    if (!widget.pressScale) {
      return Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: child,
      );
    }

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _scale = 0.98) : null,
        onTapUp: widget.onTap != null ? (_) => setState(() => _scale = 1) : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _scale = 1) : null,
        onTap: widget.onTap != null ? _handleTap : null,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: child,
        ),
      ),
    );
  }

  Widget _shell({
    required Widget child,
    required EdgeInsets padding,
    required double radius,
    bool elevated = false,
  }) {
    final t = widget.theme;
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: widget.pressScale ? null : (widget.onTap != null ? _handleTap : null),
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: t.borderColor, width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                t.surfaceTint,
                PoliceColors.surfaceDark,
              ],
            ),
            boxShadow: elevated
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  Widget _buildRow() {
    return _shell(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          PoliceModuleIconBadge(style: widget.theme.style),
          const SizedBox(width: 14),
          Expanded(child: _textBlock(titleSize: 15.5, subtitleSize: 12.5)),
          if (widget.showTrailing)
            const PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              color: PoliceColors.textMuted,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return _shell(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PoliceModuleIconBadge(
            style: widget.theme.style,
            size: 22,
            padding: 7,
            borderRadius: 10,
          ),
          const SizedBox(height: 6),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.85),
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeature() {
    return _shell(
      radius: 18,
      padding: const EdgeInsets.all(18),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PoliceModuleIconBadge(
            style: widget.theme.style,
            size: 30,
            padding: 10,
            borderRadius: 14,
          ),
          const SizedBox(height: 14),
          _textBlock(titleSize: 16, subtitleSize: 12.5),
        ],
      ),
    );
  }

  Widget _textBlock({required double titleSize, required double subtitleSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: PoliceColors.titleOnDark,
            fontWeight: FontWeight.w800,
            fontSize: titleSize,
          ),
        ),
        if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.92),
              fontSize: subtitleSize,
              height: 1.35,
            ),
          ),
        ],
        if (widget.footer != null && widget.footer!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.footer!,
            style: TextStyle(
              color: widget.theme.accentColor.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
