import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'saglik_metin.dart';

final saglikMetinProvider =
    FutureProvider.family<SaglikMetinBelge, SaglikMetinId>((ref, id) async {
  final raw = await rootBundle.loadString(id.assetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return SaglikMetinBelge.fromJson(json);
});
