import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'encrypted_local_store.dart';
import 'vault_sensitive_catalog.dart';
import 'vault_session.dart';

class VaultInventoryRow {
  const VaultInventoryRow({
    required this.category,
    required this.status,
    required this.detail,
    this.itemCount,
  });

  final VaultSensitiveCategory category;
  final VaultInventoryStatus status;
  final String detail;
  final int? itemCount;
}

enum VaultInventoryStatus {
  empty,
  encrypted,
  plainLegacy,
  unlocked,
}

class VaultDataInventory {
  VaultDataInventory._();

  static Future<List<VaultInventoryRow>> scan() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = VaultSession.isUnlocked;
    final rows = <VaultInventoryRow>[];

    for (final cat in kVaultSensitiveCategories) {
      final encKey = 'vault_enc:${cat.logicalKey}';
      final enc = prefs.getString(encKey);
      final plain = prefs.getString(cat.logicalKey);

      if (unlocked) {
        final raw = await EncryptedLocalStore.readString(cat.logicalKey);
        if (raw == null || raw.isEmpty) {
          rows.add(
            VaultInventoryRow(
              category: cat,
              status: VaultInventoryStatus.empty,
              detail: 'Kayıt yok',
            ),
          );
          continue;
        }
        final count = _estimateItemCount(raw);
        rows.add(
          VaultInventoryRow(
            category: cat,
            status: VaultInventoryStatus.unlocked,
            detail: count != null ? '$count kayıt' : 'Şifreli veri yüklü',
            itemCount: count,
          ),
        );
        continue;
      }

      if (enc != null && enc.isNotEmpty) {
        rows.add(
          VaultInventoryRow(
            category: cat,
            status: VaultInventoryStatus.encrypted,
            detail: 'AES-256-GCM (${enc.length} bayt)',
          ),
        );
      } else if (plain != null && plain.isNotEmpty) {
        rows.add(
          VaultInventoryRow(
            category: cat,
            status: VaultInventoryStatus.plainLegacy,
            detail: 'İlk açılışta şifrelenecek',
          ),
        );
      } else {
        rows.add(
          VaultInventoryRow(
            category: cat,
            status: VaultInventoryStatus.empty,
            detail: 'Kayıt yok',
          ),
        );
      }
    }

    return rows;
  }

  static int? _estimateItemCount(String raw) {
    try {
      final dec = jsonDecode(raw);
      if (dec is List) return dec.length;
      if (dec is Map) return dec.length;
    } catch (_) {
      return null;
    }
    return null;
  }
}
