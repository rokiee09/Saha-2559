/// Yol harcırahı hesaplama (6245 sayılı Kanun özet modeli; bağlayıcı değildir).
library;

import '../../gorevlerim/izin/il_mesafe.dart';

/// Eşin çalışma durumu (bekar değilse).
enum HarcirahEsDurumu {
  calismiyor,
  memur,
  ozelSektor,
}

class HarcirahGirdi {
  const HarcirahGirdi({
    required this.nereden,
    required this.nereye,
    required this.mesafeKm,
    required this.bekar,
    required this.esDurumu,
    required this.cocukSayisi,
    required this.gunlukUcret,
    required this.otobusUcreti,
  });

  final String nereden;
  final String nereye;
  final int mesafeKm;
  final bool bekar;
  final HarcirahEsDurumu esDurumu;
  final int cocukSayisi;
  final double gunlukUcret;
  final double otobusUcreti;
}

class HarcirahSatir {
  const HarcirahSatir({
    required this.aciklama,
    required this.deger,
    this.katSayisi,
    this.mesafeKm,
    required this.sonuc,
  });

  final String aciklama;
  final double deger;
  final double? katSayisi;
  final int? mesafeKm;
  final double sonuc;
}

class HarcirahSonuc {
  const HarcirahSonuc({
    required this.satirlar,
    required this.toplam,
    required this.gunSayisi,
    required this.cocukGunSayisi,
    required this.mesafeKm,
  });

  final List<HarcirahSatir> satirlar;
  final double toplam;
  final int gunSayisi;
  final int cocukGunSayisi;
  final int mesafeKm;
}

/// Örnek rapor / varsayılan günlük harcırah (2026 örnek; kurum duyurusu esas).
const double kHarcirahOrnekGunlukUcret = 850;

/// Kendisi ve eş (memur değil) mesafe katsayısı.
const double kHarcirahMesafeKatsayi = 0.05;

/// Eş memur ise mesafe katsayısı (6245 s.45 — yarı).
const double kHarcirahEsMemurMesafeKatsayi = 0.025;

/// Günlük gün sayısı: mesafe / 60 (Polis 360 örnek modeli; Denizli–Diyarbakır 1280→21).
int harcirahGunSayisi(int mesafeKm) {
  if (mesafeKm <= 0) return 0;
  return (mesafeKm / 60).round().clamp(1, 999);
}

int harcirahCocukGunSayisi(int gunSayisi) {
  if (gunSayisi <= 0) return 0;
  return (gunSayisi / 2).round().clamp(1, 999);
}

/// İl merkezleri arası tahmini km — yol izni ile aynı model (KGM cetveline yakın).
int harcirahMesafeKmTahmin(String nereden, String nereye) =>
    ilMesafeKm(nereden, nereye);

HarcirahSonuc hesaplaHarcirah(HarcirahGirdi g) {
  final km = g.mesafeKm;
  final gun = harcirahGunSayisi(km);
  final cocukGun = harcirahCocukGunSayisi(gun);
  final u = g.gunlukUcret;
  final satirlar = <HarcirahSatir>[];

  void ekle({
    required String aciklama,
    required double deger,
    double? kat,
    int? mesafe,
    required double sonuc,
  }) {
    satirlar.add(HarcirahSatir(
      aciklama: aciklama,
      deger: deger,
      katSayisi: kat,
      mesafeKm: mesafe,
      sonuc: sonuc,
    ));
  }

  if (km > 0 && gun > 0) {
    ekle(
      aciklama: 'Kendisi için (Günlük Harcırah ücreti)',
      deger: u,
      kat: gun.toDouble(),
      sonuc: u * gun,
    );
    ekle(
      aciklama: 'Kendisi için (Mesafe Harcırah ücreti)',
      deger: u,
      kat: kHarcirahMesafeKatsayi,
      mesafe: km,
      sonuc: u * kHarcirahMesafeKatsayi * km,
    );
  }
  if (g.otobusUcreti > 0) {
    ekle(
      aciklama: 'Kendisi için (Otobüs Ücreti)',
      deger: g.otobusUcreti,
      sonuc: g.otobusUcreti,
    );
  }

  if (!g.bekar && km > 0 && gun > 0) {
    final esMesafeKat = g.esDurumu == HarcirahEsDurumu.memur
        ? kHarcirahEsMemurMesafeKatsayi
        : kHarcirahMesafeKatsayi;
    final esEtiket = switch (g.esDurumu) {
      HarcirahEsDurumu.memur => 'Eşi için (Çalışan Memur)',
      HarcirahEsDurumu.ozelSektor => 'Eşi için (Özel Sektör)',
      HarcirahEsDurumu.calismiyor => 'Eşi için (Çalışmıyor)',
    };

    ekle(
      aciklama: '$esEtiket — Günlük Harcırah',
      deger: u,
      kat: gun.toDouble(),
      sonuc: u * gun,
    );
    ekle(
      aciklama: '$esEtiket — Mesafe Harcırah',
      deger: u,
      kat: esMesafeKat,
      mesafe: km,
      sonuc: u * esMesafeKat * km,
    );
    if (g.otobusUcreti > 0) {
      ekle(
        aciklama: '$esEtiket — Otobüs Ücreti',
        deger: g.otobusUcreti,
        sonuc: g.otobusUcreti,
      );
    }
  }

  for (var i = 1; i <= g.cocukSayisi; i++) {
    if (gun > 0 && cocukGun > 0) {
      ekle(
        aciklama: 'Çocuk $i — Günlük Harcırah ücreti',
        deger: u,
        kat: cocukGun.toDouble(),
        sonuc: u * cocukGun,
      );
    }
    if (g.otobusUcreti > 0) {
      ekle(
        aciklama: 'Çocuk $i — Otobüs Ücreti',
        deger: g.otobusUcreti,
        sonuc: g.otobusUcreti,
      );
    }
  }

  final toplam = satirlar.fold<double>(0, (s, r) => s + r.sonuc);

  return HarcirahSonuc(
    satirlar: satirlar,
    toplam: toplam,
    gunSayisi: gun,
    cocukGunSayisi: cocukGun,
    mesafeKm: km,
  );
}

/// Örnek rapor girdisi (Denizli → Diyarbakır, KGM ~1243 km).
HarcirahGirdi get ornekHarcirahGirdi {
  final km = harcirahMesafeKmTahmin('Denizli', 'Diyarbakır');
  return HarcirahGirdi(
    nereden: 'Denizli',
    nereye: 'Diyarbakır',
    mesafeKm: km > 0 ? km : 1243,
    bekar: false,
    esDurumu: HarcirahEsDurumu.memur,
    cocukSayisi: 1,
    gunlukUcret: kHarcirahOrnekGunlukUcret,
    otobusUcreti: 2150,
  );
}
