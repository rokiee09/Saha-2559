import 'package:flutter/material.dart';

import '../../../common/theme/police_colors.dart';

/// Yatay kayar yazı (şehit isimleri devriyesi).
class SehitDevriyeKayarBant extends StatefulWidget {
  const SehitDevriyeKayarBant({
    super.key,
    required this.text,
    this.height = 40,
    this.speedPxPerSecond = 48,
  });

  final String text;
  final double height;
  final double speedPxPerSecond;

  @override
  State<SehitDevriyeKayarBant> createState() => _SehitDevriyeKayarBantState();
}

class _SehitDevriyeKayarBantState extends State<SehitDevriyeKayarBant>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _segmentWidth = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    _controller?.dispose();
    _controller = null;
    if (_segmentWidth <= 0 || !mounted) return;

    final durationMs =
        ((_segmentWidth / widget.speedPxPerSecond) * 1000).round().clamp(8000, 120000);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SehitDevriyeKayarBant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _segmentWidth = 0;
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: PoliceColors.titleOnDark.withValues(alpha: 0.95),
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: widget.height,
        color: Colors.black.withValues(alpha: 0.28),
        alignment: Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final painter = TextPainter(
              text: TextSpan(text: widget.text, style: style),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout();
            final w = painter.width + 48;
            if (_segmentWidth != w) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _segmentWidth = w;
                  _syncAnimation();
                });
              });
            }

            final ctrl = _controller;
            if (ctrl == null || _segmentWidth <= 0) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: style,
                  ),
                ),
              );
            }

            return AnimatedBuilder(
              animation: ctrl,
              builder: (context, child) {
                final offset = -ctrl.value * _segmentWidth;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Row(
                    children: [
                      _segment(style),
                      _segment(style),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _segment(TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        widget.text,
        maxLines: 1,
        softWrap: false,
        style: style,
      ),
    );
  }
}
