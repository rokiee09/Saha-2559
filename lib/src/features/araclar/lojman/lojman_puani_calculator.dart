class LojmanPuaniGirdi {
  const LojmanPuaniGirdi({
    this.iseBaslama,
    required this.esCalisiyor,
    required this.evli,
    required this.cocukSayisi,
    required this.gaziYakini,
    required this.engelliAileFerdi,
    required this.digerAileFerdi,
    required this.beklenenYil,
    required this.beklenenAy,
    required this.askerlikAy,
    required this.gelirSiniriAsildi,
    required this.oncekiKonutYil,
    required this.oncekiKonutAy,
    required this.ilIciKonut,
    required this.ilDisiKonut,
  });

  final DateTime? iseBaslama;
  final bool esCalisiyor;
  final bool evli;
  final int cocukSayisi;
  final int gaziYakini;
  final int engelliAileFerdi;
  final int digerAileFerdi;
  final int beklenenYil;
  final int beklenenAy;
  final int askerlikAy;
  final bool gelirSiniriAsildi;
  final int oncekiKonutYil;
  final int oncekiKonutAy;
  final int ilIciKonut;
  final int ilDisiKonut;
}

class LojmanPuanSatiri {
  const LojmanPuanSatiri({
    required this.aciklama,
    required this.deger,
    required this.katsayi,
    required this.sonuc,
  });

  final String aciklama;
  final String deger;
  final double katsayi;
  final double sonuc;
}

class LojmanPuaniSonuc {
  const LojmanPuaniSonuc({
    required this.satirlar,
    required this.toplam,
    required this.hizmetYil,
    required this.hizmetAy,
  });

  final List<LojmanPuanSatiri> satirlar;
  final double toplam;
  final int hizmetYil;
  final int hizmetAy;
}

const double kLojmanMedeniEvliPuani = 6;
const double kLojmanEsCalisiyorPuani = -1;
const double kLojmanGaziYakiniPuani = 40;
const double kLojmanEngelliAileFerdiPuani = 40;
const double kLojmanHizmetYilPuani = 5;
const double kLojmanCocukPuani = 3;
const double kLojmanDigerAileFerdiPuani = 1;
const double kLojmanBeklemeYilPuani = 1;
const double kLojmanGelirSiniriPuani = -1;
const double kLojmanOncekiKonutYilPuani = -3;
const double kLojmanIlIciKonutPuani = -15;
const double kLojmanIlDisiKonutPuani = -10;

({int yil, int ay}) lojmanHizmetSuresi(DateTime? baslama, {DateTime? now}) {
  if (baslama == null) return (yil: 0, ay: 0);
  final bugun = now ?? DateTime.now();
  if (bugun.isBefore(baslama)) return (yil: 0, ay: 0);

  var yil = bugun.year - baslama.year;
  var ay = bugun.month - baslama.month;
  if (bugun.day < baslama.day) ay--;
  if (ay < 0) {
    yil--;
    ay += 12;
  }
  return (yil: yil.clamp(0, 80), ay: ay.clamp(0, 11));
}

LojmanPuaniSonuc hesaplaLojmanPuani(
  LojmanPuaniGirdi g, {
  DateTime? now,
}) {
  final hizmet = lojmanHizmetSuresi(g.iseBaslama, now: now);
  final satirlar = <LojmanPuanSatiri>[];

  void ekle(String aciklama, num deger, double katsayi) {
    if (deger == 0) return;
    satirlar.add(
      LojmanPuanSatiri(
        aciklama: aciklama,
        deger: deger is int ? '$deger' : deger.toString(),
        katsayi: katsayi,
        sonuc: deger * katsayi,
      ),
    );
  }

  if (g.esCalisiyor) ekle('Eş çalışıyor', 1, kLojmanEsCalisiyorPuani);
  if (g.evli) ekle('Medeni durum: evli', 1, kLojmanMedeniEvliPuani);
  ekle('Gazi / şehit yakını', g.gaziYakini, kLojmanGaziYakiniPuani);
  ekle(
    'Engelli aile ferdi',
    g.engelliAileFerdi,
    kLojmanEngelliAileFerdiPuani,
  );
  ekle('Hizmet süresi (yıl)', hizmet.yil, kLojmanHizmetYilPuani);
  ekle('Hizmet süresi (ay)', hizmet.ay, kLojmanHizmetYilPuani / 12);
  ekle('Çocuk sayısı', g.cocukSayisi, kLojmanCocukPuani);
  ekle('Diğer aile fertleri', g.digerAileFerdi, kLojmanDigerAileFerdiPuani);
  ekle('Lojman için beklenen yıl', g.beklenenYil, kLojmanBeklemeYilPuani);
  ekle('Lojman için beklenen ay', g.beklenenAy, kLojmanBeklemeYilPuani / 12);
  ekle('Askerlik süresi (ay)', g.askerlikAy, kLojmanHizmetYilPuani / 12);
  if (g.gelirSiniriAsildi) {
    ekle('Yıllık gelir sınırı aşıldı', 1, kLojmanGelirSiniriPuani);
  }
  ekle('Önceki konut kullanımı (yıl)', g.oncekiKonutYil,
      kLojmanOncekiKonutYilPuani);
  ekle('Önceki konut kullanımı (ay)', g.oncekiKonutAy,
      kLojmanOncekiKonutYilPuani / 12);
  ekle('Sahip olunan konut (il içinde)', g.ilIciKonut, kLojmanIlIciKonutPuani);
  ekle('Sahip olunan konut (il dışında)', g.ilDisiKonut,
      kLojmanIlDisiKonutPuani);

  final toplam = satirlar.fold<double>(0, (sum, row) => sum + row.sonuc);
  return LojmanPuaniSonuc(
    satirlar: satirlar,
    toplam: toplam,
    hizmetYil: hizmet.yil,
    hizmetAy: hizmet.ay,
  );
}

LojmanPuaniGirdi get ornekLojmanGirdi => LojmanPuaniGirdi(
      iseBaslama: DateTime(2017, 6, 5),
      esCalisiyor: true,
      evli: true,
      cocukSayisi: 2,
      gaziYakini: 1,
      engelliAileFerdi: 1,
      digerAileFerdi: 1,
      beklenenYil: 5,
      beklenenAy: 3,
      askerlikAy: 6,
      gelirSiniriAsildi: true,
      oncekiKonutYil: 3,
      oncekiKonutAy: 8,
      ilIciKonut: 1,
      ilDisiKonut: 0,
    );
