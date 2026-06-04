import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'encrypted_local_store.dart';
import 'vault_migration.dart';
import 'vault_session.dart';

const kVaultBackupFormat = 'saha2559_vault_backup';
const kVaultBackupVersion = 1;

class VaultBackupPayload {
  const VaultBackupPayload({
    required this.exportedAt,
    required this.entries,
  });

  final DateTime exportedAt;
  final Map<String, String> entries;

  Map<String, dynamic> toJson() => {
        'format': kVaultBackupFormat,
        'version': kVaultBackupVersion,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'entries': entries,
      };

  factory VaultBackupPayload.fromJson(Map<String, dynamic> json) {
    if (json['format'] != kVaultBackupFormat) {
      throw const FormatException('Geçersiz yedek dosyası');
    }
    final version = json['version'];
    if (version is! int || version > kVaultBackupVersion) {
      throw const FormatException('Desteklenmeyen yedek sürümü');
    }
    final rawEntries = json['entries'];
    if (rawEntries is! Map) {
      throw const FormatException('Yedek kayıtları okunamadı');
    }
    final entries = <String, String>{};
    for (final e in rawEntries.entries) {
      if (e.key is String && e.value is String) {
        entries[e.key as String] = e.value as String;
      }
    }
    final atRaw = json['exportedAt'] as String? ?? '';
    final exportedAt = DateTime.tryParse(atRaw) ?? DateTime.now();
    return VaultBackupPayload(exportedAt: exportedAt, entries: entries);
  }
}

class VaultBackupService {
  VaultBackupService._();

  static Future<VaultBackupPayload> exportPayload() async {
    if (!VaultSession.isUnlocked) {
      throw StateError('Yedek için kasa açık olmalıdır');
    }
    final entries = <String, String>{};
    for (final key in VaultMigration.sensitiveKeys) {
      final value = await EncryptedLocalStore.readString(key);
      if (value != null && value.isNotEmpty) {
        entries[key] = value;
      }
    }
    return VaultBackupPayload(
      exportedAt: DateTime.now(),
      entries: entries,
    );
  }

  static Future<String> exportJson() async {
    final payload = await exportPayload();
    return const JsonEncoder.withIndent('  ').convert(payload.toJson());
  }

  static VaultBackupPayload parseJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON bekleniyordu');
    }
    return VaultBackupPayload.fromJson(decoded);
  }

  /// Yedekten gelen kayıtları mevcut kasa anahtarıyla yeniden şifreler.
  static Future<int> importPayload(
    VaultBackupPayload payload, {
    bool replaceExisting = true,
  }) async {
    if (!VaultSession.isUnlocked) {
      throw StateError('Geri yükleme için kasa açık olmalıdır');
    }
    var count = 0;
    for (final key in VaultMigration.sensitiveKeys) {
      final value = payload.entries[key];
      if (value == null || value.isEmpty) continue;
      if (!replaceExisting) {
        final existing = await EncryptedLocalStore.readString(key);
        if (existing != null && existing.isNotEmpty) continue;
      }
      await EncryptedLocalStore.writeString(key, value);
      count++;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(VaultMigration.migrationDonePrefsKey, true);
    return count;
  }
}
