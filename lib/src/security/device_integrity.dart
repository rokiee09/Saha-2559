import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Root, hata ayıklama ve emülatör için yerel uyarı (engelleme değil).
class DeviceIntegrityReport {
  const DeviceIntegrityReport({
    required this.isRootedOrJailbroken,
    required this.isEmulator,
    required this.isDebugBuild,
    required this.developerModeEnabled,
  });

  final bool isRootedOrJailbroken;
  final bool isEmulator;
  final bool isDebugBuild;
  final bool developerModeEnabled;

  bool get hasWarning =>
      isRootedOrJailbroken ||
      isEmulator ||
      isDebugBuild ||
      developerModeEnabled;

  List<String> get messages {
    final out = <String>[];
    if (isRootedOrJailbroken) {
      out.add('Cihaz root/jailbreak izleri taşıyor olabilir.');
    }
    if (isEmulator) {
      out.add('Emülatör veya sanal cihaz algılandı.');
    }
    if (isDebugBuild) {
      out.add('Hata ayıklama (debug) derlemesi çalışıyor.');
    }
    if (developerModeEnabled) {
      out.add('Geliştirici seçenekleri açık görünüyor (ADB / test cihazı).');
    }
    return out;
  }
}

class DeviceIntegrityService {
  DeviceIntegrityService._();

  static Future<DeviceIntegrityReport> scan() async {
    var rooted = false;
    var emulator = false;
    var devMode = kDebugMode;

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final info = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final android = await info.androidInfo;
          emulator = !android.isPhysicalDevice;
          final fp = android.fingerprint.toLowerCase();
          final model = android.model.toLowerCase();
          final product = android.product.toLowerCase();
          if (fp.contains('generic') ||
              fp.contains('emulator') ||
              model.contains('sdk') ||
              product.contains('sdk') ||
              product.contains('emulator')) {
            emulator = true;
          }
          // Yaygın root / test imleri (heuristic, kesin değil).
          final tags = android.tags.toLowerCase();
          if (tags.contains('test-keys') ||
              fp.contains('userdebug') ||
              android.brand.toLowerCase() == 'generic') {
            rooted = true;
          }
          devMode = devMode || android.isPhysicalDevice == false;
        } else if (Platform.isIOS) {
          final ios = await info.iosInfo;
          emulator = !ios.isPhysicalDevice;
        }
      } catch (_) {}
    }

    return DeviceIntegrityReport(
      isRootedOrJailbroken: rooted,
      isEmulator: emulator,
      isDebugBuild: kDebugMode,
      developerModeEnabled: devMode,
    );
  }
}
