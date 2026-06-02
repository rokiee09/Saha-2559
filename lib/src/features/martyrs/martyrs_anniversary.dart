import 'package:intl/intl.dart';

import '../../data/models/martyr.dart';
import 'martyrs_loader.dart';

const sehitDevriyeKapanis =
    'Ruhları şad olsun. Sonsuza dek minnettarız.';

/// Bugünün ay-günü ile şehadet tarihi eşleşen şehitler (yıldönümü).
List<Martyr> martyrsOnAnniversaryDay(
  List<Martyr> all,
  DateTime gun, {
  bool useLocal = true,
}) {
  final items = all.where((m) {
    final d = m.dateOfMartyrdom;
    if (d == null) return false;
    final local = useLocal ? d.toLocal() : d;
    return local.month == gun.month && local.day == gun.day;
  }).toList();

  items.sort((a, b) {
    final ya = a.dateOfMartyrdom?.year ?? 0;
    final yb = b.dateOfMartyrdom?.year ?? 0;
    if (ya != yb) return yb.compareTo(ya);
    return a.fullName.compareTo(b.fullName);
  });
  return items;
}

String formatAnniversaryGunLabel(DateTime gun) {
  return DateFormat('d MMMM', 'tr_TR').format(gun);
}

/// Kayar bant metni: isimler + kapanış duası.
String buildSehitDevriyeMarqueeText(List<Martyr> martyrs) {
  if (martyrs.isEmpty) return sehitDevriyeKapanis;

  final parts = <String>[];
  for (final m in martyrs) {
    final y = m.dateOfMartyrdom?.year;
    final city = m.cityName.trim();
    final showCity = city.isNotEmpty && city.toLowerCase() != 'belirtilmedi';
    final ek = <String>[
      if (y != null) '$y',
      if (showCity) city,
    ];
    final suffix = ek.isEmpty ? '' : ' (${ek.join(' · ')})';
    parts.add('${m.fullName}$suffix');
  }
  parts.add(sehitDevriyeKapanis);
  return parts.join('   ◆   ');
}

String martyrAnniversarySubtitle(List<Martyr> martyrs, DateTime gun) {
  final label = formatAnniversaryGunLabel(gun);
  if (martyrs.isEmpty) {
    return '$label tarihinde kayıtlı şehidimiz yok.';
  }
  if (martyrs.length == 1) {
    return '$label — 1 şehidimizin şehadet yıldönümü.';
  }
  return '$label — ${martyrs.length} şehidimizin şehadet yıldönümü.';
}

String martyrShortLine(Martyr m) {
  final date = formatMartyrDate(m.dateOfMartyrdom);
  return '${m.fullName} — $date';
}
