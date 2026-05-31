import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import 'vardiya_cycle_calculator.dart';
import 'vardiya_month_calendar_panel.dart';
import 'vardiya_setup_page.dart';
import 'vardiya_setup_store.dart';
import 'vardiya_shift_content.dart';
import 'vardiya_shift_types.dart';
import 'vardiya_ui_widgets.dart';

String _fmtDateTr(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm.${d.year}';
}

const List<String> _weekdayShortTr = [
  '',
  'Pzt',
  'Sal',
  'Çar',
  'Per',
  'Cum',
  'Cmt',
  'Paz',
];

String _fmtShiftLine(VardiyaShiftInstance s) {
  String hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final startDate =
      '${s.start.day.toString().padLeft(2, '0')}.${s.start.month.toString().padLeft(2, '0')}';
  final startWd = _weekdayShortTr[s.start.weekday];
  final sameDay = s.start.year == s.end.year &&
      s.start.month == s.end.month &&
      s.start.day == s.end.day;
  if (sameDay) {
    return '$startDate $startWd · ${hhmm(s.start)} – ${hhmm(s.end)}';
  }
  final endDate =
      '${s.end.day.toString().padLeft(2, '0')}.${s.end.month.toString().padLeft(2, '0')}';
  return '$startDate $startWd ${hhmm(s.start)} → $endDate ${hhmm(s.end)}';
}

/// Seçilen vardiya türü: kurulum sonrası açıklama, özet tablo ve aylık çizelge.
class VardiyaShiftPlaceholderPage extends StatefulWidget {
  const VardiyaShiftPlaceholderPage({
    super.key,
    required this.shiftId,
  });

  final String shiftId;

  @override
  State<VardiyaShiftPlaceholderPage> createState() =>
      _VardiyaShiftPlaceholderPageState();
}

