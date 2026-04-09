import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/martyr.dart';

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

final martyrsFilteredProvider =
    FutureProvider<List<Martyr>>((ref) async {
  final city = ref.watch(martyrCityFilterProvider);
  final nameQ = ref.watch(martyrNameQueryProvider).toLowerCase();
  final isar = IsarService.db;

  final hasCity = city != null && city.isNotEmpty;
  final hasName = nameQ.isNotEmpty;

  if (!hasCity && !hasName) {
    return isar.martyrs.where().sortByDateOfMartyrdomDesc().findAll();
  }

  if (hasCity && hasName) {
    return isar.martyrs
        .filter()
        .cityNameEqualTo(city)
        .and()
        .fullNameContains(nameQ, caseSensitive: false)
        .sortByDateOfMartyrdomDesc()
        .findAll();
  }

  if (hasCity) {
    return isar.martyrs
        .filter()
        .cityNameEqualTo(city)
        .sortByDateOfMartyrdomDesc()
        .findAll();
  }

  return isar.martyrs
      .filter()
      .fullNameContains(nameQ, caseSensitive: false)
      .sortByDateOfMartyrdomDesc()
      .findAll();
});

final martyrCitiesProvider =
    FutureProvider<List<String>>((ref) async {
  final isar = IsarService.db;
  final martyrs = await isar.martyrs.where().findAll();
  final set = <String>{};
  for (final m in martyrs) {
    set.add(m.cityName);
  }
  final list = set.toList()..sort();
  return list;
});
