import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';

final martyrProvider =
    FutureProvider.family<Martyr?, int>((ref, id) async => null);
