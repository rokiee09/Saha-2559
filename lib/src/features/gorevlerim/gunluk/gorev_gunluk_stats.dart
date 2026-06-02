import 'gorev_gunluk_models.dart';

const kAyAdlari = [
  '',
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

class GorevGunlukAyIstatistik {
  const GorevGunlukAyIstatistik({
    required this.toplamGorev,
    required this.toplamSaat,
    this.enYogunGun,
    this.enYogunGunLabel,
  });

  final int toplamGorev;
  final double toplamSaat;
  final DateTime? enYogunGun;
  final String? enYogunGunLabel;
}

class GorevGunlukYilIstatistik {
  const GorevGunlukYilIstatistik({
    required this.yil,
    required this.toplamGorev,
    required this.toplamSaat,
  });

  final int yil;
  final int toplamGorev;
  final double toplamSaat;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _sameMonth(DateTime a, int y, int m) => a.year == y && a.month == m;

List<GorevGunlukKayit> kayitlarForMonth(
  List<GorevGunlukKayit> all,
  int year,
  int month,
) {
  return all
      .where((k) => _sameMonth(k.tarih, year, month))
      .toList();
}

List<GorevGunlukKayit> kayitlarForDay(
  List<GorevGunlukKayit> all,
  DateTime day,
) {
  return all.where((k) => _sameDay(k.tarih, day)).toList();
}

GorevGunlukAyIstatistik ayIstatistik(
  List<GorevGunlukKayit> all, {
  DateTime? referans,
}) {
  final now = referans ?? DateTime.now();
  final items = kayitlarForMonth(all, now.year, now.month);
  if (items.isEmpty) {
    return const GorevGunlukAyIstatistik(toplamGorev: 0, toplamSaat: 0);
  }
  final saat = items.fold<double>(0, (s, e) => s + e.sureSaat);
  final byDay = <String, double>{};
  for (final k in items) {
    final key = '${k.tarih.year}-${k.tarih.month}-${k.tarih.day}';
    byDay[key] = (byDay[key] ?? 0) + k.sureSaat;
  }
  String? bestKey;
  var bestVal = -1.0;
  for (final e in byDay.entries) {
    if (e.value > bestVal) {
      bestVal = e.value;
      bestKey = e.key;
    }
  }
  DateTime? bestDay;
  String? label;
  if (bestKey != null) {
    final parts = bestKey.split('-');
    if (parts.length == 3) {
      bestDay = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      label = '${bestDay.day} ${kAyAdlari[bestDay.month]}';
    }
  }
  return GorevGunlukAyIstatistik(
    toplamGorev: items.length,
    toplamSaat: saat,
    enYogunGun: bestDay,
    enYogunGunLabel: label,
  );
}

GorevGunlukYilIstatistik yilIstatistik(
  List<GorevGunlukKayit> all, {
  int? yil,
}) {
  final y = yil ?? DateTime.now().year;
  final items = all.where((k) => k.tarih.year == y).toList();
  return GorevGunlukYilIstatistik(
    yil: y,
    toplamGorev: items.length,
    toplamSaat: items.fold<double>(0, (s, e) => s + e.sureSaat),
  );
}

String formatSaat(double saat) {
  if (saat == saat.roundToDouble()) {
    return saat.round().toString();
  }
  return saat.toStringAsFixed(1).replaceAll('.', ',');
}
