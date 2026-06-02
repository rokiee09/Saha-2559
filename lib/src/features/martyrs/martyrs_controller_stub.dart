import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';
import 'martyrs_loader.dart';

export 'martyrs_loader.dart'
    show formatMartyrDate, loadMartyrsFromAsset, parseMartyrsFromJson;

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

final martyrsCatalogProvider = FutureProvider<List<Martyr>>((ref) async {
  return loadMartyrsFromAsset();
});

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
