import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../kariyer/kariyer_profil_provider.dart';
import 'emeklilik_calculator.dart';

final emeklilikDurumProvider = Provider<EmeklilikDurum?>((ref) {
  final profil = ref.watch(kariyerProfilProvider).valueOrNull;
  if (profil == null || !profil.emeklilikHesaplanabilir) return null;
  return hesaplaEmeklilik(profil, DateTime.now());
});
