import 'package:shared_preferences/shared_preferences.dart';

import 'encrypted_local_store.dart';
import 'vault_session.dart';

/// Eski düz metin kayıtları ilk açılışta şifreli forma taşınır.
class VaultMigration {
  VaultMigration._();

  static const sensitiveKeys = <String>[
    'saha_local_notes_v1',
    'gorev_gunluk_v1',
    'o1_gider_v1',
    'sifre_kayitli_v1',
  ];

  static const _doneKey = 'vault_migration_v1_done';

  static Future<void> runIfNeeded() async {
    if (!VaultSession.isUnlocked) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_doneKey) == true) return;

    for (final key in sensitiveKeys) {
      final plain = prefs.getString(key);
      if (plain != null && plain.isNotEmpty) {
        final encExists = prefs.getString('vault_enc:$key');
        if (encExists == null || encExists.isEmpty) {
          await EncryptedLocalStore.writeString(key, plain);
        } else {
          await prefs.remove(key);
        }
      }
    }

    await prefs.setBool(_doneKey, true);
  }
}
