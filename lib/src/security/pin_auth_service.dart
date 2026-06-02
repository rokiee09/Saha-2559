import 'package:flutter/foundation.dart';

import 'secure_vault_storage.dart';
import 'vault_crypto.dart';
import 'vault_session.dart';

enum PinVerifyResult {
  success,
  wrongPin,
  locked,
  notConfigured,
  invalidPin,
}

/// 6 haneli PIN: PBKDF2 türevi + hash; düz metin saklanmaz.
class PinAuthService {
  PinAuthService._();

  static const pinLength = 6;
  static const maxAttempts = 5;

  static bool isValidPinFormat(String pin) {
    return pin.length == pinLength && RegExp(r'^\d{6}$').hasMatch(pin);
  }

  static Future<int?> lockRemainingMs() async {
    final until = await SecureVaultStorage.readLockUntilMs();
    if (until == null) return null;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    if (left <= 0) {
      await SecureVaultStorage.writeLockUntilMs(null);
      return null;
    }
    return left;
  }

  static int _lockDurationMs(int failedAfterReset) {
    if (failedAfterReset <= 5) return 30 * 1000;
    if (failedAfterReset <= 8) return 2 * 60 * 1000;
    return 15 * 60 * 1000;
  }

  static Future<PinVerifyResult> setupPin(String pin) async {
    if (!isValidPinFormat(pin)) return PinVerifyResult.invalidPin;
    final dek = VaultCrypto.randomBytes(32);
    final salt = VaultCrypto.randomBytes(16);
    final pinKey = await VaultCrypto.derivePinKey(pin, salt);
    final hash = await VaultCrypto.hashPinKey(pinKey);
    final wrapped = await VaultCrypto.wrapDek(dek, pinKey);

    await SecureVaultStorage.writeSalt(salt);
    await SecureVaultStorage.writePinHash(hash);
    await SecureVaultStorage.writeWrappedDek(wrapped);
    await SecureVaultStorage.writeFailedAttempts(0);
    await SecureVaultStorage.writeLockUntilMs(null);
    await SecureVaultStorage.setPinConfigured(true);

    VaultSession.unlock(dek);
    return PinVerifyResult.success;
  }

  static Future<PinVerifyResult> verifyPin(String pin) async {
    if (!isValidPinFormat(pin)) return PinVerifyResult.invalidPin;

    final remaining = await lockRemainingMs();
    if (remaining != null) return PinVerifyResult.locked;

    final configured = await SecureVaultStorage.isPinConfigured();
    if (!configured) return PinVerifyResult.notConfigured;

    final salt = await SecureVaultStorage.readSalt();
    final storedHash = await SecureVaultStorage.readPinHash();
    final wrapped = await SecureVaultStorage.readWrappedDek();
    if (salt == null || storedHash == null || wrapped == null) {
      return PinVerifyResult.notConfigured;
    }

    final pinKey = await VaultCrypto.derivePinKey(pin, salt);
    final hash = await VaultCrypto.hashPinKey(pinKey);
    if (!_constantTimeEquals(hash, storedHash)) {
      final failed = (await SecureVaultStorage.readFailedAttempts()) + 1;
      await SecureVaultStorage.writeFailedAttempts(failed);
      if (failed >= maxAttempts) {
        final until = DateTime.now().millisecondsSinceEpoch +
            _lockDurationMs(failed);
        await SecureVaultStorage.writeLockUntilMs(until);
        await SecureVaultStorage.writeFailedAttempts(0);
      }
      return PinVerifyResult.wrongPin;
    }

    try {
      final dek = await VaultCrypto.unwrapDek(wrapped, pinKey);
      await SecureVaultStorage.writeFailedAttempts(0);
      await SecureVaultStorage.writeLockUntilMs(null);
      VaultSession.unlock(dek);
      return PinVerifyResult.success;
    } catch (e, st) {
      debugPrint('PIN unwrap hatası: $e');
      debugPrintStack(stackTrace: st);
      return PinVerifyResult.wrongPin;
    }
  }

  /// Mevcut şifreli veriyi korur; yalnızca PIN sarmalayıcısını yeniler.
  static Future<PinVerifyResult> changePin(String oldPin, String newPin) async {
    if (!isValidPinFormat(newPin)) return PinVerifyResult.invalidPin;
    final check = await verifyPin(oldPin);
    if (check != PinVerifyResult.success) return check;
    if (!VaultSession.isUnlocked) return PinVerifyResult.wrongPin;

    final dek = Uint8List.fromList(VaultSession.dek);
    final salt = VaultCrypto.randomBytes(16);
    final pinKey = await VaultCrypto.derivePinKey(newPin, salt);
    final hash = await VaultCrypto.hashPinKey(pinKey);
    final wrapped = await VaultCrypto.wrapDek(dek, pinKey);

    await SecureVaultStorage.writeSalt(salt);
    await SecureVaultStorage.writePinHash(hash);
    await SecureVaultStorage.writeWrappedDek(wrapped);
    await SecureVaultStorage.writeFailedAttempts(0);
    await SecureVaultStorage.writeLockUntilMs(null);
    return PinVerifyResult.success;
  }

  static Future<void> lockSession() async {
    VaultSession.lock();
  }

  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
