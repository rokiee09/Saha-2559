import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/theme/app_theme.dart';
import 'features/root_gate.dart';
import 'features/settings/theme_controller.dart';

class PolisMevzuatApp extends ConsumerWidget {
  const PolisMevzuatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAHA 2559',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: const RootGate(),
    );
  }
}

