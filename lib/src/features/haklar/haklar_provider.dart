import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/text/tr_text.dart';
import 'haklar_data.dart';

final haklarSearchQueryProvider = StateProvider<String>((ref) => '');

final haklarCategoryProvider =
    StateProvider<HaklarCategory>((ref) => HaklarCategory.tumu);

final haklarFilteredProvider = Provider<List<RightItem>>((ref) {
  final q = trFold(ref.watch(haklarSearchQueryProvider).trim());
  final cat = ref.watch(haklarCategoryProvider);
  Iterable<RightItem> list = rightsData;
  if (cat != HaklarCategory.tumu) {
    list = list.where((r) => r.category == cat);
  }
  if (q.isEmpty) return list.toList();
  return list.where((r) {
    final blob = trFold(
      '${r.title} ${r.shortDescription} ${r.fullContent} ${r.legalRefs.join(' ')}',
    );
    return blob.contains(q);
  }).toList();
});
