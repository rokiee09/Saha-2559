import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/theme/police_colors.dart';
import 'il_analiz_sablon_fields.dart';
import 'il_analiz_display.dart';
import 'il_analiz_models.dart';
import 'il_analiz_widgets.dart';
import 'konut_fiyatlari_widgets.dart';

class IlAnalizDetailPage extends StatelessWidget {
  const IlAnalizDetailPage({super.key, required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: PoliceColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: PoliceColors.navy,
          foregroundColor: PoliceColors.titleOnDark,
          title: Text(profil.ad),
          bottom: const TabBar(
            indicatorColor: PoliceColors.primaryBlue,
            labelColor: PoliceColors.titleOnDark,
            unselectedLabelColor: PoliceColors.textMuted,
            tabs: [
              Tab(text: 'Özet'),
              Tab(text: 'Detaylar'),
              Tab(text: 'İlçeler'),
              Tab(text: 'Güvenlik'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OzetTab(profil: profil),
            _DetaylarTab(profil: profil),
            _IlcelerTab(profil: profil),
            _GuvenlikTab(profil: profil),
          ],
        ),
      ),
    );
  }
}

class _OzetTab extends StatelessWidget {
  const _OzetTab({required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        IlHeroCard(profil: profil),
        if (ilMetinDolu(profil.ozetAi)) IlAiOzetCard(metin: profil.ozetAi!),
        ilBolumKartiSablon(
          title: 'Hızlı göstergeler',
          icon: PhosphorIconsRegular.gauge,
          accent: PoliceColors.primaryBlue,
          satirlar: ilHizliGostergelerSatirlar(profil),
        ),
      ],
    );
  }
}

