import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/module_section_header.dart';
import '../../common/widgets/police_module_icon.dart';
import '../../common/widgets/police_module_list_tile.dart';
import '../../common/widgets/rutbe_level_icon.dart';
import '../araclar/gider/o1_gider_page.dart';
import '../araclar/gorev_puanlari/gorev_puan_hub_page.dart';
import '../il_analiz/il_analiz_hub_page.dart';
import '../araclar/lojman/lojman_puani_page.dart';
import '../home/root_drawer_scope.dart';
import 'atis/atis_takip_page.dart';
import 'disiplin/disiplin_rehberi_page.dart';
import 'gunluk/gorev_gunluk_page.dart';
import 'izin/izin_page.dart';
import 'kariyer/basari/basari_page.dart';
import 'kariyer/egitim/egitim_page.dart';
import 'kariyer/kariyer_hub_page.dart';
import 'kariyer/kariyer_ozet_provider.dart';
import 'emeklilik/emeklilik_takip_page.dart';
import 'kariyer/profil/profil_form.dart';

/// Profilim: kişisel bilgiler + kariyer modülleri.
class GorevlerimPage extends ConsumerStatefulWidget {
  const GorevlerimPage({super.key});

  @override
  ConsumerState<GorevlerimPage> createState() => _GorevlerimPageState();
}

class _GorevlerimPageState extends ConsumerState<GorevlerimPage> {
  bool _profilFormAcik = false;

  @override
  Widget build(BuildContext context) {
    final ozetAsync = ref.watch(kariyerOzetProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Profilim',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Text(
            'Kişisel bilgiler (detaylı)',
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.95),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bilgileri ilk kez girerken form görünür. Kaydettikten sonra ekranı kaplamasın diye özet karta döner.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ozetAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            ),
            error: (_, __) => const Text('Profil yüklenemedi.'),
            data: (ozet) {
              final profilVar = ozet.profil.hasOzet;
              final formAcik = _profilFormAcik || !profilVar;
              if (formAcik) {
                return _ProfilFormCard(
                  onSaved: () => setState(() => _profilFormAcik = false),
                );
              }
              return _ProfilSummaryCard(
                ozet: ozet,
                onEdit: () => setState(() => _profilFormAcik = true),
              );
            },
          ),
          const SizedBox(height: 20),
          ozetAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (ozet) => _MiniOzet(ozet: ozet),
          ),
          const SizedBox(height: 18),
          const ModuleSectionHeader('Kariyer', topGap: 4),
          PoliceModuleListTile(
            style: PoliceModules.basari,
            title: 'Başarı ve Ödüllerim',
            subtitle: 'Başarı, üstün başarı belgeleri ve taltifler',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const BasariPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.egitim,
            title: 'Eğitimlerim',
            subtitle: 'Kurs, sertifika ve diploma kayıtları',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const EgitimPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.kariyerOzet,
            title: 'Kariyer özeti',
            subtitle: 'Tüm kariyer verilerinin özeti',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const KariyerHubPage())),
          ),
          const ModuleSectionHeader(
            'Görev takibi',
            topGap: 18,
          ),
          PoliceModuleListTile(
            style: PoliceModules.gorevGunlugu,
            title: 'Görev Günlüğüm',
            subtitle: 'Görev kaydı, takvim ve istatistik.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const GorevGunlukPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.atisTakip,
            title: 'Atış Takibim',
            subtitle: '4 dönem atış puanı.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const AtisTakipPage())),
          ),
          const ModuleSectionHeader('Emeklilik', topGap: 18),
          PoliceModuleListTile(
            style: PoliceModules.emeklilik,
            title: 'Emeklilik Takibi',
            subtitle: '20 yıl zorunlu hizmet ve yaş haddi ilerlemesi.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const EmeklilikTakipPage())),
          ),
          const ModuleSectionHeader(
            'Kişisel kayıtlar ve özlük',
            subtitle: 'İzin, gider, disiplin, tayin ve lojman.',
            topGap: 18,
          ),
          PoliceModuleListTile(
            style: PoliceModules.izin,
            title: 'İzinlerim',
            subtitle: 'Yıllık, mazeret, refakat izni.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const IzinPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.o1Gider,
            title: 'O-1 Giderleri',
            subtitle: 'Görev giderleri ve fişler.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const O1GiderPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.disiplin,
            title: 'Disiplinlerim',
            subtitle: 'Fiil rehberi ve savunma süreci.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const DisiplinRehberiPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.tayin,
            title: 'İl Analizi',
            subtitle:
                'Tayin kararı — kartlar, puanlar, ilçe ve karşılaştırma.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const IlAnalizHubPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.rehber,
            title: 'Görev puanı hesaplama',
            subtitle: '2025 / 2026 cetveli ve hizmet süreleri.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const GorevPuanHubPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.lojman,
            title: 'Lojmanım',
            subtitle: 'Lojman puanı hesaplama.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const LojmanPuaniPage())),
          ),
        ],
      ),
    );
  }
}

class _ProfilFormCard extends StatelessWidget {
  const _ProfilFormCard({required this.onSaved});

  final VoidCallback onSaved;

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
      child: ProfilForm(onSaved: onSaved),
    );
  }
}

class _ProfilSummaryCard extends StatelessWidget {
  const _ProfilSummaryCard({
    required this.ozet,
    required this.onEdit,
  });

  final KariyerOzet ozet;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final profil = ozet.profil;
    final rutbe = profil.rutbe;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: rutbe == null
                ? const PhosphorIcon(
                    PhosphorIconsRegular.userCircle,
                    color: PoliceColors.primaryBlue,
                    size: 30,
                  )
                : RutbeRankIcon(
                    levelIndex: rutbe.levelIndex,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profil.adSoyad.isEmpty
                      ? 'Profil bilgileri kayıtlı'
                      : profil.adSoyad,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (ozet.rutbeLabel != '—') ozet.rutbeLabel,
                    if (profil.birim.isNotEmpty) profil.birim,
                    if (profil.il.isNotEmpty) profil.il,
                  ].join(' · '),
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ozet.egitimLabel != '—') ...[
                  const SizedBox(height: 2),
                  Text(
                    ozet.egitimLabel,
                    style: TextStyle(
                      color: PoliceColors.gold.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onEdit,
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }
}

class _MiniOzet extends StatelessWidget {
  const _MiniOzet({required this.ozet});

  final KariyerOzet ozet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          _chip('Başarı', '${ozet.basariHesap.basariSayisi}'),
          _chip('Üstün', '${ozet.basariHesap.ustunSayisi}'),
          _chip('Taltif', '${ozet.taltifOzet.toplamSayi}'),
          _chip('Gazi', ozet.gaziLabel),
        ],
      ),
    );
  }

  Widget _chip(String k, String v) => Expanded(
        child: Column(
          children: [
            Text(v,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                )),
            Text(k,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 11,
                )),
          ],
        ),
      );
}

