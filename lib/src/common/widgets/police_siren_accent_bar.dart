import 'package:flutter/material.dart';

/// SAHA başlığı altı — kırmızı / mavi polis lambası yanıp sönme çizgisi.
class PoliceSirenAccentBar extends StatefulWidget {
  const PoliceSirenAccentBar({
    super.key,
    this.width = 52,
    this.height = 4,
  });

  final double width;
  final double height;

  static const _sirenRed = Color(0xFFDC2626);
  static const _sirenBlue = Color(0xFF2563EB);

  @override
  State<PoliceSirenAccentBar> createState() => _PoliceSirenAccentBarState();
}

class _PoliceSirenAccentBarState extends State<PoliceSirenAccentBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lampPower(double t, {required bool isRed}) {
    final redPhase = t < 0.5;
    final active = isRed ? redPhase : !redPhase;
    return active ? 1.0 : 0.22;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final redPower = _lampPower(t, isRed: true);
        final bluePower = _lampPower(t, isRed: false);
        final radius = BorderRadius.circular(widget.height / 2);

        return SizedBox(
          width: widget.width,
          height: widget.height + 6,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: widget.width * 0.5,
                child: IgnorePointer(
                  child: Container(
                    height: widget.height + 4,
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: PoliceSirenAccentBar._sirenRed
                              .withValues(alpha: 0.55 * redPower),
                          blurRadius: 8 * redPower,
                          spreadRadius: 0.5 * redPower,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: widget.width * 0.5,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: widget.height + 4,
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: PoliceSirenAccentBar._sirenBlue
                              .withValues(alpha: 0.55 * bluePower),
                          blurRadius: 8 * bluePower,
                          spreadRadius: 0.5 * bluePower,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: radius,
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: Row(
                    children: [
                      Expanded(
                        child: ColoredBox(
                          color: PoliceSirenAccentBar._sirenRed
                              .withValues(alpha: 0.35 + 0.65 * redPower),
                        ),
                      ),
                      Expanded(
                        child: ColoredBox(
                          color: PoliceSirenAccentBar._sirenBlue
                              .withValues(alpha: 0.35 + 0.65 * bluePower),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
