import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/field_card.dart';

final fieldCardsProvider = FutureProvider.autoDispose<List<FieldCard>>((ref) async {
  final isar = IsarService.db;
  return isar.fieldCards.where().findAll();
});
