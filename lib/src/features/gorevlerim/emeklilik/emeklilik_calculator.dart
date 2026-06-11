import '../kariyer/kariyer_constants.dart';
import '../kariyer/kariyer_profil.dart';

/// Rütbeye göre yaş haddi (bilgilendirme; resmî özlük hesabı değildir).
int emeklilikYasHaddi(String? rutbeId) {
  switch (rutbeId) {
    case 'polis_memuru':
    case 'baspolis':
    case 'kideme_baspolis':
      return 55;
    case 'komiser_yardimcisi':
    case 'komiser':
    case 'baskomiser':
      return 56;
    case 'emniyet_amiri':
    case 'dort_sinif':
    case 'uc_sinif':
    case 'iki_sinif':
      return 60;
    case 'bir_sinif':
      return 65;
    default:
      return 55;
  }
}

String emeklilikYasHaddiAciklama(String? rutbeId) {
  final yas = emeklilikYasHaddi(rutbeId);
  final rutbe = KariyerRutbe.byId(rutbeId);
  final ad = rutbe?.label ?? 'Seçili rütbe';
  return '$ad için yaş haddi: $yas';
}

class EmeklilikYilAyGun {
  const EmeklilikYilAyGun({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;

  bool get isZero => years == 0 && months == 0 && days == 0;

  String kalanMetin() {
    if (isZero) return '0 gün kaldı';
    final parts = <String>[];
    if (years > 0) parts.add('$years yıl');
    if (months > 0) parts.add('$months ay');
    if (days > 0) parts.add('$days gün');
    return '${parts.join(' ')} kaldı';
  }
}

class EmeklilikIlerleme {
  const EmeklilikIlerleme({
    required this.baslangic,
    required this.bitis,
    required this.simdi,
    required this.yuzde,
    required this.kalan,
    required this.tamamlandi,
  });

  final DateTime baslangic;
  final DateTime bitis;
  final DateTime simdi;
  final double yuzde;
  final EmeklilikYilAyGun kalan;
  final bool tamamlandi;
}

class EmeklilikDurum {
  const EmeklilikDurum({
    required this.rutbeLabel,
    required this.yasHaddiYas,
    required this.zorunluHizmet,
    required this.yasHaddi,
  });

  final String rutbeLabel;
  final int yasHaddiYas;
  final EmeklilikIlerleme zorunluHizmet;
  final EmeklilikIlerleme yasHaddi;

  /// Hangi koşul önce dolarsa (daha erken bitiş tarihi).
  DateTime get emeklilikTarihi =>
      zorunluHizmet.bitis.isBefore(yasHaddi.bitis) ||
              zorunluHizmet.bitis.isAtSameMomentAs(yasHaddi.bitis)
          ? zorunluHizmet.bitis
          : yasHaddi.bitis;

  EmeklilikIlerleme get onceBitecek =>
      zorunluHizmet.bitis.isBefore(yasHaddi.bitis) ||
              zorunluHizmet.bitis.isAtSameMomentAs(yasHaddi.bitis)
          ? zorunluHizmet
          : yasHaddi;
}

DateTime _addYears(DateTime d, int years) {
  return DateTime(d.year + years, d.month, d.day);
}

EmeklilikYilAyGun _kalanYilAyGun(DateTime from, DateTime to) {
  if (!to.isAfter(from)) {
    return const EmeklilikYilAyGun(years: 0, months: 0, days: 0);
  }
  var years = to.year - from.year;
  var months = to.month - from.month;
  var days = to.day - from.day;
  if (days < 0) {
    months--;
    days += DateTime(to.year, to.month, 0).day;
  }
  if (months < 0) {
    years--;
    months += 12;
  }
  return EmeklilikYilAyGun(years: years, months: months, days: days);
}

EmeklilikIlerleme _ilerleme({
  required DateTime baslangic,
  required DateTime bitis,
  required DateTime simdi,
}) {
  if (!simdi.isBefore(bitis)) {
    return EmeklilikIlerleme(
      baslangic: baslangic,
      bitis: bitis,
      simdi: simdi,
      yuzde: 100,
      kalan: const EmeklilikYilAyGun(years: 0, months: 0, days: 0),
      tamamlandi: true,
    );
  }
  final totalDays = bitis.difference(baslangic).inDays;
  final elapsedDays = simdi.difference(baslangic).inDays.clamp(0, totalDays);
  final yuzde = totalDays <= 0
      ? 0.0
      : (elapsedDays / totalDays * 100).clamp(0.0, 100.0);
  return EmeklilikIlerleme(
    baslangic: baslangic,
    bitis: bitis,
    simdi: simdi,
    yuzde: yuzde,
    kalan: _kalanYilAyGun(simdi, bitis),
    tamamlandi: false,
  );
}

/// 20 yıl zorunlu hizmet + doğum tarihinden yaş haddi.
EmeklilikDurum? hesaplaEmeklilik(KariyerProfil profil, DateTime simdi) {
  if (profil.gorevBaslamaMs <= 0 ||
      profil.dogumTarihiMs <= 0 ||
      profil.rutbeId.isEmpty) {
    return null;
  }
  final meslekGiris =
      DateTime.fromMillisecondsSinceEpoch(profil.gorevBaslamaMs);
  final dogum = DateTime.fromMillisecondsSinceEpoch(profil.dogumTarihiMs);
  final yasHaddiYas = emeklilikYasHaddi(profil.rutbeId);
  final zorunluBitis = _addYears(meslekGiris, 20);
  final yasBitis = _addYears(dogum, yasHaddiYas);
  final rutbe = KariyerRutbe.byId(profil.rutbeId);

  final zorunlu = _ilerleme(
    baslangic: meslekGiris,
    bitis: zorunluBitis,
    simdi: simdi,
  );
  // Yaş haddi ilerlemesi: meslek girişinden 55 yaşına kadar (doğumdan değil).
  // Böylece kalan süre ile tamamlanma yüzdesi aynı ölçekte kalır.
  final yas = meslekGiris.isAfter(yasBitis)
      ? EmeklilikIlerleme(
          baslangic: yasBitis,
          bitis: yasBitis,
          simdi: simdi,
          yuzde: 100,
          kalan: const EmeklilikYilAyGun(years: 0, months: 0, days: 0),
          tamamlandi: true,
        )
      : _ilerleme(
          baslangic: meslekGiris,
          bitis: yasBitis,
          simdi: simdi,
        );

  return EmeklilikDurum(
    rutbeLabel: rutbe?.label ?? '—',
    yasHaddiYas: yasHaddiYas,
    zorunluHizmet: zorunlu,
    yasHaddi: yas,
  );
}

String formatTrTarih(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day.$month.${d.year}';
}

String formatYuzde(double yuzde) {
  if (yuzde >= 100) return '%100';
  if (yuzde == yuzde.roundToDouble()) {
    return '%${yuzde.round()}';
  }
  return '%${yuzde.toStringAsFixed(1).replaceAll('.', ',')}';
}
