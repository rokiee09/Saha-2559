import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../atis/atis_models.dart';
import '../atis/atis_store.dart';
import '../gunluk/gorev_gunluk_store.dart';
import 'basari/basari_models.dart';
import 'basari/basari_store.dart';
import 'egitim/egitim_models.dart';
import 'egitim/egitim_store.dart';
import 'kariyer_constants.dart';
import 'kariyer_profil.dart';
import 'kariyer_profil_provider.dart';

class KariyerOzet {
  const KariyerOzet({
    required this.profil,
    required this.basariHesap,
    required this.egitimStat,
    required this.atisTamamlanan,
    required this.toplamGorev,
  });

  final KariyerProfil profil;
  final BasariHesap basariHesap;
  final EgitimIstatistik egitimStat;
  final int atisTamamlanan;
  final int toplamGorev;

  String get rutbeLabel => profil.rutbe?.label ?? '—';
  String get egitimLabel => profil.egitim?.label ?? '—';
}

final kariyerOzetProvider = FutureProvider<KariyerOzet>((ref) async {
  ref.watch(kariyerVersionProvider);
  final profil = await ref.watch(kariyerProfilProvider.future);
  final basari = await ref.watch(basariBelgelerProvider.future);
  final egitim = await ref.watch(egitimKayitlarProvider.future);
  final atis = await atisLoadAll();
  final gorevler = await gorevGunlukLoadAll();

  return KariyerOzet(
    profil: profil,
    basariHesap: hesaplaBasari(basari),
    egitimStat: egitimIstatistik(egitim),
    atisTamamlanan:
        atisTamamlananDonemSayisi(atis, yil: DateTime.now().year),
    toplamGorev: gorevler.length,
  );
});
