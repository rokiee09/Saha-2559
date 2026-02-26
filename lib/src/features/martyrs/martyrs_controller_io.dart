import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/martyr.dart';

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

final martyrsFilteredProvider =
    FutureProvider<List<Martyr>>((ref) async {
  final city = ref.watch(martyrCityFilterProvider);
  final nameQ = ref.watch(martyrNameQueryProvider).toLowerCase();
  final isar = IsarService.db;

  final q = isar.martyrs.filter();

  if (city != null && city.isNotEmpty) {
    q.cityNameEqualTo(city);
  }

  if (nameQ.isNotEmpty) {
    q.fullNameContains(nameQ, caseSensitive: false);
  }

  return q.sortByDateOfMartyrdomDesc().findAll();
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
