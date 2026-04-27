import 'package:flutter/material.dart';

/// [HomeShell] çekmecesini açmak için; sekme kök sayfalarının AppBar'ından erişilir.
class RootDrawerIntent extends InheritedWidget {
  const RootDrawerIntent({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  static RootDrawerIntent? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RootDrawerIntent>();
  }

  @override
  bool updateShouldNotify(RootDrawerIntent oldWidget) {
    return openDrawer != oldWidget.openDrawer;
  }
}

class HomeDrawerButton extends StatelessWidget {
  const HomeDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final intent = RootDrawerIntent.maybeOf(context);
    if (intent == null) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      tooltip: 'Bölümler ve ayarlar',
      onPressed: intent.openDrawer,
    );
  }
}
