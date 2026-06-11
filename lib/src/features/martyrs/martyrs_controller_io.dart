import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/martyr.dart';
import 'martyrs_anniversary.dart';
import 'martyrs_loader.dart';

export 'martyrs_loader.dart'
    show formatMartyrDate, loadMartyrsFromAsset, parseMartyrsFromJson;

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

/// Şehitler sayfasında yalnızca bugünün yıldönümü kayıtları.
final martyrsAnniversaryFilterProvider = StateProvider<bool>((ref) => false);

class MartyrsAnniversaryToday {
  const MartyrsAnniversaryToday({
    required this.gun,
    required this.martyrs,
  });

  final DateTime gun;
  final List<Martyr> martyrs;
}

final martyrsAnniversaryTodayProvider =
    FutureProvider<MartyrsAnniversaryToday>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  final gun = DateTime.now();
  final martyrs = martyrsOnAnniversaryDay(all, gun);
  return MartyrsAnniversaryToday(gun: gun, martyrs: martyrs);
});

/// Tüm şehit kayıtları — `martyrs.json` (Isar yalnızca tohum/yedek).
final martyrsCatalogProvider = FutureProvider<List<Martyr>>((ref) async {
  final fromAsset = await loadMartyrsFromAsset();
  await _trySeedIsar(fromAsset);
  return fromAsset;
});

Future<void> _trySeedIsar(List<Martyr> martyrs) async {
  if (martyrs.isEmpty) return;
  try {
    final isar = IsarService.db;
    final count = await isar.martyrs.count();
    if (count > 0) return;
    await isar.writeTxn(() async {
      await isar.martyrs.putAll(martyrs);
    });
  } catch (_) {}
}

final martyrsFilteredProvider =
    FutureProvider<List<Martyr>>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  if (ref.watch(martyrsAnniversaryFilterProvider)) {
    final gun = DateTime.now();
    return martyrsOnAnniversaryDay(all, gun);
  }
  final city = ref.watch(martyrCityFilterProvider);
  final nameQ = ref.watch(martyrNameQueryProvider);
  return filterMartyrs(all: all, city: city, nameQuery: nameQ);
});

final martyrCitiesProvider = FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  return martyrCityNames(all);
});
