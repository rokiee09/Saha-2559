import 'package:flutter/material.dart';

/// Atatürk portresi: yükseklik, gölge ve hizalama ile listede daha seçilebilir görünüm.
class AtaturkPortraitHero extends StatelessWidget {
  const AtaturkPortraitHero({
    super.key,
    required this.assetPath,
    this.height = 300,
    this.alignment = const Alignment(0, -0.15),
    this.borderRadius,
    this.horizontalInset = 0,
  });

  final String assetPath;
  final double height;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final double horizontalInset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final br = borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Material(
        elevation: 5,
        shadowColor: Colors.black45,
        color: cs.surfaceContainerHighest,
        borderRadius: br,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Image.asset(
            assetPath,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: alignment,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: cs.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.person_outline,
                  size: 72,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
