import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';
import 'martyrs_controller_io.dart';

final martyrProvider =
    FutureProvider.family<Martyr?, int>((ref, id) async {
  final all = await ref.watch(martyrsCatalogProvider.future);
  for (final m in all) {
    if (m.id == id) return m;
  }
  return null;
});
