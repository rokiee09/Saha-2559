import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';
import 'web_martyrs.dart';

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

final martyrsFilteredProvider =
    FutureProvider<List<Martyr>>((ref) async {
  final all = await ref.watch(webMartyrsProvider.future);
  final city = ref.watch(martyrCityFilterProvider);
  final nameQ = ref.watch(martyrNameQueryProvider).trim().toLowerCase();

  var out = all.where((m) {
    if (city != null && city.isNotEmpty && m.cityName != city) {
      return false;
    }
    if (nameQ.isNotEmpty && !m.fullName.toLowerCase().contains(nameQ)) {
      return false;
    }
    return true;
  }).toList();

  int cmp(Martyr a, Martyr b) {
    final da = a.dateOfMartyrdom;
    final db = b.dateOfMartyrdom;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }

  out.sort(cmp);
  return out;
});

final martyrCitiesProvider =
    FutureProvider<List<String>>((ref) async {
  final all = await ref.watch(webMartyrsProvider.future);
  final s = all.map((m) => m.cityName).toSet().toList()..sort();
  return s;
});