class _VardiyaShiftPlaceholderPageState
    extends State<VardiyaShiftPlaceholderPage> {
  VardiyaSetupState _setup = const VardiyaSetupState();
  late DateTime _visibleMonth;
  bool _loading = true;

  int get _groupOffset =>
      VardiyaSetupStore.groupOffsetDays(widget.shiftId, _setup.group);

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _visibleMonth = DateTime(n.year, n.month);
    _refresh();
  }

  Future<void> _refresh() async {
    final s = await VardiyaSetupStore.load(widget.shiftId);
    if (!mounted) return;
    setState(() {
      _setup = s;
      _loading = false;
      if (s.anchorDate != null) {
        _visibleMonth = DateTime(s.anchorDate!.year, s.anchorDate!.month);
      }
    });
  }

  Future<void> _openSetup() async {
    await Navigator.of(context).push<void>(
      fadeRoute(VardiyaSetupPage(shiftId: widget.shiftId)),
    );
    await _refresh();
  }

  Future<void> _clearSetup() async {
    await VardiyaSetupStore.clear(widget.shiftId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vardiya_last_shift_type_id');
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  void _snapMonthToAnchor() {
    final a = _setup.anchorDate;
    if (a == null) return;
    setState(() => _visibleMonth = DateTime(a.year, a.month));
  }

  @override
  Widget build(BuildContext context) {
    final tur = VardiyaTur.byId(widget.shiftId);
    final title = tur?.title ?? 'Vardiya';
    final accent = tur?.topColor ?? PoliceColors.primaryBlue;
    final body = vardiyaDescriptionFor(widget.shiftId);
    final anchorDate = _setup.anchorDate;

    final monthSchedule = anchorDate != null
        ? buildVardiyaMonthSchedule(
            year: _visibleMonth.year,
            month: _visibleMonth.month,
            anchorLocalDate: anchorDate,
            shiftId: widget.shiftId,
            startNight: _setup.startNight,
            cycleAnchorIndex: _setup.cycleIndex,
            groupOffsetDays: _groupOffset,
            cakmaPatternId: _setup.cakmaPatternId,
          )
        : null;

    final upcomingShifts = (anchorDate != null &&
            isPhasedDayNightShift(widget.shiftId))
        ? buildVardiyaUpcomingShifts(
            anchorLocalDate: anchorDate,
            shiftId: widget.shiftId,
            startNight: _setup.startNight,
            from: DateTime.now(),
            count: 8,
            groupOffsetDays: _groupOffset,
            cakmaPatternId: _setup.cakmaPatternId,
          )
        : const <VardiyaShiftInstance>[];

    return Scaffold(
      backgroundColor: VardiyaUi.pageBackground,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        elevation: 0,
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Kurulumu düzenle',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _openSetup,
          ),
          if (anchorDate != null)
            IconButton(
              tooltip: 'Referans ayına git',
              icon: const Icon(Icons.event_repeat_rounded),
              onPressed: () {
                HapticFeedback.selectionClick();
                _snapMonthToAnchor();
              },
            ),
        ],
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34)),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VardiyaSectionCard(
                    title: title,
                    child: Text(
                      body,
                      style: TextStyle(
                        color: PoliceColors.mevzuatBodyText
                            .withValues(alpha: 0.92),
                        height: 1.48,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  VardiyaSectionCard(
                    title: 'Kurulum özeti',
                    subtitle: 'Seçimler yalnızca bu cihazda saklanır.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (anchorDate != null) ...[
                          _SummaryRow(
                            icon: Icons.event_rounded,
                            label: 'Referans tarihi',
                            value: _fmtDateTr(anchorDate),
                            accent: accent,
                          ),
                          if (widget.shiftId == 'gercek_12_36')
                            _SummaryRow(
                              icon: Icons.groups_rounded,
                              label: 'Grup',
                              value: '${_setup.group}. Grup',
                              accent: accent,
                            ),
                          if (isPhasedDayNightShift(widget.shiftId))
                            _SummaryRow(
                              icon: _setup.startNight
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_rounded,
                              label: 'Başlangıç bloğu',
                              value: _setup.startNight
                                  ? 'Gece (20:00 – 08:00)'
                                  : 'Gündüz (08:00 – 20:00)',
                              accent: accent,
                            ),
                          if (widget.shiftId == 'cakma_12_36')
                            _SummaryRow(
                              icon: Icons.view_week_rounded,
                              label: 'Patern',
                              value: VardiyaSetupStore.cakmaPatternById(
                                      _setup.cakmaPatternId)
                                  ?.label ??
                                  _setup.cakmaPatternId,
                              accent: accent,
                            ),
                          _SummaryRow(
                            icon: Icons.table_rows_rounded,
                            label: 'Tablo süresi',
                            value: '${_setup.tableDays} gün',
                            accent: accent,
                          ),
                          _SummaryRow(
                            icon: Icons.repeat_rounded,
                            label: 'Döngü kalıbı',
                            value: vardiyaPatternShortLabel(widget.shiftId),
                            accent: accent,
                          ),
                        ] else
                          Text(
                            'Henüz kurulum yapılmadı.',
                            style: VardiyaUi.bodyMuted(context),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonal(
                              onPressed: _openSetup,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    accent.withValues(alpha: 0.18),
                                foregroundColor: PoliceColors.titleOnDark,
                              ),
                              child: Text(
                                anchorDate == null
                                    ? 'Kurulum yap'
                                    : 'Seçimleri düzenle',
                              ),
                            ),
                            if (anchorDate != null)
                              TextButton(
                                onPressed: _clearSetup,
                                child: const Text('Sıfırla'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (monthSchedule != null) ...[
                    Text(
                      'Aylık çalışma özeti',
                      style: VardiyaUi.sectionTitle(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gündüz $kDayShiftStartHour:00–$kNightShiftStartHour:00 · '
                      'Gece $kNightShiftStartHour:00–${kDayShiftStartHour.toString().padLeft(2, '0')}:00',
                      style: VardiyaUi.bodyMuted(context),
                    ),
                    const SizedBox(height: 12),
                    VardiyaMonthCalendarPanel(
                      year: _visibleMonth.year,
                      month: _visibleMonth.month,
                      cells: monthSchedule.cells,
                      tallies: monthSchedule.tallies,
                      shiftId: widget.shiftId,
                      onPrevMonth: _prevMonth,
                      onNextMonth: _nextMonth,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: VardiyaUi.cardDecoration(),
                      padding: const EdgeInsets.all(12),
                      child: _CalendarLegend(shiftId: widget.shiftId),
                    ),
                    const SizedBox(height: 14),
                    if (upcomingShifts.isNotEmpty)
                      _UpcomingShiftsCard(shifts: upcomingShifts),
                  ] else ...[
                    Container(
                      decoration: VardiyaUi.cardDecoration(),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: PoliceColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Çizelgeyi görmek için önce vardiya durumunuzu seçin.',
                              style: VardiyaUi.bodyMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const VardiyaInfoBanner(
                    text: 'Bu sayfa bilgilendirmedir; görev saati, nöbet sırası ve '
                        'ücret hesabı için resmî çizelge ve bordro esas alınmalıdır.',
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent.withValues(alpha: 0.9)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: PoliceColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: PoliceColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _UpcomingShiftsCard extends StatelessWidget {
  const _UpcomingShiftsCard({required this.shifts});

  final List<VardiyaShiftInstance> shifts;

  @override
  Widget build(BuildContext context) {
    return VardiyaSectionCard(
      title: 'Yaklaşan çalışma saatleri',
      child: Column(
        children: shifts.map((s) => _ShiftRow(shift: s)).toList(),
      ),
    );
  }
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({required this.shift});

  final VardiyaShiftInstance shift;

  @override
  Widget build(BuildContext context) {
    final night = shift.night;
    final color =
        night ? PoliceColors.primaryBlue : PoliceColors.gold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              night ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _fmtShiftLine(shift),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: PoliceColors.titleOnDark,
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            night ? 'Gece' : 'Gündüz',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.shiftId});

  final String shiftId;

  @override
  Widget build(BuildContext context) {
    if (isPhasedDayNightShift(shiftId)) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: const [
          _LegendDot(color: PoliceColors.gold, label: 'GÜN — gündüz nöbet'),
          _LegendDot(
            color: PoliceColors.primaryBlue,
            label: 'GECE — gece nöbet',
          ),
          _LegendDot(color: Color(0xFF4ADE80), label: 'İST — dinlenme'),
        ],
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendDot(color: PoliceColors.gold, label: 'GÜN — görev günü'),
        _LegendDot(color: Color(0xFF4ADE80), label: 'İST — dinlenme'),
      ],
    );
  }
}
