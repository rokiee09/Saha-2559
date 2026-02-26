import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/martyr.dart';

final martyrCityFilterProvider = StateProvider<String?>((ref) => null);
final martyrNameQueryProvider = StateProvider<String>((ref) => '');

final martyrsFilteredProvider =
    FutureProvider<List<Martyr>>((ref) async => []);

final martyrCitiesProvider =
    FutureProvider<List<String>>((ref) async => []);
