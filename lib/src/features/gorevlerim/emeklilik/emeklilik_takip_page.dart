import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../../common/widgets/police_module_icon.dart';
import '../../home/root_drawer_scope.dart';
import '../kariyer/kariyer_profil_provider.dart';
import '../kariyer/profil/profil_page.dart';
import 'emeklilik_calculator.dart';
import 'emeklilik_provider.dart';
import 'widgets/emeklilik_donut_chart.dart';

class EmeklilikTakipPage extends ConsumerWidget {
  const EmeklilikTakipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(kariyerProfilProvider);
    final durum = ref.watch(emeklilikDurumProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Emeklilik Takibi',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: profilAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Profil yüklenemedi.')),
        data: (profil) {
          if (durum == null) {
            return _EksikProfil(
              onProfil: () => Navigator.of(context).push(
                fadeRoute(const ProfilPage()),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Text(
                '20 yıl zorunlu hizmet ve rütbeye göre yaş haddi birlikte '
                'değerlendirilir. Hangi koşul önce dolarsa o tarih öne çıkar.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emeklilikYasHaddiAciklama(profil.rutbeId),
                style: TextStyle(
                  color: PoliceColors.emeklilikAccent.withValues(alpha: 0.95),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _GrafikKart(
                      baslik: 'Zorunlu hizmet',
                      altBaslik: '20 yıl',
                      renk: PoliceColors.primaryBlue,
                      ilerleme: durum.zorunluHizmet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GrafikKart(
                      baslik: 'Yaş haddi',
                      altBaslik: '${durum.yasHaddiYas} yaş',
                      renk: PoliceColors.emeklilikAccent,
                      ilerleme: durum.yasHaddi,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _OzetKart(durum: durum),
              const SizedBox(height: 14),
              _DetayKart(
                baslik: 'Zorunlu hizmet (20 yıl)',
                renk: PoliceColors.primaryBlue,
                meslekGiris: durum.zorunluHizmet.baslangic,
                bitis: durum.zorunluHizmet.bitis,
                ilerleme: durum.zorunluHizmet,
              ),
              const SizedBox(height: 10),
              _DetayKart(
                baslik: 'Yaş haddi (${durum.yasHaddiYas})',
                renk: PoliceColors.emeklilikAccent,
                meslekGiris: durum.yasHaddi.baslangic,
                bitis: durum.yasHaddi.bitis,
                ilerleme: durum.yasHaddi,
                baslangicEtiket: 'Doğum tarihi',
              ),
              const SizedBox(height: 16),
              Text(
                'Bu ekran yalnızca kişisel takip içindir; bağlayıcı emeklilik '
                'hesabı veya resmî özlük işlemi değildir. Kesin tarih ve hak '
                'Personel Dairesi / özlük kayıtlarına göre belirlenir.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.75),
                  fontSize: 11.5,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EksikProfil extends StatelessWidget {
  const _EksikProfil({required this.onProfil});

  final VoidCallback onProfil;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PoliceModuleIconBadge(style: PoliceModules.emeklilik, size: 32),
          const SizedBox(height: 16),
          const Text(
            'Hesap için Profilim’de şunlar gerekli:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '• Rütbe\n• Mesleğe giriş tarihi\n• Doğum tarihi',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onProfil,
            style: FilledButton.styleFrom(
              backgroundColor: PoliceColors.primaryBlue,
            ),
            child: const Text('Profili tamamla'),
          ),
        ],
      ),
    );
  }
}

class _GrafikKart extends StatelessWidget {
  const _GrafikKart({
    required this.baslik,
    required this.altBaslik,
    required this.renk,
    required this.ilerleme,
  });

  final String baslik;
  final String altBaslik;
  final Color renk;
  final EmeklilikIlerleme ilerleme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            baslik,
            style: TextStyle(
              color: renk,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          Text(
            altBaslik,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          EmeklilikDonutChart(
            progress: ilerleme.yuzde / 100,
            color: renk,
            size: 110,
            strokeWidth: 12,
            centerLabel: formatYuzde(ilerleme.yuzde),
            centerSubLabel: ilerleme.tamamlandi ? 'Doldu' : 'tamam',
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              ilerleme.tamamlandi
                  ? 'Süre tamamlandı'
                  : ilerleme.kalan.kalanMetin(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OzetKart extends StatelessWidget {
  const _OzetKart({required this.durum});

  final EmeklilikDurum durum;

  @override
  Widget build(BuildContext context) {
    final once = durum.onceBitecek;
    final etiket = once == durum.zorunluHizmet
        ? 'Zorunlu 20 yıl önce doluyor'
        : 'Yaş haddi önce doluyor';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PoliceColors.navy.withValues(alpha: 0.9),
            PoliceColors.primaryBlue.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiket,
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatTrTarih(durum.emeklilikTarihi),
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            durum.rutbeLabel,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetayKart extends StatelessWidget {
  const _DetayKart({
    required this.baslik,
    required this.renk,
    required this.meslekGiris,
    required this.bitis,
    required this.ilerleme,
    this.baslangicEtiket = 'Mesleğe giriş',
  });

  final String baslik;
  final Color renk;
  final DateTime meslekGiris;
  final DateTime bitis;
  final EmeklilikIlerleme ilerleme;
  final String baslangicEtiket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            baslik,
            style: TextStyle(
              color: renk,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _tarihSatir(baslangicEtiket, formatTrTarih(meslekGiris)),
          _tarihSatir('Bitiş tarihi', formatTrTarih(bitis)),
          const Divider(height: 20, color: PoliceColors.outlineMuted),
          _tarihSatir('Tamamlanan', formatYuzde(ilerleme.yuzde)),
          _tarihSatir(
            'Kalan',
            ilerleme.tamamlandi ? '—' : ilerleme.kalan.kalanMetin(),
          ),
        ],
      ),
    );
  }

  Widget _tarihSatir(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              etiket,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.85),
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              deger,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
