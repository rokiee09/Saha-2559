import '../../data/db/isar_service.dart';
import '../../data/models/city_contact.dart';
import '../../data/models/martyr.dart';
import '../../features/contacts/city_contacts_loader.dart';
import '../../features/martyrs/martyrs_loader.dart';

class OfflineImportService {
  static Future<void> importAll() async {
    await Future.wait([
      importCityContacts(),
      importMartyrs(),
    ]);
  }

  /// 81 il emniyet müdürlüğü — `assets/json/city_contacts.json` → Isar.
  static Future<void> importCityContacts() async {
    final contacts = await loadCityContactsFromAsset();

    final isar = IsarService.db;
    await isar.writeTxn(() async {
      await isar.cityContacts.clear();
      await isar.cityContacts.putAll(contacts);
    });
  }

  /// Şehit listesi — `assets/json/martyrs.json` → Isar.
  static Future<void> importMartyrs() async {
    final martyrs = await loadMartyrsFromAsset();

    final isar = IsarService.db;
    await isar.writeTxn(() async {
      await isar.martyrs.clear();
      await isar.martyrs.putAll(martyrs);
    });
  }
}
