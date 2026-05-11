import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/common/theme/police_colors.dart';
import 'src/data/db/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Ürün hedefi mobil; web derlemesi kullanılmıyorsa Isar yine güvenli şekilde atlanır.
  if (!kIsWeb) {
    await IsarService.init();
  }

  runApp(const ProviderScope(child: PolisMevzuatApp()));
}
