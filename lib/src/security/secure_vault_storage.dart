import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// PIN türevleri ve sarmalanmış DEK — Android Keystore / iOS Keychain.
class SecureVaultStorage {
  SecureVaultStorage._();

  static const _configuredKey = 'vault_pin_configured_v1';
  static const _saltKey = 'vault_pin_salt_v1';
  static const _hashKey = 'vault_pin_hash_v1';
  static const _wrappedDekKey = 'vault_wrapped_dek_v1';
  static const _failedKey = 'vault_failed_attempts_v1';
  static const _lockUntilKey = 'vault_lock_until_ms_v1';
  static const _biometricKey = 'vault_biometric_enabled_v1';
  static const _bioDekKey = 'vault_dek_biometric_v1';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static bool get supported => !kIsWeb;

  static Future<bool> isPinConfigured() async {
    if (!supported) return false;
    final v = await _storage.read(key: _configuredKey);
    return v == '1';
  }

  static Future<void> setPinConfigured(bool value) async {
    await _storage.write(key: _configuredKey, value: value ? '1' : '0');
  }

  static Future<Uint8List?> readSalt() async {
    final raw = await _storage.read(key: _saltKey);
    if (raw == null) return null;
    return base64Decode(raw);
  }

  static Future<void> writeSalt(Uint8List salt) async {
    await _storage.write(key: _saltKey, value: base64Encode(salt));
  }

  static Future<Uint8List?> readPinHash() async {
    final raw = await _storage.read(key: _hashKey);
    if (raw == null) return null;
    return base64Decode(raw);
  }

  static Future<void> writePinHash(Uint8List hash) async {
    await _storage.write(key: _hashKey, value: base64Encode(hash));
  }

  static Future<Uint8List?> readWrappedDek() async {
    final raw = await _storage.read(key: _wrappedDekKey);
    if (raw == null) return null;
    return base64Decode(raw);
  }

  static Future<void> writeWrappedDek(Uint8List wrapped) async {
    await _storage.write(
      key: _wrappedDekKey,
      value: base64Encode(wrapped),
    );
  }

  static Future<int> readFailedAttempts() async {
    final raw = await _storage.read(key: _failedKey);
    return int.tryParse(raw ?? '') ?? 0;
  }

  static Future<void> writeFailedAttempts(int count) async {
    await _storage.write(key: _failedKey, value: count.toString());
  }

  static Future<int?> readLockUntilMs() async {
    final raw = await _storage.read(key: _lockUntilKey);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  static Future<void> writeLockUntilMs(int? ms) async {
    if (ms == null) {
      await _storage.delete(key: _lockUntilKey);
    } else {
      await _storage.write(key: _lockUntilKey, value: ms.toString());
    }
  }

  static Future<bool> isBiometricEnabled() async {
    return (await _storage.read(key: _biometricKey)) == '1';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled ? '1' : '0');
    if (!enabled) {
      await _storage.delete(key: _bioDekKey);
    }
  }

  static Future<void> writeBiometricDek(Uint8List dek) async {
    await _storage.write(key: _bioDekKey, value: base64Encode(dek));
  }

  static Future<Uint8List?> readBiometricDek() async {
    final raw = await _storage.read(key: _bioDekKey);
    if (raw == null) return null;
    return base64Decode(raw);
  }

  static Future<void> clearAllVaultSecrets() async {
    await _storage.delete(key: _configuredKey);
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _wrappedDekKey);
    await _storage.delete(key: _failedKey);
    await _storage.delete(key: _lockUntilKey);
    await _storage.delete(key: _biometricKey);
    await _storage.delete(key: _bioDekKey);
  }
}
