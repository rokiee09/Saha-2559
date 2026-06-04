import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../../common/widgets/police_module_icon.dart';
import '../../../common/widgets/police_module_list_tile.dart';
import '../atis/atis_takip_page.dart';
import '../emeklilik/emeklilik_takip_page.dart';
import '../gunluk/gorev_gunluk_page.dart';
import 'basari/basari_page.dart';
import 'egitim/egitim_page.dart';
import 'kariyer_ozet_provider.dart';
import 'profil/profil_page.dart';

/// Kariyer merkezi: özet + alt modüller.
class KariyerHubPage extends ConsumerWidget {
  const KariyerHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ozetAsync = ref.watch(kariyerOzetProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Kariyerim'),
      ),
      body: ozetAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Özet yüklenemedi.')),
        data: (ozet) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            _OzetPanel(ozet: ozet),
            const SizedBox(height: 18),
            PoliceModuleListTile(
              style: PoliceModules.profilim,
              title: 'Profilim',
              subtitle: 'Kimlik, rütbe, birim, eğitim, gazilik',
              onTap: () =>
                  Navigator.of(context).push(fadeRoute(const ProfilPage())),
            ),
            PoliceModuleListTile(
              style: PoliceModules.emeklilik,
              title: 'Emeklilik Takibi',
              subtitle: '20 yıl zorunlu hizmet ve yaş haddi',
              onTap: () => Navigator.of(context)
                  .push(fadeRoute(const EmeklilikTakipPage())),
            ),
            PoliceModuleListTile(
              style: PoliceModules.basari,
              title: 'Başarı ve Ödüllerim',
              subtitle:
                  'Başarı ${ozet.basariHesap.basariSayisi} · Üstün ${ozet.basariHesap.ustunSayisi} · Taltif ${ozet.taltifOzet.toplamSayi}',
              onTap: () =>
                  Navigator.of(context).push(fadeRoute(const BasariPage())),
            ),
            PoliceModuleListTile(
              style: PoliceModules.egitim,
              title: 'Eğitimlerim',
              subtitle:
                  '${ozet.egitimStat.toplamEgitim} eğitim · ${ozet.egitimStat.toplamSertifika} sertifika',
              onTap: () =>
                  Navigator.of(context).push(fadeRoute(const EgitimPage())),
            ),
            PoliceModuleListTile(
              style: PoliceModules.gorevGunlugu,
              title: 'Görev Günlüğüm',
              subtitle: '${ozet.toplamGorev} kayıtlı görev',
              onTap: () => Navigator.of(context)
                  .push(fadeRoute(const GorevGunlukPage())),
            ),
            PoliceModuleListTile(
              style: PoliceModules.atisTakip,
              title: 'Atış Takibim',
              subtitle: '${ozet.atisTamamlanan}/4 dönem tamamlandı',
              onTap: () =>
                  Navigator.of(context).push(fadeRoute(const AtisTakipPage())),
            ),
            const SizedBox(height: 12),
            Text(
              'Tüm veriler yalnızca bu cihazda saklanır; resmî özlük veya '
              'sicil kaydı yerine geçmez.',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.75),
                fontSize: 11.5,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OzetPanel extends StatelessWidget {
  const _OzetPanel({required this.ozet});

  final KariyerOzet ozet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kariyer özeti',
            style: TextStyle(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _line('Rütbe', ozet.rutbeLabel),
          _line('Birim', ozet.profil.birim.isEmpty ? '—' : ozet.profil.birim),
          _line('Eğitim', ozet.egitimLabel),
          _line('Başarı belgesi', '${ozet.basariHesap.basariSayisi}'),
          _line('Üstün başarı', '${ozet.basariHesap.ustunSayisi}'),
          _line('Taltif', '${ozet.taltifOzet.toplamSayi}'),
          _line('Gazilik', ozet.gaziLabel),
          _line('Atış dönemi', '${ozet.atisTamamlanan}/4'),
          _line('Toplam görev', '${ozet.toplamGorev}'),
          _line('Toplam eğitim',
              '${ozet.egitimStat.toplamEgitim + ozet.egitimStat.toplamSertifika}'),
        ],
      ),
    );
  }

  Widget _line(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(k,
                  style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.85),
                      fontSize: 13)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5)),
            ),
          ],
        ),
      );
}

