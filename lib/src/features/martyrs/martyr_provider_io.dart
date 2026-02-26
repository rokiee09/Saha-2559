import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/martyr.dart';

final martyrProvider =
    FutureProvider.family<Martyr?, int>((ref, id) async {
  final isar = IsarService.db;
  return isar.martyrs.get(id);
});
