import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/field_card.dart';

final fieldCardsProvider =
    FutureProvider.autoDispose<List<FieldCard>>((ref) async => []);
