/// Gün bazlı örnek vardiya görünümü (bilgilendirme; resmî cetvel değildir).
enum VardiyaCalendarDayKind {
  /// Basit döngüler: görev günü özeti.
  work,

  /// Dinlenme / nöbet dışı gün özeti.
  rest,

  /// Faz tabanlı (gerçek/çakma 12/36) düzende gündüz nöbeti başlayan gün.
  cakmaDayDuty,

  /// Faz tabanlı düzende gece nöbeti başlayan gün.
  cakmaNightDuty,

  /// Faz tabanlı düzende gündüz↔gece geçişindeki dinlenme günü (özet).
  cakmaTransitionRest,
}

class VardiyaDaySlot {
  const VardiyaDaySlot({
    required this.date,
    required this.kind,
  });

  final DateTime date;
  final VardiyaCalendarDayKind kind;
}

/// Takvimde tek gün ([kind] null ise referanstan önce veya hesap yok).
class VardiyaMonthCell {
  const VardiyaMonthCell({
    required this.date,
    this.kind,
  });

  final DateTime date;
  final VardiyaCalendarDayKind? kind;
}

/// Seçilen ay içindeki özet sayımlar (yalnızca [kind] dolu günler).
class VardiyaMonthTallies {
  const VardiyaMonthTallies({
    required this.gun,
    required this.gece,
    required this.off,
  });

  final int gun;
  final int gece;
  final int off;
}

/// Somut bir nöbet bloğu: başlangıç–bitiş saatleri ve gündüz/gece bilgisi.
class VardiyaShiftInstance {
  const VardiyaShiftInstance({
    required this.start,
    required this.end,
    required this.night,
  });

  final DateTime start;
  final DateTime end;
  final bool night;
}

// ---------------------------------------------------------------------------
// Faz tabanlı (gerçek / çakma 12/36) düzen tanımları
// ---------------------------------------------------------------------------

/// Tek bir faz: gündüz mü gece mi, kaç gün sürer, görev/dinlenme ve faz sonu
/// geçiş dinlenmesi (saat).
class _PhaseDef {
  const _PhaseDef({
    required this.night,
    required this.days,
    required this.workHours,
    required this.restHours,
    required this.transitionHours,
  });

  final bool night;
  final int days;
  final int workHours;
  final int restHours;
  final int transitionHours;
}

/// Gündüz nöbeti 08:00–20:00, gece nöbeti 20:00–08:00 kabul edilir.
const int kDayShiftStartHour = 8;
const int kNightShiftStartHour = 20;

/// Geriye dönük uyumluluk: gündüz nöbet başlangıç saati (08:00).
const int kCakmaFirstDayDutyStartHour = kDayShiftStartHour;

/// Test/etiket uyumluluğu için kısa kalıp tarifi.
const String kCakmaFirstRotationDescription =
    '5 gündüz (12 saat görev / 12 saat dinlenme) → 10 gece (12 saat görev / 36 saat dinlenme)';

/// Faz tabanlı düzenler. Her düzende tam olarak bir gündüz ve bir gece fazı bulunur.
const Map<String, List<_PhaseDef>> _phasedShifts = {
  // Gerçek 12/36: 15 gün gece, 24 saat geçiş, 15 gün gündüz, 48 saat geçiş.
  'gercek_12_36': [
    _PhaseDef(night: true, days: 15, workHours: 12, restHours: 36, transitionHours: 24),
    _PhaseDef(night: false, days: 15, workHours: 12, restHours: 36, transitionHours: 48),
  ],
  // Çakma 12/36: 5 gün gündüz (12/12), 10 gün gece (12/36).
  'cakma_12_36': [
    _PhaseDef(night: false, days: 5, workHours: 12, restHours: 12, transitionHours: 24),
    _PhaseDef(night: true, days: 10, workHours: 12, restHours: 36, transitionHours: 24),
  ],
};

/// Faz tabanlı (gündüz/gece + somut saat) düzen mi?
bool isPhasedDayNightShift(String shiftId) => _phasedShifts.containsKey(shiftId);

/// Kullanıcı seçim yapmadıysa varsayılan başlangıç: gerçek→gece, çakma→gündüz.
bool defaultStartNight(String shiftId) => shiftId == 'gercek_12_36';

