import 'package:flutter/material.dart';

/// SAHA başlığı altı — kırmızı / mavi polis lambası yanıp sönme çizgisi.
class PoliceSirenAccentBar extends StatefulWidget {
  const PoliceSirenAccentBar({
    super.key,
    this.width = 76,
    this.height = 5,
  });

  final double width;
  final double height;

  static const _sirenRed = Color(0xFFFF3B3B);
  static const _sirenBlue = Color(0xFF3B8CFF);

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
    return active ? 1.0 : 0.42;
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

        final glowH = widget.height + 10;

        return SizedBox(
          width: widget.width,
          height: glowH + 4,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: widget.width * 0.5 + 2,
                child: IgnorePointer(
                  child: Container(
                    height: glowH,
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: PoliceSirenAccentBar._sirenRed
                              .withValues(alpha: 0.92 * redPower),
                          blurRadius: 14 + 6 * redPower,
                          spreadRadius: 1.2 * redPower,
                        ),
                        BoxShadow(
                          color: PoliceSirenAccentBar._sirenRed
                              .withValues(alpha: 0.45 * redPower),
                          blurRadius: 22 * redPower,
                          spreadRadius: 2 * redPower,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: widget.width * 0.5 - 2,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: glowH,
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: PoliceSirenAccentBar._sirenBlue
                              .withValues(alpha: 0.92 * bluePower),
                          blurRadius: 14 + 6 * bluePower,
                          spreadRadius: 1.2 * bluePower,
                        ),
                        BoxShadow(
                          color: PoliceSirenAccentBar._sirenBlue
                              .withValues(alpha: 0.45 * bluePower),
                          blurRadius: 22 * bluePower,
                          spreadRadius: 2 * bluePower,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: radius,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ColoredBox(
                          color: PoliceSirenAccentBar._sirenRed
                              .withValues(alpha: 0.55 + 0.45 * redPower),
                        ),
                      ),
                      Expanded(
                        child: ColoredBox(
                          color: PoliceSirenAccentBar._sirenBlue
                              .withValues(alpha: 0.55 + 0.45 * bluePower),
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
