import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';
import 'martyrs_anniversary.dart';
import 'martyrs_loader.dart';

export 'martyrs_loader.dart'
    show formatMartyrDate, loadMartyrsFromAsset, parseMartyrsFromJson;

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');
final martyrsAnniversaryFilterProvider = StateProvider<bool>((ref) => false);

class MartyrsAnniversaryToday {
  const MartyrsAnniversaryToday({
    required this.gun,
    required this.martyrs,
  });

  final DateTime gun;
  final List<Martyr> martyrs;
}

final martyrsCatalogProvider = FutureProvider<List<Martyr>>((ref) async {
  return loadMartyrsFromAsset();
});

final martyrsAnniversaryTodayProvider =
    FutureProvider<MartyrsAnniversaryToday>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  final gun = DateTime.now();
  final martyrs = martyrsOnAnniversaryDay(all, gun);
  return MartyrsAnniversaryToday(gun: gun, martyrs: martyrs);
});

final martyrsFilteredProvider =
    FutureProvider<List<Martyr>>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  if (ref.watch(martyrsAnniversaryFilterProvider)) {
    return martyrsOnAnniversaryDay(all, DateTime.now());
  }
  final city = ref.watch(martyrCityFilterProvider);
  final nameQ = ref.watch(martyrNameQueryProvider);
  return filterMartyrs(all: all, city: city, nameQuery: nameQ);
});

final martyrCitiesProvider = FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  return martyrCityNames(all);
});
