import 'package:shared_preferences/shared_preferences.dart';

import 'vault_crypto.dart';
import 'vault_session.dart';

/// Hassas SharedPreferences kayıtları — AES-256-GCM, yalnızca kasa açıkken.
class EncryptedLocalStore {
  EncryptedLocalStore._();

  static String _encKey(String logicalKey) => 'vault_enc:$logicalKey';

  static Future<String?> readString(String logicalKey) async {
    if (!VaultSession.isUnlocked) return null;
    final prefs = await SharedPreferences.getInstance();
    final enc = prefs.getString(_encKey(logicalKey));
    if (enc != null && enc.isNotEmpty) {
      return VaultCrypto.decryptString(enc, VaultSession.dek);
    }
    return prefs.getString(logicalKey);
  }

  static Future<void> writeString(String logicalKey, String value) async {
    if (!VaultSession.isUnlocked) {
      throw StateError('Kasa kilitliyken yazılamaz');
    }
    final prefs = await SharedPreferences.getInstance();
    final enc = await VaultCrypto.encryptString(value, VaultSession.dek);
    await prefs.setString(_encKey(logicalKey), enc);
    await prefs.remove(logicalKey);
  }

  static Future<void> remove(String logicalKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(logicalKey);
    await prefs.remove(_encKey(logicalKey));
  }
}
