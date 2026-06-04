import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/theme/saha_module_theme.dart';
import '../../common/widgets/module_section_header.dart';
import '../../common/widgets/police_module_icon.dart';
import '../../common/widgets/police_module_list_tile.dart';
import '../../common/widgets/saha_module_card.dart';
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
import 'gorev_puanlari/gorev_puan_hub_page.dart';
import 'harcirah/harcirah_hesaplama_page.dart';
import 'dilekce/dilekce_merkezi_page.dart';
import 'emsal/emsal_rehberi_page.dart';
import 'idari_para_ceza/idari_para_ceza_page.dart';
import 'trafik/trafik_rehberi_page.dart';
import 'ingilizce/polis_ingilizce_page.dart';
import 'kriz/kriz_rehberi_page.dart';
import 'lojman/lojman_puani_page.dart';
import 'sifre/kayitli_sifreler_page.dart';
import 'sifre_uretici_page.dart';
import 'telsiz_kodlari_page.dart';
import 'tutanak/tutanak_merkezi_page.dart';

/// Araçlar: hesaplayıcılar, kişisel kayıtlar, tutanak/operasyon ve referans.
class AraclarPage extends StatelessWidget {
  const AraclarPage({super.key});

  static const _tutanakOperasyonIds = {
    'tutanak',
    'arama_karari',
    'gorev_gunlugu',
    'atis_takip',
  };

  static const _kisiselKayitIds = {
    'notlar',
    'o1_gider',
    'izin',
  };

  @override
  Widget build(BuildContext context) {
    final tutanakCats = SahaCategoryDef.all
        .where((c) => _tutanakOperasyonIds.contains(c.id))
        .toList();
    final kisiselCats = SahaCategoryDef.all
        .where((c) => _kisiselKayitIds.contains(c.id))
        .toList();

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
          const ModuleSectionHeader(
            'Hesaplayıcılar',
            area: SahaModuleArea.araclar,
          ),
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
            title: 'Görev puanı hesaplama',
            subtitle:
                '2025 / 2026 cetveli, günlük puanlar ve hizmet puanı hesabı.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const GorevPuanHubPage())),
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
          const ModuleSectionHeader(
            'Kişisel kayıtlar',
            subtitle: 'Yalnızca bu telefonda tutulur; buluta çıkmaz.',
            topGap: 18,
          ),
          _SahaCategoryGrid(categories: kisiselCats),
          const ModuleSectionHeader(
            'Tutanak ve operasyon',
            subtitle: 'Görev kaydı, tutanak taslağı ve arama rehberi.',
            topGap: 18,
          ),
          _SahaCategoryGrid(categories: tutanakCats),
          const ModuleSectionHeader(
            'Görev içeriği',
            subtitle: 'Dilekçe taslağı, emsal özet ve trafik kontrol listesi.',
            topGap: 18,
            area: SahaModuleArea.araclar,
          ),
          PoliceModuleListTile(
            style: PoliceModules.disiplin,
            title: 'Dilekçe Merkezi',
            subtitle: 'İzin, refakat ve disiplin savunması taslakları.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const DilekceMerkeziPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.rehber,
            title: 'Emsal özetleri',
            subtitle: 'Anonim uygulama özetleri ve kontrol listeleri.',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const EmsalRehberiPage())),
          ),
          PoliceModuleListTile(
            style: PoliceModules.idariParaCeza,
            title: 'Trafik rehberi',
            subtitle: 'Kontrol, alkol, hız ve kaza adımları (offline).',
            onTap: () =>
                Navigator.of(context).push(fadeRoute(const TrafikRehberiPage())),
          ),
          const ModuleSectionHeader(
            'Referans',
            subtitle: 'Dil, telsiz, teşkilat ve kültür.',
            topGap: 18,
            area: SahaModuleArea.araclar,
          ),
          PoliceModuleListTile(
            style: PoliceModules.idariParaCeza,
            title: 'İdari Para Cezaları',
            subtitle: '2026 kabahat cezaları — arama, filtre ve favoriler.',
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const IdariParaCezaPage())),
          ),
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

class _SahaCategoryGrid extends StatelessWidget {
  const _SahaCategoryGrid({required this.categories});

  final List<SahaCategoryDef> categories;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w < 380 ? 3 : 4;
    final aspect = cols == 3 ? 0.94 : 0.88;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: aspect,
      children: [
        for (final cat in categories)
          SahaModuleCard.compact(
            style: PoliceModules.forSahaCategory(cat.id),
            title: cat.gridTitle ?? cat.title,
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
    );
  }
}
