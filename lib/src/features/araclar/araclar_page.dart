import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/police_module_icon.dart';
import '../../common/widgets/police_module_list_tile.dart';
import '../gorevlerim/atis/atis_takip_page.dart';
import '../gorevlerim/gunluk/gorev_gunluk_page.dart';
import '../gorevlerim/izin/izin_takip_page.dart';
import '../haklar/maas_hesaplama_page.dart';
import '../haklar/vardiya/vardiya_hesaplama_page.dart';
import '../home/root_drawer_scope.dart';
import '../kultur/kultur_page.dart';
import '../saha/saha_categories.dart';
import '../saha/saha_category_page.dart';
import '../teskilat/teskilat_page.dart';
import 'arama/arama_rehberi_page.dart';
import 'gider/o1_gider_page.dart';
import 'gorev_puanlari/gorev_puani_giris_page.dart';
import 'gorev_puanlari/gorev_puanlari_page.dart';
import 'harcirah/harcirah_hesaplama_page.dart';
import 'ingilizce/polis_ingilizce_page.dart';
import 'kriz/kriz_rehberi_page.dart';
import 'lojman/lojman_puani_page.dart';
import 'sifre/kayitli_sifreler_page.dart';
import 'sifre_uretici_page.dart';
import 'telsiz_kodlari_page.dart';
import 'tutanak/tutanak_merkezi_page.dart';

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
          PoliceModuleListTile(
            style: PoliceModules.vardiya,
            title: 'Vardiyam',
            subtitle: '10 vardiya türü; seçim cihazda saklanır.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const VardiyaHesaplamaPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.maas,
            title: 'Maaşım',
            subtitle: 'Katsayıya göre tahmini; bağlayıcı değildir.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const MaasHesaplamaPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.lojman,
            title: 'Lojman puanı hesaplama',
            subtitle: 'Aile, hizmet, bekleme ve konut bilgilerine göre puan.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const LojmanPuaniPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.harcirah,
            title: 'Yol harcırah hesaplama',
            subtitle: 'İller arası km, eş/çocuk ve örnek rapor.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const HarcirahHesaplamaPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.tayin,
            title: 'Görev puanları cetveli',
            subtitle: '2025 il / ilçe günlük görev yeri puanları.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const GorevPuanlariPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.tayin,
            title: 'Görev puanı hesapla',
            subtitle: 'EGM hizmet puanı — görev yerleri ve süreleri.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const GorevPuaniGirisPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.sifre,
            title: 'Şifre üretici',
            subtitle: 'Cihazda güçlü, rastgele şifre üret veya kasaya kaydet.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const SifreUreticiPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.sifreKasa,
            title: 'Kayıtlı şifreler',
            subtitle: 'Sisteme/bankaya bağlı şifre kasan (yalnızca cihazda).',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const KayitliSifrelerPage())),
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
                        'tutanak' => const TutanakMerkeziPage(),
                        'arama_karari' => const AramaRehberiPage(),
                        'gorev_gunlugu' => const GorevGunlukPage(),
                        'atis_takip' => const AtisTakipPage(),
                        _ => SahaCategoryPage(categoryId: cat.id),
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Saha rehberleri'),
          PoliceModuleListTile(
            style: PoliceModules.ingilizce,
            title: 'Polis İngilizcesi',
            subtitle: 'Durdurma, kimlik, trafik ve yardım kalıpları (offline).',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const PolisIngilizcePage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.kriz,
            title: 'Kriz rehberi',
            subtitle: 'Kritik olaylarda adım adım kontrol listesi.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const KrizRehberiPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.telsiz,
            title: 'Telsiz kodları',
            subtitle: '33-10, protokol ve birim çağrı kodlarını hızlı ara.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const TelsizKodlariPage())),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Teşkilat & Kültür'),
          PoliceModuleListTile(
            style: PoliceModules.teskilat,
            title: 'Teşkilat',
            subtitle: 'Yapı, birimler ve il listesi.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const TeskilatPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.kultur,
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
              PoliceModuleIconBadge(
                style: PoliceModules.forSahaCategory(category.id),
                size: 24,
                padding: 8,
                borderRadius: 10,
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
