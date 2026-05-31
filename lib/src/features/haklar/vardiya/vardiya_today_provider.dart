import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vardiya_cycle_calculator.dart';
import 'vardiya_setup_store.dart';
import 'vardiya_shift_types.dart';

const _prefsLastShiftId = 'vardiya_last_shift_type_id';

/// Ana sayfadaki "Bugün görevdeyim" paneli için bugünkü vardiya durumu.
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
  final bool configured;
  final bool phased;
  final VardiyaShiftInstance? active;
  final VardiyaShiftInstance? next;
  final VardiyaCalendarDayKind? todayKind;
}

final vardiyaTodayProvider =
    FutureProvider.autoDispose<VardiyaTodayStatus?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final shiftId = prefs.getString(_prefsLastShiftId);
  if (shiftId == null || shiftId.isEmpty) return null;

  final tur = VardiyaTur.byId(shiftId);
  final title = tur?.title ?? 'Vardiya';
  final setup = await VardiyaSetupStore.load(shiftId);

  if (!setup.isConfigured || setup.anchorDate == null) {
    return VardiyaTodayStatus(
      shiftId: shiftId,
      title: title,
      configured: false,
      phased: isPhasedDayNightShift(shiftId),
    );
  }

  final anchor = setup.anchorDate!;
  final groupOffset =
      VardiyaSetupStore.groupOffsetDays(shiftId, setup.group);
  final now = DateTime.now();

  if (isPhasedDayNightShift(shiftId)) {
    final shifts = buildVardiyaUpcomingShifts(
      anchorLocalDate: anchor,
      shiftId: shiftId,
      startNight: setup.startNight,
      from: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1)),
      count: 12,
      groupOffsetDays: groupOffset,
      cakmaPatternId: setup.cakmaPatternId,
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

  final effectiveAnchor = anchor.subtract(Duration(days: groupOffset));
  final anchorDay = DateTime(
    effectiveAnchor.year,
    effectiveAnchor.month,
    effectiveAnchor.day,
  );
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
    startNight: setup.startNight,
    dayCount: offset + 2,
    cycleAnchorIndex: setup.cycleIndex,
    groupOffsetDays: groupOffset,
    cakmaPatternId: setup.cakmaPatternId,
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