class _DetaylarTab extends StatelessWidget {
  const _DetaylarTab({required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context) {
    final g = profil.genel;
    final e = profil.ekonomi;
    final s = profil.saglik;
    final ed = profil.egitim;
    final sy = profil.sosyal;
    final p = profil.polis;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ilBolumKartiSablon(
          title: 'Genel bilgiler',
          icon: PhosphorIconsRegular.mapTrifold,
          accent: PoliceColors.primaryBlue,
          kaynak: g.kaynak,
          satirlar: [
            ilMetrikZorunlu(PhosphorIconsRegular.users, 'Nüfus', formatIlNufusVeyaDash(g.nufus)),
            ilMetrikZorunlu(
              PhosphorIconsRegular.mapPin,
              'Yüzölçümü',
              g.yuzolcumuKm2 != null ? '${g.yuzolcumuKm2} km²' : kIlAnalizBosDash,
            ),
            ilMetrikZorunlu(
              PhosphorIconsRegular.buildings,
              'İlçe sayısı',
              formatIlSayiVeyaDash(g.ilceSayisi),
            ),
            ilMetrikZorunlu(
              PhosphorIconsRegular.chartLineUp,
              'Yaşam endeksi sırası (TÜİK)',
              formatIlYasamIndeksiSiraVeyaDash(g.yasamIndeksiSira, yil: g.yasamIndeksiYil),
            ),
            ilMetrikZorunlu(
              PhosphorIconsRegular.mountains,
              'Rakım',
              g.rakimM != null ? '${g.rakimM} m' : kIlAnalizBosDash,
            ),
            ilMetrikZorunlu(
              PhosphorIconsRegular.compass,
              'Bölge',
              formatIlMetinVeyaDash(profil.bolge),
            ),
            ilMetrikZorunlu(
              PhosphorIconsRegular.trendUp,
              'Kalkınmada öncelikli',
              formatIlEvetHayirVeyaDash(g.kalkinmadaOncelikli),
            ),
          ],
        ),
        ilBolumKartiSablon(
          title: 'Ekonomik durum',
          icon: PhosphorIconsRegular.currencyCircleDollar,
          accent: PoliceColors.gold,
          kaynak: e.kaynak,
          satirlar: [
            ilMetrikZorunlu(PhosphorIconsRegular.house, 'Ortalama kira', formatIlTlVeyaDash(e.ortalamaKiraTl)),
            ilMetrikZorunlu(PhosphorIconsRegular.tag, 'Konut satış (ort.)', formatIlTlVeyaDash(e.konutSatisOrtTl)),
            ilMetrikZorunlu(PhosphorIconsRegular.chartLineUp, 'SEGE düzeyi', formatIlMetinVeyaDash(e.segeDuzey)),
            ilMetrikZorunlu(PhosphorIconsRegular.chartBar, 'Sosyoekonomik sıra', formatIlSayiVeyaDash(e.sosyoekonomikSira)),
          ],
        ),
        ilBolumKartiSablon(
          title: 'Sağlık',
          icon: PhosphorIconsRegular.heart,
          accent: PoliceColors.saglikAccent,
          kaynak: s.kaynak,
          satirlar: [
            ilMetrikZorunlu(PhosphorIconsRegular.hospital, 'Devlet hastanesi', formatIlSayiVeyaDash(s.devletHastanesi)),
            ilMetrikZorunlu(PhosphorIconsRegular.stethoscope, 'Eğitim araştırma', formatIlSayiVeyaDash(s.egitimArastirma)),
            ilMetrikZorunlu(PhosphorIconsRegular.student, 'Üniversite hastanesi', formatIlSayiVeyaDash(s.universiteHastanesi)),
            ilMetrikZorunlu(PhosphorIconsRegular.building, 'Şehir hastanesi', formatIlBoolVeyaDash(s.sehirHastanesi)),
            ilMetrikZorunlu(PhosphorIconsRegular.firstAid, 'Özel hastane', formatIlSayiVeyaDash(s.ozelHastane)),
          ],
        ),
        ilBolumKartiSablon(
          title: 'Eğitim',
          icon: PhosphorIconsRegular.graduationCap,
          accent: PoliceColors.emeklilikAccent,
          kaynak: ed.kaynak,
          satirlar: [
            ilMetrikZorunlu(PhosphorIconsRegular.student, 'Üniversite', formatIlSayiVeyaDash(ed.universite)),
            ilMetrikZorunlu(PhosphorIconsRegular.atom, 'Fen lisesi', formatIlSayiVeyaDash(ed.fenLisesi)),
            ilMetrikZorunlu(PhosphorIconsRegular.book, 'Anadolu lisesi', formatIlSayiVeyaDash(ed.anadoluLisesi)),
            ilMetrikZorunlu(PhosphorIconsRegular.wrench, 'Meslek lisesi', formatIlSayiVeyaDash(ed.meslekLisesi)),
            ilMetrikZorunlu(PhosphorIconsRegular.graduationCap, 'Özel okul', formatIlSayiVeyaDash(ed.ozelOkul)),
          ],
        ),
        ilBolumKartiSablon(
          title: 'Sosyal yaşam',
          icon: PhosphorIconsRegular.city,
          accent: PoliceColors.primaryBlue,
          satirlar: [
            ilMetrikZorunlu(PhosphorIconsRegular.shoppingBag, 'AVM', formatIlSayiVeyaDash(sy.avm)),
            ilMetrikZorunlu(PhosphorIconsRegular.airplane, 'Havalimanı', formatIlSayiVeyaDash(sy.havalimani)),
            ilMetrikZorunlu(PhosphorIconsRegular.soccerBall, 'Süper Lig', formatIlBoolVeyaDash(sy.superLigTakimi)),
            ilMetrikZorunlu(PhosphorIconsRegular.barbell, 'Spor tesisleri', formatIlSayiVeyaDash(sy.sporTesisleri)),
            ilMetrikZorunlu(PhosphorIconsRegular.waves, 'Sahil', formatIlMetinVeyaDash(sy.sahil)),
            ilMetrikZorunlu(PhosphorIconsRegular.sun, 'Turizm', formatIlMetinVeyaDash(sy.turizm)),
          ],
        ),
        _IlcelerTab(profil: profil),
        ilBolumKartiSablon(
          title: 'Polis bilgileri',
          icon: PhosphorIconsRegular.shield,
          accent: PoliceColors.gold,
          kaynak: p.kaynak,
          satirlar: [
            ilMetrikZorunlu(PhosphorIconsRegular.star, 'Görev puanı', formatIlGorevPuaniVeyaDash(p.gorevPuani)),
            ilMetrikZorunlu(PhosphorIconsRegular.clock, 'Görev süresi (il)', formatIlYilVeyaDash(p.gorevSuresiYil)),
            ilMetrikZorunlu(PhosphorIconsRegular.buildings, 'Müdürlük', formatIlSayiVeyaDash(p.mudurluk)),
            ilMetrikZorunlu(PhosphorIconsRegular.shield, 'Amirlik', formatIlSayiVeyaDash(p.amirlik)),
            ilMetrikZorunlu(
              PhosphorIconsRegular.medal,
              'Tazminat derecesi',
              formatIlTazminatDereceVeyaDash(p.tazminatDerece),
            ),
            ilMetrikZorunlu(PhosphorIconsRegular.wallet, 'Ek ödeme', formatIlTlVeyaDash(p.ekTazminatTl)),
            ilMetrikZorunlu(PhosphorIconsRegular.house, 'Lojman sayısı', formatIlSayiVeyaDash(p.lojmanSayisi)),
            ilMetrikZorunlu(PhosphorIconsRegular.houseLine, 'Lojman durumu', formatIlMetinVeyaDash(p.lojmanDurumu)),
            ilMetrikZorunlu(PhosphorIconsRegular.hourglass, 'Lojman bekleme', formatIlMetinVeyaDash(p.lojmanBeklemeYil)),
            ilMetrikZorunlu(PhosphorIconsRegular.calendar, 'Çalışma sistemi', formatIlMetinVeyaDash(p.calismaSistemi)),
            ilMetrikZorunlu(PhosphorIconsRegular.clock, 'Mesai', formatIlMetinVeyaDash(p.mesai)),
            ilMetrikZorunlu(PhosphorIconsRegular.broadcast, 'Anons', formatIlMetinVeyaDash(p.anons)),
            ilMetrikZorunlu(PhosphorIconsRegular.listChecks, 'Uygulama', formatIlMetinVeyaDash(p.uygulama)),
            ilMetrikZorunlu(PhosphorIconsRegular.briefcase, 'İş yükü', formatIlMetinVeyaDash(p.isYuku)),
            ilMetrikZorunlu(PhosphorIconsRegular.scales, 'Suç türü (6136)', formatIlMetinVeyaDash(p.sucTuru)),
          ],
        ),
      ],
    );
  }
}

class _IlcelerTab extends StatelessWidget {
  const _IlcelerTab({required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context) {
    return IlIlcelerTabIcerik(profil: profil);
  }
}

class _GuvenlikTab extends StatelessWidget {
  const _GuvenlikTab({required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context) {
    final g = profil.guvenlik;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        IlSectionCard(
          title: 'Resmî güvenlik profili',
          icon: PhosphorIconsRegular.chartBar,
          accent: PoliceColors.primaryBlue,
          children: [
            if (g.gostergeler.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  kIlAnalizBosDash,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
              )
            else
              for (final o in g.gostergeler)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.etiket,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            o.deger,
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (o.egilim != null && o.egilim!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '· ${o.egilim}',
                              style: TextStyle(
                                color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
          ],
        ),
        if (ilMetinDolu(g.dipnot))
          Text(
            g.dipnot!,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.75),
              fontSize: 11,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
