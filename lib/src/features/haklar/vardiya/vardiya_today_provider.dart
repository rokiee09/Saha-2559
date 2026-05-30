import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vardiya_cycle_calculator.dart';
import 'vardiya_shift_types.dart';

const _prefsLastShiftId = 'vardiya_last_shift_type_id';

/// Ana sayfadaki "Bugün görevdeyim" paneli için bugünkü vardiya durumu.
/// Yalnızca cihazdaki vardiya tercihinden (tür + referans + gündüz/gece)
/// türetilir; resmî çizelge değildir.
class VardiyaTodayStatus {
  const VardiyaTodayStatus({
    required this.shiftId,
    required this.title,
    required this.configured,
    this.phased = false,
    this.active,
    this.next,
    this.todayKind,
  });

  final String shiftId;
  final String title;

  /// Referans tarihi seçilmiş mi (faz tabanlı düzende somut saat için gerekli).
  final bool configured;
  final bool phased;

  /// Faz tabanlı düzende şu an süren nöbet (varsa).
  final VardiyaShiftInstance? active;

  /// Faz tabanlı düzende bir sonraki nöbet (varsa).
  final VardiyaShiftInstance? next;

  /// Basit kalıp düzenlerde bugünün türü (görev/dinlenme).
  final VardiyaCalendarDayKind? todayKind;
}

final vardiyaTodayProvider =
    FutureProvider.autoDispose<VardiyaTodayStatus?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final shiftId = prefs.getString(_prefsLastShiftId);
  if (shiftId == null || shiftId.isEmpty) return null;

  final tur = VardiyaTur.byId(shiftId);
  final title = tur?.title ?? 'Vardiya';

  final anchorMs = prefs.getInt('vardiya_anchor_$shiftId');
  final startNight =
      prefs.getBool('vardiya_startnight_$shiftId') ?? defaultStartNight(shiftId);

  if (anchorMs == null) {
    return VardiyaTodayStatus(
      shiftId: shiftId,
      title: title,
      configured: false,
      phased: isPhasedDayNightShift(shiftId),
    );
  }

  final anchor = DateTime.fromMillisecondsSinceEpoch(anchorMs);
  final now = DateTime.now();

  if (isPhasedDayNightShift(shiftId)) {
    final shifts = buildVardiyaUpcomingShifts(
      anchorLocalDate: anchor,
      shiftId: shiftId,
      startNight: startNight,
      from: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1)),
      count: 12,
    );
    VardiyaShiftInstance? active;
    VardiyaShiftInstance? next;
    for (final s in shifts) {
      final isActive = !now.isBefore(s.start) && now.isBefore(s.end);
      if (isActive) {
        active = s;
      } else if (s.start.isAfter(now)) {
        next ??= s;
      }
    }
    return VardiyaTodayStatus(
      shiftId: shiftId,
      title: title,
      configured: true,
      phased: true,
      active: active,
      next: next,
    );
  }

  // Basit kalıp düzenler: bugünün görev/dinlenme türü.
  final anchorDay = DateTime(anchor.year, anchor.month, anchor.day);
  final today = DateTime(now.year, now.month, now.day);
  if (today.isBefore(anchorDay)) {
    return VardiyaTodayStatus(
      shiftId: shiftId,
      title: title,
      configured: true,
    );
  }
  final offset = today.difference(anchorDay).inDays;
  final days = buildVardiyaIllustrativeDays(
    anchorLocalDate: anchor,
    shiftId: shiftId,
    startNight: startNight,
    dayCount: offset + 2,
  );
  VardiyaCalendarDayKind? todayKind;
  for (final d in days) {
    if (d.date.year == today.year &&
        d.date.month == today.month &&
        d.date.day == today.day) {
      todayKind = d.kind;
      break;
    }
  }
  return VardiyaTodayStatus(
    shiftId: shiftId,
    title: title,
    configured: true,
    todayKind: todayKind,
  );
});
