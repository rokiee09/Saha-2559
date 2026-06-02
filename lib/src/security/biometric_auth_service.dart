import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

import 'secure_vault_storage.dart';
import 'vault_session.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// PIN ile açıldıktan sonra biyometrik kısayol için DEK kopyası saklanır.
  static Future<void> enableAfterPinUnlock() async {
    if (!VaultSession.isUnlocked) return;
    await SecureVaultStorage.writeBiometricDek(VaultSession.dek);
    await SecureVaultStorage.setBiometricEnabled(true);
  }

  static Future<bool> tryUnlockWithBiometric() async {
    final enabled = await SecureVaultStorage.isBiometricEnabled();
    if (!enabled) return false;
    final stored = await SecureVaultStorage.readBiometricDek();
    if (stored == null || stored.length != 32) return false;

    final ok = await authenticate(
      reason: 'SAHA 2559 kasasını açmak için kimliğinizi doğrulayın',
    );
    if (!ok) return false;

    VaultSession.unlock(stored);
    return true;
  }

  static Future<void> disable() async {
    await SecureVaultStorage.setBiometricEnabled(false);
  }
}
