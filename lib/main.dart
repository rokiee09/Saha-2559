import 'package:flutter/foundation.dart' show kIsWeb;
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

  // Ürün hedefi mobil; web derlemesi kullanılmıyorsa Isar yine güvenli şekilde atlanır.
  // Isar başlatma; native kütüphane yüklenemese (ör. eski cihaz, beklenmedik ABI)
  // veya beklenenden uzun sürse bile uygulamayı açılış ekranında kilitlemeyiz.
  // Isar yalnızca şehit/iletişim verileri için kullanılır; başarısızlıkta bu sayfalar
  // kendi hata durumunu gösterir, geri kalan modüller (mevzuat/haklar/vardiya/kültür)
  // sorunsuz çalışır.
  if (!kIsWeb) {
    try {
      await IsarService.init().timeout(const Duration(seconds: 10));
      // İl emniyet listesi (81 il) — Teşkilat ekranı JSON/Isar için hazır olsun.
      await OfflineImportService.importCityContacts();
      await OfflineImportService.importMartyrs();
    } catch (error, stackTrace) {
      debugPrint('IsarService.init() başarısız; uygulama Isar olmadan açılıyor: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  runApp(const ProviderScope(child: PolisMevzuatApp()));
}
