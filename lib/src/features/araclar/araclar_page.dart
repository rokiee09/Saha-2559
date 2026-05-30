import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../gorevlerim/izin/izin_takip_page.dart';
import '../haklar/maas_hesaplama_page.dart';
import '../haklar/vardiya/vardiya_hesaplama_page.dart';
import '../home/root_drawer_scope.dart';
import '../kultur/kultur_page.dart';
import '../saha/saha_categories.dart';
import '../saha/saha_category_page.dart';
import '../teskilat/teskilat_page.dart';
import 'gider/o1_gider_page.dart';
import 'ingilizce/polis_ingilizce_page.dart';
import 'kriz/kriz_rehberi_page.dart';
import 'sifre/kayitli_sifreler_page.dart';
import 'sifre_uretici_page.dart';
import 'telsiz_kodlari_page.dart';
import 'tutanak/tutanak_page.dart';

/// Araçlar: hesaplayıcılar, yerel saha defteri ve teşkilat/kültür bilgisi
/// tek bir merkezde. Polisin "işime yarayan araçlar" mantığına göre gruplanır.
class AraclarPage extends StatelessWidget {
  const AraclarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Araçlar',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const _SectionTitle('Hesaplayıcılar'),
          _ToolTile(
            icon: PhosphorIconsRegular.calendarCheck,
            title: 'Vardiya hesaplama',
            subtitle: '10 vardiya türü; seçim cihazda saklanır.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const VardiyaHesaplamaPage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.calculator,
            title: 'Maaş hesaplama',
            subtitle: 'Katsayıya göre tahmini; bağlayıcı değildir.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const MaasHesaplamaPage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.password,
            title: 'Şifre üretici',
            subtitle: 'Cihazda güçlü, rastgele şifre üret veya kasaya kaydet.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const SifreUreticiPage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.vault,
            title: 'Kayıtlı şifreler',
            subtitle: 'Sisteme/bankaya bağlı şifre kasan (yalnızca cihazda).',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const KayitliSifrelerPage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.clipboardText,
            title: 'Tutanak asistanı',
            subtitle: 'Şablonu doldur, taslak metin üret ve kaydet.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const TutanakPage())),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Yerel saha defteri'),
          Text(
            'Yalnızca bu telefonda tutulur; buluta çıkmaz.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [
              for (final cat in SahaCategoryDef.all)
                _SahaTile(
                  category: cat,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => switch (cat.id) {
                        'izin' => const IzinTakipPage(),
                        'o1_gider' => const O1GiderPage(),
                        'telsiz' => const TelsizKodlariPage(),
                        _ => SahaCategoryPage(categoryId: cat.id),
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Saha rehberleri'),
          _ToolTile(
            icon: PhosphorIconsRegular.translate,
            title: 'Polis İngilizcesi',
            subtitle: 'Durdurma, kimlik, trafik ve yardım kalıpları (offline).',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const PolisIngilizcePage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.lifebuoy,
            title: 'Kriz rehberi',
            subtitle: 'Kritik olaylarda adım adım kontrol listesi.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const KrizRehberiPage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.broadcast,
            title: 'Telsiz kodları',
            subtitle: '33-10, protokol ve birim çağrı kodlarını hızlı ara.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const TelsizKodlariPage())),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Teşkilat & Kültür'),
          _ToolTile(
            icon: PhosphorIconsRegular.buildings,
            title: 'Teşkilat',
            subtitle: 'Yapı, birimler ve il listesi.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const TeskilatPage())),
          ),
          _ToolTile(
            icon: PhosphorIconsRegular.palette,
            title: 'Kültür',
            subtitle: 'Tarih, şehitler, tören ve önemli günler.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const KulturPage())),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
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
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
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

class _SahaTile extends StatelessWidget {
  const _SahaTile({required this.category, required this.onTap});

  final SahaCategoryDef category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.25),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                category.icon,
                color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