/// Bu düzende kullanıcıya "gündüz mü gece mi başladın?" seçimi sunulur mu?
bool supportsStartModeChoice(String shiftId) => isPhasedDayNightShift(shiftId);

// ---------------------------------------------------------------------------
// Basit (pattern) düzenler — değişmedi
// ---------------------------------------------------------------------------

/// Her vardiya türü için tekrarlayan örnek kalıp (referans günü = dizinin 0. indeksi, iş günü).
/// Faz tabanlı düzenler için boş liste döner; özel saat simülasyonu kullanılır.
List<VardiyaCalendarDayKind> vardiyaCyclePatternFor(String shiftId) {
  if (isPhasedDayNightShift(shiftId)) return const [];
  return List<VardiyaCalendarDayKind>.from(
    _patterns[shiftId] ?? _defaultPattern,
  );
}

/// Tek döngü özeti (ör. "İş → Din → Din").
String vardiyaPatternShortLabel(String shiftId) {
  if (shiftId == 'cakma_12_36') {
    return 'Çakma blokları (örnek): $kCakmaFirstRotationDescription';
  }
  if (shiftId == 'gercek_12_36') {
    return '15 gün gece (12/36) → 24 saat geçiş → 15 gün gündüz (12/36) → 48 saat geçiş';
  }
  final p = vardiyaCyclePatternFor(shiftId);
  return p
      .map((k) => k == VardiyaCalendarDayKind.work ? 'İş' : 'Din')
      .join(' → ');
}

/// Referans tarihinden başlayarak [dayCount] gün için örnek iş/dinlen sırası.
List<VardiyaDaySlot> buildVardiyaIllustrativeDays({
  required DateTime anchorLocalDate,
  required String shiftId,
  bool? startNight,
  int dayCount = 21,
}) {
  if (isPhasedDayNightShift(shiftId)) {
    return _buildPhasedIllustrativeDays(
      anchorLocalDate: anchorLocalDate,
      shiftId: shiftId,
      startNight: startNight ?? defaultStartNight(shiftId),
      dayCount: dayCount,
    );
  }

  final pattern = vardiyaCyclePatternFor(shiftId);
  if (pattern.isEmpty) return const [];

  final anchor = DateTime(
    anchorLocalDate.year,
    anchorLocalDate.month,
    anchorLocalDate.day,
  );
  final out = <VardiyaDaySlot>[];
  final n = pattern.length;

  for (var i = 0; i < dayCount; i++) {
    final d = anchor.add(Duration(days: i));
    out.add(VardiyaDaySlot(date: d, kind: pattern[i % n]));
  }
  return out;
}

// ---------------------------------------------------------------------------
// Faz tabanlı saat çizelgesi simülasyonu
// ---------------------------------------------------------------------------

enum _SegKind { dayWork, nightWork, rest, transitionRest }

class _Seg {
  _Seg(this.start, this.end, this.kind);
  final DateTime start;
  final DateTime end;
  final _SegKind kind;
}

/// Referans gününden başlayıp [coverUntil]'e kadar nöbet/dinlenme bloklarını üretir.
List<_Seg> _buildPhasedSegments({
  required DateTime anchorMidnight,
  required String shiftId,
  required bool startNight,
  required DateTime coverUntil,
}) {
  final phases = _phasedShifts[shiftId]!;
  final startIndex = phases.indexWhere((p) => p.night == startNight);
  final segs = <_Seg>[];

  var cursor = DateTime(
    anchorMidnight.year,
    anchorMidnight.month,
    anchorMidnight.day,
    startNight ? kNightShiftStartHour : kDayShiftStartHour,
  );

  var idx = startIndex < 0 ? 0 : startIndex;
  var safety = 0;
  while (cursor.isBefore(coverUntil) && safety < 100000) {
    final phase = phases[idx];
    final phaseEnd = cursor.add(Duration(days: phase.days));
    while (safety < 100000) {
      safety++;
      final workStart = cursor;
      final workEnd = workStart.add(Duration(hours: phase.workHours));
      segs.add(_Seg(
        workStart,
        workEnd,
        phase.night ? _SegKind.nightWork : _SegKind.dayWork,
      ));
      final nextStart = workEnd.add(Duration(hours: phase.restHours));
      if (nextStart.isBefore(phaseEnd)) {
        segs.add(_Seg(workEnd, nextStart, _SegKind.rest));
        cursor = nextStart;
      } else {
        final transEnd = workEnd.add(Duration(hours: phase.transitionHours));
        segs.add(_Seg(workEnd, transEnd, _SegKind.transitionRest));
        cursor = transEnd;
        break;
      }
    }
    idx = (idx + 1) % phases.length;
  }
  return segs;
}

