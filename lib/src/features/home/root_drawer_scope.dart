import 'package:flutter/material.dart';

/// [HomeShell] ana menüsünü (modal alt sayfa) açmak için.
class RootDrawerIntent extends InheritedWidget {
  const RootDrawerIntent({
    super.key,
    required this.openMainMenu,
    required super.child,
  });

  final VoidCallback openMainMenu;

  static RootDrawerIntent? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RootDrawerIntent>();
  }

  @override
  bool updateShouldNotify(RootDrawerIntent oldWidget) {
    return openMainMenu != oldWidget.openMainMenu;
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
      tooltip: 'Menü',
      onPressed: intent.openMainMenu,
    );
  }
}
