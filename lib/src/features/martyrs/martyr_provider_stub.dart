import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';
import 'web_martyrs.dart';

final martyrProvider =
    FutureProvider.family<Martyr?, int>((ref, id) async {
  final all = await ref.watch(webMartyrsProvider.future);
  for (final m in all) {
    if (m.id == id) return m;
  }
  return null;
});
