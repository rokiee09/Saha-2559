import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'haklar_data.dart';

final haklarSearchQueryProvider = StateProvider<String>((ref) => '');

final haklarCategoryProvider =
    StateProvider<HaklarCategory>((ref) => HaklarCategory.tumu);

final haklarFilteredProvider = Provider<List<RightItem>>((ref) {
  final q = ref.watch(haklarSearchQueryProvider).trim().toLowerCase();
  final cat = ref.watch(haklarCategoryProvider);
  Iterable<RightItem> list = rightsData;
  if (cat != HaklarCategory.tumu) {
    list = list.where((r) => r.category == cat);
  }
  if (q.isEmpty) return list.toList();
  return list.where((r) {
    final blob =
        '${r.title} ${r.shortDescription} ${r.fullContent} ${r.legalRefs.join(' ')}'
            .toLowerCase();
    return blob.contains(q);
  }).toList();
});
