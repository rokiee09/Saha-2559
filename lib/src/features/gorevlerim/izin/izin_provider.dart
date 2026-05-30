import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// İzin takibi yalnızca cihazda (SharedPreferences) tutulur; buluta çıkmaz.
/// Gün sayıları kullanıcının kendi girdiğidir, resmî kayıt değildir.

enum LeaveType { yillik, mazeret, refakat, dogum, rapor, diger }

extension LeaveTypeX on LeaveType {
  String get id => name;

  String get label => switch (this) {
        LeaveType.yillik => 'Yıllık izin',
        LeaveType.mazeret => 'Mazeret izni',
        LeaveType.refakat => 'Refakat izni',
        LeaveType.dogum => 'Doğum izni',
        LeaveType.rapor => 'Rapor',
        LeaveType.diger => 'Diğer',
      };

  static LeaveType fromId(String? id) {
    return LeaveType.values.firstWhere(
      (e) => e.name == id,
      orElse: () => LeaveType.diger,
    );
  }
}

/// Rapor süresine göre sınıflandırma: 10 günü aşan rapor heyet raporu,
/// 10 gün ve altı tek hekim tarafından verilir.
bool raporHeyetGerekir(int days) => days > 10;

class LeaveRecord {
  final String id;
  final LeaveType type;

  /// İzin gün sayısı (yol izni hariç).
  final int days;

  /// Otomatik hesaplanan yol izni günü.
  final int roadDays;

  /// İznin başlangıç tarihi (gün başlangıcı).
  final int startMs;

  /// Kaydın oluşturulma tarihi.
  final int dateMs;

  final String fromCity;
  final String toCity;
  final int km;
  final String note;

  const LeaveRecord({
    required this.id,
    required this.type,
    required this.days,
    required this.startMs,
    required this.dateMs,
    this.roadDays = 0,
    this.fromCity = '',
    this.toCity = '',
    this.km = 0,
    this.note = '',
  });

  DateTime get start => DateTime.fromMillisecondsSinceEpoch(startMs);

  /// Toplam izinli gün (izin + yol izni).
  int get totalOffDays => days + roadDays;

  /// İşe başlama tarihi = başlangıç + (izin + yol) günü.
  DateTime get returnDate => DateTime(start.year, start.month, start.day)
      .add(Duration(days: totalOffDays));

  /// İznin son günü (işe başlamadan bir gün önce).
  DateTime get lastOffDay => returnDate.subtract(const Duration(days: 1));

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.id,
        'days': days,
        'roadDays': roadDays,
        'start': startMs,
        'date': dateMs,
        'fromCity': fromCity,
        'toCity': toCity,
        'km': km,
        'note': note,
      };

  factory LeaveRecord.fromJson(Map<String, dynamic> json) {
    final dateMs = (json['date'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    return LeaveRecord(
      id: json['id'] as String? ?? '',
      type: LeaveTypeX.fromId(json['type'] as String?),
      days: (json['days'] as num?)?.toInt() ?? 0,
      roadDays: (json['roadDays'] as num?)?.toInt() ?? 0,
      // Eski kayıtlarda start yoksa kayıt tarihini başlangıç kabul et.
      startMs: (json['start'] as num?)?.toInt() ?? dateMs,
      dateMs: dateMs,
      fromCity: json['fromCity'] as String? ?? '',
      toCity: json['toCity'] as String? ?? '',
      km: (json['km'] as num?)?.toInt() ?? 0,
      note: json['note'] as String? ?? '',
    );
  }
}

const _leaveRecordsKey = 'gorevlerim_izin_records_v1';
const _serviceYearsKey = 'gorevlerim_hizmet_yili_v1';
const _devirYillikKey = 'gorevlerim_izin_devir_yillik_v1';
const _devirYolKey = 'gorevlerim_izin_devir_yol_v1';

/// Yıllık yol izni hakkı (gün). Örnek modelde sabit.
const int kYolIzniYillik = 4;

final izinVersionProvider = StateProvider<int>((ref) => 0);

/// Hizmet yılı (657'ye göre yıllık izin hakkını belirler).
final hizmetYiliProvider = FutureProvider<int>((ref) async {
  ref.watch(izinVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_serviceYearsKey) ?? 0;
});

Future<void> izinSaveHizmetYili(WidgetRef ref, int years) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_serviceYearsKey, years.clamp(0, 60));
  ref.read(izinVersionProvider.notifier).state++;
}

/// Geçen yıldan devreden izin (manuel giriş).
typedef IzinDevir = ({int yillik, int yol});

final izinDevirProvider = FutureProvider<IzinDevir>((ref) async {
  ref.watch(izinVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  return (
    yillik: prefs.getInt(_devirYillikKey) ?? 0,
    yol: prefs.getInt(_devirYolKey) ?? 0,
  );
});

Future<void> izinSaveDevir(WidgetRef ref, int yillik, int yol) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_devirYillikKey, yillik.clamp(0, 365));
  await prefs.setInt(_devirYolKey, yol.clamp(0, 60));
  ref.read(izinVersionProvider.notifier).state++;
}

/// 657 sayılı DMK md. 102: hizmeti 10 yıldan az olan → 20 gün, 10 yıl ve
/// üzeri → 30 gün (10. yıla giren memur 30 güne geçer).
int yillikIzinHakki(int serviceYears) => serviceYears >= 10 ? 30 : 20;

