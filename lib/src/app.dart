import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/constants/app_branding.dart';
import 'common/theme/app_theme.dart';
import 'features/root_gate.dart';
import 'features/settings/reading_scale_controller.dart';
import 'features/settings/theme_controller.dart';

class PolisMevzuatApp extends ConsumerWidget {
  const PolisMevzuatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final readingScale = ref.watch(readingScaleProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kAppDisplayName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        const refFontSize = 14.0;
        final systemFactor = mq.textScaler.scale(refFontSize) / refFontSize;
        final combined = systemFactor * readingScale;
        final scaled = TextScaler.linear(combined).clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.48,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: scaled),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RootGate(),
    );
  }
}

