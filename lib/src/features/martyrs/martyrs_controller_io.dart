import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/martyr.dart';
import 'martyrs_loader.dart';

export 'martyrs_loader.dart'
    show formatMartyrDate, loadMartyrsFromAsset, parseMartyrsFromJson;

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

/// Tüm şehit kayıtları — her zaman `martyrs.json`.
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
  final city = ref.watch(martyrCityFilterProvider);
  final nameQ = ref.watch(martyrNameQueryProvider);
  return filterMartyrs(all: all, city: city, nameQuery: nameQ);
});

final martyrCitiesProvider = FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  return martyrCityNames(all);
});
