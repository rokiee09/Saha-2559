import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/theme/police_colors.dart';
import 'vardiya_cycle_calculator.dart';
import 'vardiya_month_calendar_panel.dart';
import 'vardiya_shift_content.dart';
import 'vardiya_shift_types.dart';

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

/// Seçilen vardiya türü: bilgilendirici metin, referans tarihi ve aylık örnek çizelge.
class VardiyaShiftPlaceholderPage extends StatefulWidget {
  const VardiyaShiftPlaceholderPage({
    super.key,
    required this.shiftId,
  });

  final String shiftId;

  @override
  State<VardiyaShiftPlaceholderPage> createState() => _VardiyaShiftPlaceholderPageState();
}

class _VardiyaShiftPlaceholderPageState extends State<VardiyaShiftPlaceholderPage> {
  int? _anchorMs;
  late DateTime _visibleMonth;
  late bool _startNight;

  String get _startNightPrefsKey => 'vardiya_startnight_${widget.shiftId}';

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _visibleMonth = DateTime(n.year, n.month);
    _startNight = defaultStartNight(widget.shiftId);
    _refreshAnchor();
  }

  Future<void> _setStartNight(bool night) async {
    HapticFeedback.selectionClick();
    setState(() => _startNight = night);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_startNightPrefsKey, night);
  }

  void _snapMonthToAnchor() {
    if (_anchorMs == null) return;
    final a = DateTime.fromMillisecondsSinceEpoch(_anchorMs!);
    _visibleMonth = DateTime(a.year, a.month);
  }

  Future<void> _refreshAnchor() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt('vardiya_anchor_${widget.shiftId}');
    final sn = prefs.getBool(_startNightPrefsKey);
    if (!mounted) return;
    setState(() {
      _anchorMs = v;
      if (sn != null) _startNight = sn;
      if (v != null) _snapMonthToAnchor();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _anchorMs != null
        ? DateTime.fromMillisecondsSinceEpoch(_anchorMs!)
        : now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (d == null || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final atMidnight = DateTime(d.year, d.month, d.day);
    await prefs.setInt(
      'vardiya_anchor_${widget.shiftId}',
      atMidnight.millisecondsSinceEpoch,
    );
    setState(() {
      _anchorMs = atMidnight.millisecondsSinceEpoch;
      _snapMonthToAnchor();
    });
  }

  Future<void> _clearDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vardiya_anchor_${widget.shiftId}');
    if (!mounted) return;
    final n = DateTime.now();
    setState(() {
      _anchorMs = null;
      _visibleMonth = DateTime(n.year, n.month);
    });
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

  @override
  Widget build(BuildContext context) {
    final tur = VardiyaTur.byId(widget.shiftId);
    final title = tur?.title ?? 'Vardiya';
    final body = vardiyaDescriptionFor(widget.shiftId);
    final anchorDate = _anchorMs != null
        ? DateTime.fromMillisecondsSinceEpoch(_anchorMs!)
        : null;

    final monthSchedule = anchorDate != null
        ? buildVardiyaMonthSchedule(
            year: _visibleMonth.year,
            month: _visibleMonth.month,
            anchorLocalDate: anchorDate,
            shiftId: widget.shiftId,
            startNight: _startNight,
          )
        : null;

    final upcomingShifts = (anchorDate != null &&
            supportsStartModeChoice(widget.shiftId))
        ? buildVardiyaUpcomingShifts(
            anchorLocalDate: anchorDate,
            shiftId: widget.shiftId,
            startNight: _startNight,
            from: DateTime.now(),
            count: 8,
          )
        : const <VardiyaShiftInstance>[];

    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF2),
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        elevation: 0,
        title: Text(title),
        actions: [
          if (_anchorMs != null)
            IconButton(
              tooltip: 'Referans tarihinin ayına git',
              icon: const Icon(Icons.event_repeat_rounded),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(_snapMonthToAnchor);
              },
            ),
        ],
        shape: Border(
          bottom: BorderSide(
            color: PoliceColors.accentMix(0.34),
            width: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: PoliceColors.onSurfaceLight,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.48,
                            color: PoliceColors.onSurfaceLight.withValues(alpha: 0.88),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 22,
                          color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Başlangıç tarihi (hatırlatma)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: PoliceColors.onSurfaceLight,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Referans günü nöbet çizgisinin başladığı ilk iş günü olarak alınır (örnek model). '
                      'Seçim yalnızca bu cihazda saklanır. Resmî sıra için kurum çizelgesine bakın.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.42,
                            color: PoliceColors.onSurfaceLight.withValues(alpha: 0.78),
                          ),
                    ),
                    if (supportsStartModeChoice(widget.shiftId)) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Bu tarihte hangi vardiyayla başladın?',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: PoliceColors.onSurfaceLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.wb_sunny_rounded, size: 18),
                            label: Text('Gündüz (08–20)'),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.nightlight_round, size: 18),
                            label: Text('Gece (20–08)'),
                          ),
                        ],
                        selected: {_startNight},
                        onSelectionChanged: (s) => _setStartNight(s.first),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (supportsStartModeChoice(widget.shiftId))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Saat kabulü: gündüz nöbeti $kDayShiftStartHour:00–$kNightShiftStartHour:00, '
                          'gece nöbeti $kNightShiftStartHour:00–${kDayShiftStartHour.toString().padLeft(2, '0')}:00 (ertesi gün). '
                          'Biriminizin saati farklıysa tablo buna göre kayar.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.38,
                                color: PoliceColors.onSurfaceLight.withValues(alpha: 0.72),
                              ),
                        ),
                      ),
                    if (_anchorMs != null)
                      Text(
                        'Seçili referans: ${_fmtDateTr(DateTime.fromMillisecondsSinceEpoch(_anchorMs!))}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                            ),
                      )
                    else
                      Text(
                        'Henüz tarih seçilmedi.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: PoliceColors.onSurfaceLight.withValues(alpha: 0.65),
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: _pickDate,
                          child: const Text('Tarih seç'),
                        ),
                        const SizedBox(width: 10),
                        if (_anchorMs != null)
                          TextButton(
                            onPressed: _clearDate,
                            child: const Text('Temizle'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (monthSchedule != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 22,
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aylık çalışma özeti',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: PoliceColors.onSurfaceLight,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tekrar kalıbı: ${vardiyaPatternShortLabel(widget.shiftId)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.35,
                                color: PoliceColors.onSurfaceLight.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              Material(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _CalendarLegend(shiftId: widget.shiftId),
                ),
              ),
              const SizedBox(height: 14),
              if (upcomingShifts.isNotEmpty) ...[
                _UpcomingShiftsCard(shifts: upcomingShifts),
                const SizedBox(height: 14),
              ],
            ] else ...[
              Material(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: PoliceColors.onSurfaceLight.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Aylık çizelgeyi görmek için yukarıdan bir başlangıç tarihi seçin.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.38,
                                color: PoliceColors.onSurfaceLight.withValues(alpha: 0.72),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'Bu sayfa bilgilendirmedir; görev saati, nöbet sırası ve ücret hesabı için resmî çizelge ve bordro esas alınmalıdır. '
                'Veri sunucuya gönderilmez.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.42,
                      color: Colors.orange.shade900.withValues(alpha: 0.92),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PoliceColors.onSurfaceLight.withValues(alpha: 0.75),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 22,
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 8),
                Text(
                  'Yaklaşan çalışma saatleri',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PoliceColors.onSurfaceLight,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...shifts.map((s) => _ShiftRow(shift: s)),
          ],
        ),
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
    final color = night ? Colors.deepPurple.shade400 : Colors.orange.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PoliceColors.onSurfaceLight,
                  ),
            ),
          ),
          Text(
            night ? 'Gece' : 'Gündüz',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
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
        children: [
          _LegendDot(color: Colors.orange.shade600, label: 'GÜN — gündüz nöbet'),
          _LegendDot(color: Colors.deepPurple.shade400, label: 'GECE — gece nöbet'),
          _LegendDot(color: Colors.green.shade600, label: 'İST — dinlenme / geçiş (özet)'),
        ],
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendDot(
          color: Colors.orange.shade600,
          label: 'GÜN — görev günü (örnek)',
        ),
        _LegendDot(
          color: Colors.green.shade600,
          label: 'İST — dinlenme (örnek)',
        ),
      ],
    );
  }
}
