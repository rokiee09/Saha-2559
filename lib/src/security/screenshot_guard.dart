import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Android ekran görüntüsü / son ekran önizlemesini engeller (FLAG_SECURE).
class ScreenshotGuard {
  ScreenshotGuard._();

  static const _channel = MethodChannel('com.coderipple.saha2559/security');

  static bool get supported => !kIsWeb && Platform.isAndroid;

  static Future<void> enable() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('enableSecureFlag');
    } catch (_) {
      // Kanal yoksa sessiz geç.
    }
  }

  static Future<void> disable() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('disableSecureFlag');
    } catch (_) {}
  }
}
