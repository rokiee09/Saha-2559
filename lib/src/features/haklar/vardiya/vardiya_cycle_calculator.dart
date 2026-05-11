/// Gün bazlı örnek vardiya görünümü (bilgilendirme; resmî cetvel değildir).
enum VardiyaCalendarDayKind {
  /// Basit döngüler: görev günü özeti.
  work,

  /// Dinlenme / nöbet dışı gün özeti.
  rest,

  /// Çakma 12/36: takvim gününde gündüz nöbet bandı (12 saat görev) hâkim.
  cakmaDayDuty,

  /// Çakma 12/36: takvim gününde gece nöbet bandı (12 saat görev) hâkim.
  cakmaNightDuty,

  /// Çakma 12/36: gündüz ile gece blokları arasındaki 24 saatlik geçiş dinlenmesine denk gelen gün.
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

/// Çakma 12/36 örnek zaman çizelgesi — blok uzunlukları birime göre değişebilir; cetvelle doğrulanmalıdır.
///
/// İç kurallar: her **gündüz** birimi 12 saat görev + 12 saat dinlenme; her **gece** birimi 12 saat görev + 36 saat dinlenme.
/// Bir **gündüz** bloğu ile **gece** bloğu arasında (veya tam tersi) 24 saatlik geçiş dinlenmesi eklenir.
/// Büyük döngü sonunda tekrar başa dönülmeden önce de bir geçiş dinlenmesi konur (örnek son blok gece ise).
///
/// [kCakmaFirstRotationDescription]: kullanıcı tarifi — haftanın günleri değil, üst üste kaç “gündüz/gece birimi”.
const String kCakmaFirstRotationDescription =
    '3 gündüz → 12 gece → 5 gündüz → 10 gece → 6 gündüz → 9 gece';

const int kCakmaFirstDayDutyStartHour = 8;

class _CakmaPhase {
  const _CakmaPhase({
    required this.dayMode,
    required this.innerCycles,
  });

  /// true: her birim (12 saat görev + 12 saat dinlenme); false: (12 + 36).
  final bool dayMode;

