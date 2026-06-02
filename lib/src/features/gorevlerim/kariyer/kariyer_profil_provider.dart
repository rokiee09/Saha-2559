import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kariyer_profil.dart';

const _profilV2Key = 'kariyer_profil_v2';
const _profilV1Key = 'kariyer_profil_v1';

final kariyerVersionProvider = StateProvider<int>((ref) => 0);

final kariyerProfilProvider = FutureProvider<KariyerProfil>((ref) async {
  ref.watch(kariyerVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final v2 = prefs.getString(_profilV2Key);
  if (v2 != null && v2.isNotEmpty) {
    try {
      return KariyerProfil.fromJson(jsonDecode(v2) as Map<String, dynamic>);
    } catch (_) {}
  }
  final v1 = prefs.getString(_profilV1Key);
  if (v1 != null && v1.isNotEmpty) {
    try {
      final legacy = jsonDecode(v1) as Map<String, dynamic>;
      final migrated = KariyerProfil.fromLegacyV1(legacy);
      await prefs.setString(_profilV2Key, jsonEncode(migrated.toJson()));
      return migrated;
    } catch (_) {}
  }
  return const KariyerProfil();
});

Future<void> kariyerSaveProfil(WidgetRef ref, KariyerProfil profil) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_profilV2Key, jsonEncode(profil.toJson()));
  ref.read(kariyerVersionProvider.notifier).state++;
}