/// Bir nöbet bloğunun "ait olduğu" takvim günü = başladığı gün
/// (gece nöbeti ertesi sabah bitse de başladığı güne yazılır).
List<VardiyaDaySlot> _buildPhasedIllustrativeDays({
  required DateTime anchorLocalDate,
  required String shiftId,
  required bool startNight,
  int dayCount = 21,
}) {
  final anchorDay = DateTime(
    anchorLocalDate.year,
    anchorLocalDate.month,
    anchorLocalDate.day,
  );
  final lastDate = anchorDay.add(Duration(days: dayCount - 1));
  final segs = _buildPhasedSegments(
    anchorMidnight: anchorDay,
    shiftId: shiftId,
    startNight: startNight,
    coverUntil: lastDate.add(const Duration(days: 2)),
  );

  final dutyByDay = _dutyDaysFromSegments(segs);
  final out = <VardiyaDaySlot>[];
  for (var i = 0; i < dayCount; i++) {
    final d = anchorDay.add(Duration(days: i));
    out.add(VardiyaDaySlot(
      date: d,
      kind: dutyByDay[_dayKey(d)] ?? VardiyaCalendarDayKind.rest,
    ));
  }
  return out;
}

/// Çalışma bloklarının başladığı günleri gündüz/gece olarak işaretler.
Map<int, VardiyaCalendarDayKind> _dutyDaysFromSegments(List<_Seg> segs) {
  final map = <int, VardiyaCalendarDayKind>{};
  for (final s in segs) {
    if (s.kind == _SegKind.dayWork || s.kind == _SegKind.nightWork) {
      map[_dayKey(s.start)] = s.kind == _SegKind.dayWork
          ? VardiyaCalendarDayKind.cakmaDayDuty
          : VardiyaCalendarDayKind.cakmaNightDuty;
    }
  }
  return map;
}

int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

/// Bugünden (veya [from]) itibaren ilk [count] somut nöbet bloğu (saatli).
/// Yalnızca faz tabanlı düzenlerde anlamlıdır; aksi halde boş döner.
List<VardiyaShiftInstance> buildVardiyaUpcomingShifts({
  required DateTime anchorLocalDate,
  required String shiftId,
  bool? startNight,
  DateTime? from,
  int count = 8,
}) {
  if (!isPhasedDayNightShift(shiftId)) return const [];

  final anchorDay = DateTime(
    anchorLocalDate.year,
    anchorLocalDate.month,
    anchorLocalDate.day,
  );
  final fromTs = from ?? anchorDay;
  final fromDay = DateTime(fromTs.year, fromTs.month, fromTs.day);
  final base = fromDay.isAfter(anchorDay) ? fromDay : anchorDay;

  final segs = _buildPhasedSegments(
    anchorMidnight: anchorDay,
    shiftId: shiftId,
    startNight: startNight ?? defaultStartNight(shiftId),
    coverUntil: base.add(const Duration(days: 200)),
  );

  final out = <VardiyaShiftInstance>[];
  for (final s in segs) {
    if (s.kind != _SegKind.dayWork && s.kind != _SegKind.nightWork) continue;
    if (s.end.isBefore(base)) continue;
    out.add(VardiyaShiftInstance(
      start: s.start,
      end: s.end,
      night: s.kind == _SegKind.nightWork,
    ));
    if (out.length >= count) break;
  }
  return out;
}

