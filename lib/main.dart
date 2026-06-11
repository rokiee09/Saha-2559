import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, debugPrintStack;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/common/theme/police_colors.dart';
import 'src/security/screenshot_guard.dart';
import 'src/data/db/isar_service.dart';
import 'src/data/repositories/offline_import_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenshotGuard.enable();

  ErrorWidget.builder = (details) => Material(
        color: PoliceColors.backgroundDark,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Görünüm oluşturulurken beklenmeyen bir sorun oluştu.\n'
                'Sayfayı geri alıp tekrar deneyin veya uygulamayı yeniden başlatın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.95),
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: PolisMevzuatApp()));

  // Isar + tohum veri: UI açıldıktan sonra arka planda; her açılışta tablo silinmez.
  if (!kIsWeb) {
    unawaited(_warmOfflineData());
  }
}

Future<void> _warmOfflineData() async {
  try {
    await IsarService.init().timeout(const Duration(seconds: 10));
    await OfflineImportService.seedIfNeeded();
  } catch (error, stackTrace) {
    debugPrint(
      'Isar/çevrimdışı veri hazırlığı atlandı; uygulama JSON ile devam eder: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}
