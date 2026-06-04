import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'il_analiz_display.dart';
import 'il_analiz_models.dart';
import 'il_analiz_widgets.dart';

/// Tüm illerde aynı sıra ve alanlar — veri yoksa [kIlAnalizBosDash].
List<IlMetricRow> ilHizliGostergelerSatirlar(IlAnalizProfil p) {
  final g = p.genel;
  final e = p.ekonomi;
  final s = p.saglik;
  final ed = p.egitim;
  final sy = p.sosyal;
  final pol = p.polis;

  return [
    ilMetrikZorunlu(
      PhosphorIconsRegular.users,
      'Nüfus',
      formatIlNufusVeyaDash(g.nufus),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.chartLineUp,
      'Yaşam endeksi (TÜİK)',
      formatIlYasamIndeksiSiraVeyaDash(g.yasamIndeksiSira, yil: g.yasamIndeksiYil),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.star,
      'Görev puanı',
      formatIlGorevPuaniVeyaDash(pol.gorevPuani),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.medal,
      'Tazminat derecesi',
      formatIlTazminatDereceVeyaDash(pol.tazminatDerece),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.wallet,
      'Ek ödeme',
      formatIlTlVeyaDash(pol.ekTazminatTl),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.house,
      'Ortalama kira',
      formatIlTlVeyaDash(e.ortalamaKiraTl),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.tag,
      'Satılık konut (ort.)',
      formatIlTlVeyaDash(e.konutSatisOrtTl),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.hospital,
      'Devlet hastanesi',
      formatIlSayiVeyaDash(s.devletHastanesi),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.graduationCap,
      'Üniversite',
      formatIlSayiVeyaDash(ed.universite),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.shoppingBag,
      'AVM',
      formatIlSayiVeyaDash(sy.avm),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.airplane,
      'Havalimanı',
      formatIlSayiVeyaDash(sy.havalimani),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.sun,
      'Turizm',
      formatIlMetinVeyaDash(sy.turizm),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.briefcase,
      'İş yükü (özet)',
      formatIlMetinVeyaDash(pol.isYuku),
    ),
    ilMetrikZorunlu(
      PhosphorIconsRegular.buildings,
      'Lojman',
      formatIlMetinVeyaDash(pol.lojmanDurumu),
    ),
  ];
}

/// Liste kartı sağ rozeti — anlamlı etiket + değer (TÜİK sırası öncelikli).
class IlListeRozet {
  const IlListeRozet({required this.etiket, required this.deger});

  final String etiket;
  final String deger;
}

IlListeRozet? ilListeRozetFromProfil(IlAnalizProfil p) {
  final sira = p.genel.yasamIndeksiSira;
  if (sira != null) {
    final yil = p.genel.yasamIndeksiYil;
    final y = yil != null ? ' ($yil)' : '';
    return IlListeRozet(etiket: 'TÜİK yaşam', deger: '$sira/81$y');
  }
  final profilSkor = ilGenelSkor(p.puanlar);
  if (profilSkor != null) {
    return IlListeRozet(etiket: 'Profil skoru', deger: '$profilSkor');
  }
  return null;
}
