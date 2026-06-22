import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/theme/police_colors.dart';
import 'il_analiz_display.dart';
import 'il_analiz_models.dart';
import 'il_analiz_widgets.dart';
import 'konut_fiyatlari_data.dart';

/// Detaylar sekmesi — il geneli özet, ilçe konut kartları ve veri notu.
class YasamMaliyetiBolumu extends ConsumerWidget {
  const YasamMaliyetiBolumu({super.key, required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(konutFiyatlariProvider);
    return async.when(
      data: (katalog) => _buildBolum(katalog),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBolum(KonutFiyatlariKatalog katalog) {
    final konutProfil = katalog.profil(profil.id);
    if (konutProfil == null) return const SizedBox.shrink();

    final children = <Widget>[
      IlSectionCard(
        title: 'Yaşam Maliyeti',
        icon: PhosphorIconsRegular.houseLine,
        accent: PoliceColors.gold,
        children: [
          IlMetricRow(
            icon: PhosphorIconsRegular.house,
            label: 'Ortalama kira',
            value: formatIlTlVeyaDash(konutProfil.provinceAverage.averageRent),
          ),
          IlMetricRow(
            icon: PhosphorIconsRegular.ruler,
            label: 'Ortalama m² kira',
            value: formatIlKonutM2Fiyat(konutProfil.provinceAverage.rentPerSqm),
          ),
          IlMetricRow(
            icon: PhosphorIconsRegular.tag,
            label: 'Ortalama satılık m² fiyatı',
            value: formatIlKonutM2Fiyat(konutProfil.provinceAverage.salePerSqm),
          ),
          IlMetricRow(
            icon: PhosphorIconsRegular.hourglass,
            label: 'Amortisman yılı',
            value: konutProfil.provinceAverage.amortizationYears != null
                ? '${konutProfil.provinceAverage.amortizationYears} yıl'
                : kIlAnalizBosDash,
          ),
          IlMetricRow(
            icon: PhosphorIconsRegular.calendar,
            label: 'Veri güncelleme tarihi',
            value: formatIlKonutGuncellemeTarihi(katalog.lastUpdated),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ...buildKonutIlceKartlari(profil: profil, konutProfil: konutProfil),
      _VeriNotuKarti(metin: konutVeriNotu(katalog)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// İlçeler sekmesi — görev profili; konut verisi varsa bantlar kartlara eklenir.
class IlIlcelerTabIcerik extends ConsumerWidget {
  const IlIlcelerTabIcerik({super.key, required this.profil});

  final IlAnalizProfil profil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(konutFiyatlariProvider);
    return async.when(
      data: (katalog) => _buildIcerik(katalog),
      loading: () => _buildIcerik(null),
      error: (_, __) => _buildIcerik(null),
    );
  }

  Widget _buildIcerik(KonutFiyatlariKatalog? katalog) {
    final konutProfil = katalog?.profil(profil.id);

    if (profil.ilceler.isEmpty && konutProfil == null) {
      return Center(
        child: Text(
          'İlçe analizi henüz eklenmedi.',
          style: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
        ),
      );
    }

    final children = <Widget>[
      Text(
        konutProfil != null
            ? 'İlçe nüfusu, görev profili ve kira/konut fiyat bantları. İl özeti için Detaylar sekmesine bakın.'
            : 'İlçe nüfusu ve varsa profil puanları. İş yükü yüksek = daha yoğun tempo.',
        style: TextStyle(
          color: PoliceColors.textMuted.withValues(alpha: 0.85),
          fontSize: 12,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (konutProfil != null) {
      children.addAll(
        buildKonutIlceKartlari(profil: profil, konutProfil: konutProfil),
      );
    } else {
      for (final ilce in profil.ilceler) {
        children.add(IlceMiniCard(ilce: ilce));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: children,
    );
  }
}

List<Widget> buildKonutIlceKartlari({
  required IlAnalizProfil profil,
  required IlKonutFiyatProfil konutProfil,
}) {
  final konutHarita = konutIlceHaritasi(konutProfil);
  final kullanilanAnalizAd = <String>{};
  final kartlar = <Widget>[];

  for (final konut in konutProfil.districtHousing) {
    final analiz = ilceAnalizEslestir(konut.district, profil.ilceler);
    if (analiz != null) kullanilanAnalizAd.add(analiz.ad);
    final ilce = analiz ?? IlceAnaliz(ad: konut.district);
    kartlar.add(_ilceKarti(
      ilce: ilce,
      konut: konut,
      standartGorunum: true,
    ));
  }
  for (final ilce in profil.ilceler) {
    if (kullanilanAnalizAd.contains(ilce.ad)) continue;
    final konut = konutForIlceAdi(ilce.ad, konutHarita);
    kartlar.add(_ilceKarti(
      ilce: ilce,
      konut: konut,
      standartGorunum: true,
    ));
  }
  return kartlar;
}

Widget _ilceKarti({
  required IlceAnaliz ilce,
  required IlceKonutFiyat? konut,
  required bool standartGorunum,
}) {
  final ortKira = ilce.kiraTl ?? (konut != null ? konutOrtalamaKira(konut) : null);
  return IlceMiniCard(
    ilce: ilce,
    standartGorunum: standartGorunum,
    ortKiraTl: ortKira,
    sagEtiket:
        konut?.level != null ? KonutSeviyeChip(seviye: konut!.level!) : null,
    altBolum: konut != null ? _konutAltBolum(konut) : null,
  );
}

Widget _konutAltBolum(IlceKonutFiyat konut) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 10),
      Divider(
        height: 1,
        color: PoliceColors.mevzuatListBorder.withValues(alpha: 0.45),
      ),
      const SizedBox(height: 8),
      IlceKonutBandSatirlari(konut: konut),
    ],
  );
}

class IlceKonutBandSatirlari extends StatelessWidget {
  const IlceKonutBandSatirlari({super.key, required this.konut});

  final IlceKonutFiyat konut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bandSatir(
          PhosphorIconsRegular.house,
          'Kira bandı',
          formatIlKiraBand(konut.rentMin, konut.rentMax),
        ),
        const SizedBox(height: 4),
        _bandSatir(
          PhosphorIconsRegular.buildings,
          'Satılık konut',
          formatIlKonutSatisBand(konut.saleMin, konut.saleMax),
        ),
      ],
    );
  }

  Widget _bandSatir(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: PoliceColors.textMuted.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 12,
                height: 1.35,
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class KonutSeviyeChip extends StatelessWidget {
  const KonutSeviyeChip({super.key, required this.seviye});

  final KonutFiyatSeviye seviye;

  @override
  Widget build(BuildContext context) {
    final color = konutSeviyeRengi(seviye);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        konutSeviyeEtiket(seviye),
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VeriNotuKarti extends StatelessWidget {
  const _VeriNotuKarti({required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDarkElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: PoliceColors.mevzuatListBorder.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIconsRegular.info,
            size: 16,
            color: PoliceColors.textMuted.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veri notu',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metin,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.85),
                    fontSize: 11,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color konutSeviyeRengi(KonutFiyatSeviye seviye) {
  switch (seviye) {
    case KonutFiyatSeviye.high:
      return PoliceColors.emeklilikSliceRed;
    case KonutFiyatSeviye.medium:
      return const Color(0xFFF59E0B);
    case KonutFiyatSeviye.low:
      return const Color(0xFF22C55E);
    case KonutFiyatSeviye.seasonal:
      return PoliceColors.primaryBlue;
    case KonutFiyatSeviye.limitedData:
      return PoliceColors.textMuted;
  }
}

String konutSeviyeEtiket(KonutFiyatSeviye seviye) {
  switch (seviye) {
    case KonutFiyatSeviye.high:
      return 'Yüksek';
    case KonutFiyatSeviye.medium:
      return 'Orta';
    case KonutFiyatSeviye.low:
      return 'Düşük';
    case KonutFiyatSeviye.seasonal:
      return 'Mevsimsel';
    case KonutFiyatSeviye.limitedData:
      return 'Sınırlı veri';
  }
}

String formatIlKonutGuncellemeTarihi(String? raw) {
  if (raw == null || raw.trim().isEmpty) return kIlAnalizBosDash;
  final parts = raw.trim().split('-');
  if (parts.length == 2) {
    final yil = parts[0];
    final ay = int.tryParse(parts[1]);
    const aylar = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    if (ay != null && ay >= 1 && ay <= 12) return '${aylar[ay]} $yil';
  }
  return raw;
}

String formatIlKiraBand(int? min, int? max) {
  if (min == null && max == null) return kIlAnalizBosDash;
  if (min != null && max != null) {
    return '${formatIlNufus(min)} – ${formatIlNufus(max)} TL';
  }
  return formatIlTlVeyaDash(min ?? max);
}

String formatIlKonutSatisBand(int? min, int? max) {
  if (min == null && max == null) return kIlAnalizBosDash;
  if (min != null && max != null) {
    return '${_konutMilyon(min)} – ${_konutMilyon(max)}';
  }
  return _konutMilyon(min ?? max!);
}

String formatIlKonutM2Fiyat(int? v) {
  if (v == null) return kIlAnalizBosDash;
  return '${formatIlNufus(v)} ₺/m²';
}

String _konutMilyon(int v) {
  if (v >= 1000000) {
    final m = v / 1000000;
    if (v % 1000000 == 0) return '${m.toInt()} milyon ₺';
    final s = m.toStringAsFixed(1).replaceAll('.', ',');
    return '$s milyon ₺';
  }
  return '${formatIlNufus(v)} ₺';
}
