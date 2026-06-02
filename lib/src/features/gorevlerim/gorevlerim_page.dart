import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../araclar/gider/o1_gider_page.dart';
import '../araclar/gorev_puanlari/gorev_puani_giris_page.dart';
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
import 'kariyer/profil/profil_form.dart';

/// Profilim: kişisel bilgiler + kariyer modülleri.
class GorevlerimPage extends ConsumerWidget {
  const GorevlerimPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Ad, sicil, rütbe, birim, göreve başlama, eğitim ve gazilik durumunu buradan gir. '
            'Ana sayfada yalnızca rütbe, ad, birim ve eğitim özeti görünür.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PoliceColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
              ),
            ),
            child: const ProfilForm(),
          ),
          const SizedBox(height: 20),
          ozetAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (ozet) => _MiniOzet(ozet: ozet),
          ),
          const SizedBox(height: 18),
          const _SectionLabel('Kariyer'),
          _GorevTile(
            icon: PhosphorIconsRegular.medal,
            title: 'Başarı Dosyam',
            subtitle: 'Başarı ve üstün başarı belgeleri',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const BasariPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.graduationCap,
            title: 'Eğitim ve Sertifikalarım',
            subtitle: 'Kurs, sertifika ve diploma kayıtları',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const EgitimPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.chartLineUp,
            title: 'Kariyer özeti',
            subtitle: 'Tüm kariyer verilerinin özeti',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const KariyerHubPage())),
          ),
          const SizedBox(height: 18),
          const _SectionLabel('Görev takibi'),
          _GorevTile(
            icon: PhosphorIconsRegular.bookBookmark,
            title: 'Görev Günlüğüm',
            subtitle: 'Görev kaydı, takvim ve istatistik.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const GorevGunlukPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.target,
            title: 'Atış Takibim',
            subtitle: '4 dönem atış puanı.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const AtisTakipPage())),
          ),
          const SizedBox(height: 18),
          const _SectionLabel('Diğer'),
          _GorevTile(
            icon: PhosphorIconsRegular.calendarBlank,
            title: 'İzinlerim',
            subtitle: 'Yıllık, mazeret, refakat izni.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const IzinPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.receipt,
            title: 'O-1 giderleri',
            subtitle: 'Görev giderleri ve fişler.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const O1GiderPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.scales,
            title: 'Disiplinlerim',
            subtitle: 'Fiil rehberi ve savunma süreci.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const DisiplinRehberiPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.mapPinLine,
            title: 'Tayinim',
            subtitle: 'EGM hizmet puanı hesapla.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const GorevPuaniGirisPage())),
          ),
          _GorevTile(
            icon: PhosphorIconsRegular.house,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: PoliceColors.titleOnDark,
          fontWeight: FontWeight.w800,
          fontSize: 14.5,
        ),
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
          _chip('Eğitim',
              '${ozet.egitimStat.toplamEgitim + ozet.egitimStat.toplamSertifika}'),
          _chip('Görev', '${ozet.toplamGorev}'),
          _chip('Atış', '${ozet.atisTamamlanan}/4'),
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

class _GorevTile extends StatelessWidget {
  const _GorevTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PhosphorIcon(
                    icon,
                    color: PoliceColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.32,
                        ),
                      ),
                    ],
                  ),
                ),
                const PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  color: PoliceColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