/// [year]/[month] için günlük hücreler ve ay içi özet (referanstan önceki günlük null).
({List<VardiyaMonthCell> cells, VardiyaMonthTallies tallies}) buildVardiyaMonthSchedule({
  required int year,
  required int month,
  required DateTime anchorLocalDate,
  required String shiftId,
  bool? startNight,
}) {
  final anchorDay = DateTime(
    anchorLocalDate.year,
    anchorLocalDate.month,
    anchorLocalDate.day,
  );

  final lastDay = DateTime(year, month + 1, 0).day;

  Map<int, VardiyaCalendarDayKind>? dutyByDay;
  if (isPhasedDayNightShift(shiftId)) {
    final monthEnd = DateTime(year, month, lastDay);
    final coverUntil = monthEnd.add(const Duration(days: 2));
    final segs = _buildPhasedSegments(
      anchorMidnight: anchorDay,
      shiftId: shiftId,
      startNight: startNight ?? defaultStartNight(shiftId),
      coverUntil: coverUntil,
    );
    dutyByDay = _dutyDaysFromSegments(segs);
  }

  final pattern = vardiyaCyclePatternFor(shiftId);
  final n = pattern.length;

  final cells = <VardiyaMonthCell>[];
  var gun = 0, gece = 0, off = 0;

  for (var day = 1; day <= lastDay; day++) {
    final cal0 = DateTime(year, month, day);

    if (cal0.isBefore(anchorDay)) {
      cells.add(VardiyaMonthCell(date: cal0, kind: null));
      continue;
    }

    late final VardiyaCalendarDayKind kind;
    if (isPhasedDayNightShift(shiftId)) {
      kind = dutyByDay![_dayKey(cal0)] ?? VardiyaCalendarDayKind.rest;
    } else {
      if (pattern.isEmpty) {
        cells.add(VardiyaMonthCell(date: cal0, kind: null));
        continue;
      }
      final offset = cal0.difference(anchorDay).inDays;
      kind = pattern[offset % n];
    }

    cells.add(VardiyaMonthCell(date: cal0, kind: kind));
    _accumulateMonthTally(shiftId, kind, (g, gc, o) {
      gun += g;
      gece += gc;
      off += o;
    });
  }

  return (
    cells: cells,
    tallies: VardiyaMonthTallies(gun: gun, gece: gece, off: off),
  );
}

void _accumulateMonthTally(
  String shiftId,
  VardiyaCalendarDayKind kind,
  void Function(int gun, int gece, int off) add,
) {
  if (isPhasedDayNightShift(shiftId)) {
    switch (kind) {
      case VardiyaCalendarDayKind.cakmaDayDuty:
        add(1, 0, 0);
        return;
      case VardiyaCalendarDayKind.cakmaNightDuty:
        add(0, 1, 0);
        return;
      case VardiyaCalendarDayKind.rest:
      case VardiyaCalendarDayKind.cakmaTransitionRest:
        add(0, 0, 1);
        return;
      default:
        add(0, 0, 0);
        return;
    }
  }
  switch (kind) {
    case VardiyaCalendarDayKind.work:
      add(1, 0, 0);
      return;
    case VardiyaCalendarDayKind.rest:
      add(0, 0, 1);
      return;
    default:
      add(0, 0, 0);
      return;
  }
}

const List<VardiyaCalendarDayKind> _defaultPattern = [
  VardiyaCalendarDayKind.work,
  VardiyaCalendarDayKind.rest,
  VardiyaCalendarDayKind.rest,
];

final Map<String, List<VardiyaCalendarDayKind>> _patterns = {
  // 12 çalış / 24 dinlen — sık kullanılan özet: 1 iş günü, 2 dinlenme günü.
  '12_24': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
    VardiyaCalendarDayKind.rest,
  ],
  // 24 çalış / 48 dinlen — özet 3 günlük döngü.
  '24_48': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
    VardiyaCalendarDayKind.rest,
  ],
  // Sekizlik sistem özeti (örnek): üç günlük tekrar.
  '8_24': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
    VardiyaCalendarDayKind.rest,
  ],
  // Belirsiz terim — iki iş, dört dinlen örneği.
  '222': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
    VardiyaCalendarDayKind.rest,
    VardiyaCalendarDayKind.rest,
    VardiyaCalendarDayKind.rest,
  ],
  '11': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
  ],
  '21': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
  ],
  '31': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
  ],
  'asayis_11': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
  ],
};
