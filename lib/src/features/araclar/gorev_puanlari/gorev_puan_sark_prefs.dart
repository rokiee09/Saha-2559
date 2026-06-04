import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sarkBaslangicKey = 'gorev_puan_sark_baslangic_ms_v1';

final gorevPuanSarkVersionProvider = StateProvider<int>((ref) => 0);

final gorevPuanSarkBaslangicProvider = FutureProvider<DateTime?>((ref) async {
  ref.watch(gorevPuanSarkVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_sarkBaslangicKey);
  if (ms == null || ms <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms);
});

Future<void> gorevPuanSarkBaslangicKaydet(
  WidgetRef ref,
  DateTime? tarih,
) async {
  final prefs = await SharedPreferences.getInstance();
  if (tarih == null) {
    await prefs.remove(_sarkBaslangicKey);
  } else {
    await prefs.setInt(_sarkBaslangicKey, tarih.millisecondsSinceEpoch);
  }
  ref.read(gorevPuanSarkVersionProvider.notifier).state++;
}