final izinRecordsProvider = FutureProvider<List<LeaveRecord>>((ref) async {
  ref.watch(izinVersionProvider);
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_leaveRecordsKey);
  if (raw == null || raw.isEmpty) return const [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return const [];
    final list = dec
        .whereType<Map<String, dynamic>>()
        .map(LeaveRecord.fromJson)
        .toList()
      ..sort((a, b) => b.startMs.compareTo(a.startMs));
    return list;
  } catch (_) {
    return const [];
  }
});

Future<List<LeaveRecord>> _readRecords() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_leaveRecordsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final dec = jsonDecode(raw);
    if (dec is! List) return [];
    return dec
        .whereType<Map<String, dynamic>>()
        .map(LeaveRecord.fromJson)
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> _writeRecords(WidgetRef ref, List<LeaveRecord> records) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _leaveRecordsKey,
    jsonEncode(records.map((e) => e.toJson()).toList()),
  );
  ref.read(izinVersionProvider.notifier).state++;
}

Future<void> izinAddRecord(WidgetRef ref, LeaveRecord record) async {
  final records = await _readRecords();
  records.add(record);
  await _writeRecords(ref, records);
}

Future<void> izinDeleteRecord(WidgetRef ref, String id) async {
  final records = await _readRecords();
  records.removeWhere((e) => e.id == id);
  await _writeRecords(ref, records);
}

/// Türe göre toplam kullanılan gün (yol izni hariç).
Map<LeaveType, int> izinUsedByType(List<LeaveRecord> records) {
  final map = {for (final t in LeaveType.values) t: 0};
  for (final r in records) {
    map[r.type] = (map[r.type] ?? 0) + r.days;
  }
  return map;
}

/// Belirli bir yıl için yıllık + yol izni durumu.
class YillikIzinDurum {
  const YillikIzinDurum({
    required this.yil,
    required this.hakYillik,
    required this.devirYillik,
    required this.kullanilanYillik,
    required this.hakYol,
    required this.devirYol,
    required this.kullanilanYol,
  });

  final int yil;
  final int hakYillik;
  final int devirYillik;
  final int kullanilanYillik;
  final int hakYol;
  final int devirYol;
  final int kullanilanYol;

  int get toplamYillik => hakYillik + devirYillik;
  int get kalanYillik => toplamYillik - kullanilanYillik;
  int get toplamYol => hakYol + devirYol;
  int get kalanYol => toplamYol - kullanilanYol;

  /// Dolu (full) durumda 1.0 → boşaldıkça 0.0 (batarya göstergesi oranı).
  double get yillikRatio =>
      toplamYillik <= 0 ? 0.0 : (kalanYillik / toplamYillik).clamp(0.0, 1.0);
}

/// Verilen yıl (varsayılan bu yıl) için yıllık izin durumunu hesaplar.
YillikIzinDurum computeYillikDurum({
  required List<LeaveRecord> records,
  required int serviceYears,
  required int devirYillik,
  required int devirYol,
  int? year,
}) {
  final y = year ?? DateTime.now().year;
  var usedY = 0;
  var usedYol = 0;
  for (final r in records) {
    if (r.type != LeaveType.yillik) continue;
    if (r.start.year != y) continue;
    usedY += r.days;
    usedYol += r.roadDays;
  }
  return YillikIzinDurum(
    yil: y,
    hakYillik: yillikIzinHakki(serviceYears),
    devirYillik: devirYillik,
    kullanilanYillik: usedY,
    hakYol: kYolIzniYillik,
    devirYol: devirYol,
    kullanilanYol: usedYol,
  );
}

/// Şu an devam eden ya da en yakın gelecekteki izni döndürür (takip için).
LeaveRecord? izinAktifVeyaYaklasan(List<LeaveRecord> records, {DateTime? now}) {
  final now0 = now ?? DateTime.now();
  final today = DateTime(now0.year, now0.month, now0.day);

  LeaveRecord? ongoing;
  LeaveRecord? nextFuture;
  for (final r in records) {
    final start = DateTime(r.start.year, r.start.month, r.start.day);
    final ret = r.returnDate;
    final isOngoing = !today.isBefore(start) && today.isBefore(ret);
    if (isOngoing) {
      if (ongoing == null || start.isAfter(ongoing.start)) ongoing = r;
    } else if (start.isAfter(today)) {
      if (nextFuture == null || start.isBefore(nextFuture.start)) {
        nextFuture = r;
      }
    }
  }
  return ongoing ?? nextFuture;
}

/// İzin başlamasına kalan gün (negatifse başlamış). Takvim günü farkı.
int izinBaslangicaKalanGun(LeaveRecord r, {DateTime? now}) {
  final now0 = now ?? DateTime.now();
  final today = DateTime(now0.year, now0.month, now0.day);
  final start = DateTime(r.start.year, r.start.month, r.start.day);
  return start.difference(today).inDays;
}

/// İşe dönüşe kalan gün (izin sürüyorsa pozitif).
int iseDonuseKalanGun(LeaveRecord r, {DateTime? now}) {
  final now0 = now ?? DateTime.now();
  final today = DateTime(now0.year, now0.month, now0.day);
  return r.returnDate.difference(today).inDays;
}
