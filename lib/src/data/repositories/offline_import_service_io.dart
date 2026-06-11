import '../../data/db/isar_service.dart';
import '../../data/models/city_contact.dart';
import '../../data/models/martyr.dart';
import '../../features/contacts/city_contacts_loader.dart';
import '../../features/martyrs/martyrs_loader.dart';

class OfflineImportService {
  /// Eski API — yalnızca boş tabloları doldurur.
  static Future<void> importAll() => seedIfNeeded();

  /// İlk kurulumda JSON → Isar; sonraki açılışlarda atlanır.
  static Future<void> seedIfNeeded() async {
    if (!IsarService.isReady) return;
    await Future.wait([
      _seedCityContactsIfEmpty(),
      _seedMartyrsIfEmpty(),
    ]);
  }

  @Deprecated('seedIfNeeded kullanın')
  static Future<void> importCityContacts() => _seedCityContactsIfEmpty();

  @Deprecated('seedIfNeeded kullanın')
  static Future<void> importMartyrs() => _seedMartyrsIfEmpty();

  static Future<void> _seedCityContactsIfEmpty() async {
    try {
      final isar = IsarService.db;
      final count = await isar.cityContacts.count();
      if (count > 0) return;

      final contacts = await loadCityContactsFromAsset();
      if (contacts.isEmpty) return;

      await isar.writeTxn(() async {
        await isar.cityContacts.putAll(contacts);
      });
    } catch (_) {}
  }

  static Future<void> _seedMartyrsIfEmpty() async {
    try {
      final isar = IsarService.db;
      final count = await isar.martyrs.count();
      if (count > 0) return;

      final martyrs = await loadMartyrsFromAsset();
      if (martyrs.isEmpty) return;

      await isar.writeTxn(() async {
        await isar.martyrs.putAll(martyrs);
      });
    } catch (_) {}
  }
}
