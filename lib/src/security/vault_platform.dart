import 'encrypted_local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vault_gate.dart';

/// Mobil: şifreli kasa; masaüstü/web: düz yerel (geliştirme).
class VaultPlatform {
  VaultPlatform._();

  static bool get usesVault => VaultGate.vaultRequired;

  static Future<String?> readSensitive(String key) async {
    if (usesVault) {
      return EncryptedLocalStore.readString(key);
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> writeSensitive(String key, String value) async {
    if (usesVault) {
      await EncryptedLocalStore.writeString(key, value);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