  /// Üst üste kaç birim (kullanıcının “X gün gündüz / gece” dediği sayı).
  final int innerCycles;
}

/// Tek tam tur — sıra sabit; başka birime göre düzenlenecekse bu liste güncellenir.
const List<_CakmaPhase> _cakmaPhases = [
  _CakmaPhase(dayMode: true, innerCycles: 3),
  _CakmaPhase(dayMode: false, innerCycles: 12),
  _CakmaPhase(dayMode: true, innerCycles: 5),
  _CakmaPhase(dayMode: false, innerCycles: 10),
  _CakmaPhase(dayMode: true, innerCycles: 6),
  _CakmaPhase(dayMode: false, innerCycles: 9),
];

/// Her vardiya türü için tekrarlayan örnek kalıp (referans günü = dizinin 0. indeksi, iş günü).
/// Çakma 12/36 için boş liste döner; [buildVardiyaIllustrativeDays] özel yolu kullanır.
List<VardiyaCalendarDayKind> vardiyaCyclePatternFor(String shiftId) {
  if (shiftId == 'cakma_12_36') return const [];
  return List<VardiyaCalendarDayKind>.from(
    _patterns[shiftId] ?? _defaultPattern,
  );
}

/// Tek döngü özeti (ör. "İş → Din → Din").
String vardiyaPatternShortLabel(String shiftId) {
  if (shiftId == 'cakma_12_36') {
    return 'Çakma blokları (örnek): $kCakmaFirstRotationDescription '
        '(bloklar arası mod değişiminde +24 saat geçiş dinlenmesi)';
  }
  final p = vardiyaCyclePatternFor(shiftId);
  return p
      .map(
        (k) =>
            k == VardiyaCalendarDayKind.work ? 'İş' : 'Din',
      )
      .join(' → ');
}

/// Referans tarihinden başlayarak [dayCount] gün için örnek iş/dinlen sırası.
List<VardiyaDaySlot> buildVardiyaIllustrativeDays({
  required DateTime anchorLocalDate,
  required String shiftId,
  int dayCount = 21,
}) {
  if (shiftId == 'cakma_12_36') {
    return _buildCakma1236IllustrativeDays(
      anchorLocalDate: anchorLocalDate,
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
    out.add(
      VardiyaDaySlot(
        date: d,
        kind: pattern[i % n],
      ),
    );
  }
  return out;
}

List<_HourSegment> _buildCakmaSegmentsCovering({
  required DateTime anchorDayMidnight,
  required DateTime coverUntil,
}) {
  final simStart = DateTime(
    anchorDayMidnight.year,
    anchorDayMidnight.month,
    anchorDayMidnight.day,
    kCakmaFirstDayDutyStartHour,
  );
  final builder = _CakmaTimelineBuilder(simStart);
  while (builder.cursor.isBefore(coverUntil)) {
    builder.appendFullCakmaRotation(_cakmaPhases);
  }
  return builder.segments;
}

VardiyaCalendarDayKind _classifyCakmaCalendarDay(
  DateTime cal0Midnight,
  List<_HourSegment> segments,
) {
  final cal1 = cal0Midnight.add(const Duration(days: 1));

  var dw = 0.0, nw = 0.0, tr = 0.0;

  for (final seg in segments) {
    final m = _overlapMinutes(seg.start, seg.end, cal0Midnight, cal1);
    if (m <= 0) continue;
    switch (seg.kind) {
      case _CakmaSegKind.dayWork:
        dw += m;
        break;
      case _CakmaSegKind.nightWork:
        nw += m;
        break;
      case _CakmaSegKind.transitionRest:
        tr += m;
        break;
      case _CakmaSegKind.dayRest:
      case _CakmaSegKind.nightRest:
        break;
    }
  }

  if (dw > 0 || nw > 0) {
    return dw >= nw
        ? VardiyaCalendarDayKind.cakmaDayDuty
        : VardiyaCalendarDayKind.cakmaNightDuty;
  }
  if (tr >= 12 * 60) {
    return VardiyaCalendarDayKind.cakmaTransitionRest;
  }
  return VardiyaCalendarDayKind.rest;
}

/// [year]/[month] için günlük hücreler ve ay içi özet (referanstan önceki günlük null).
({List<VardiyaMonthCell> cells, VardiyaMonthTallies tallies}) buildVardiyaMonthSchedule({
  required int year,
  required int month,
  required DateTime anchorLocalDate,
  required String shiftId,
}) {
  final anchorDay = DateTime(
    anchorLocalDate.year,
    anchorLocalDate.month,
    anchorLocalDate.day,
  );

  final lastDay = DateTime(year, month + 1, 0).day;
  final monthEnd = DateTime(year, month, lastDay);
  final coverUntil = monthEnd.add(const Duration(days: 2));

  List<_HourSegment>? cakmaSegments;
  if (shiftId == 'cakma_12_36') {
    cakmaSegments = _buildCakmaSegmentsCovering(
      anchorDayMidnight: anchorDay,
      coverUntil: coverUntil,
    );
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
    if (shiftId == 'cakma_12_36') {
      kind = _classifyCakmaCalendarDay(cal0, cakmaSegments!);
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
  if (shiftId == 'cakma_12_36') {
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

List<VardiyaDaySlot> _buildCakma1236IllustrativeDays({
  required DateTime anchorLocalDate,
  int dayCount = 21,
}) {
  final anchorDay = DateTime(
    anchorLocalDate.year,
    anchorLocalDate.month,
    anchorLocalDate.day,
  );

  final lastDate = anchorDay.add(Duration(days: dayCount - 1));
  final segments = _buildCakmaSegmentsCovering(
    anchorDayMidnight: anchorDay,
    coverUntil: lastDate.add(const Duration(days: 2)),
  );

  final out = <VardiyaDaySlot>[];
  for (var i = 0; i < dayCount; i++) {
    final cal0 = anchorDay.add(Duration(days: i));
    final kind = _classifyCakmaCalendarDay(cal0, segments);
    out.add(VardiyaDaySlot(date: cal0, kind: kind));
  }
  return out;
}

double _overlapMinutes(DateTime a0, DateTime a1, DateTime b0, DateTime b1) {
  final s = a0.isAfter(b0) ? a0 : b0;
  final e = a1.isBefore(b1) ? a1 : b1;
  if (!e.isAfter(s)) return 0;
  return e.difference(s).inMinutes.toDouble();
}

enum _CakmaSegKind {
  dayWork,
  dayRest,
  transitionRest,
  nightWork,
  nightRest,
}

class _HourSegment {
  _HourSegment({
    required this.start,
    required this.end,
    required this.kind,
  });

  final DateTime start;
  final DateTime end;
  final _CakmaSegKind kind;
}

class _CakmaTimelineBuilder {
  _CakmaTimelineBuilder(this.cursor);

  DateTime cursor;
  final List<_HourSegment> segments = [];

  void _emit(_CakmaSegKind kind, int hours) {
    final start = cursor;
    cursor = cursor.add(Duration(hours: hours));
    segments.add(_HourSegment(start: start, end: cursor, kind: kind));
  }

  /// Bir tam çakma turu; [phases] birinden diğerine geçerken 24 saat geçiş dinlenmesi eklenir,
  /// tur sonunda başa dönmek için bir geçiş daha (örnek son faz gece olduğu sürece).
  void appendFullCakmaRotation(List<_CakmaPhase> phases) {
    _CakmaPhase? prev;
    for (final block in phases) {
      if (prev != null && prev.dayMode != block.dayMode) {
        _emit(_CakmaSegKind.transitionRest, 24);
      }
      if (block.dayMode) {
        for (var i = 0; i < block.innerCycles; i++) {
          _emit(_CakmaSegKind.dayWork, 12);
          _emit(_CakmaSegKind.dayRest, 12);
        }
      } else {
        for (var i = 0; i < block.innerCycles; i++) {
          _emit(_CakmaSegKind.nightWork, 12);
          _emit(_CakmaSegKind.nightRest, 36);
        }
      }
      prev = block;
    }
    _emit(_CakmaSegKind.transitionRest, 24);
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
  'gercek_12_36': [
    VardiyaCalendarDayKind.work,
    VardiyaCalendarDayKind.rest,
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
