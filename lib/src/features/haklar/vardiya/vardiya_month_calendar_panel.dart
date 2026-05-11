import 'package:flutter/material.dart';

import 'vardiya_cycle_calculator.dart';

const List<String> _monthNamesTr = [
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

const List<String> _weekdayLabelsTr = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

/// Referans görseldeki gibi: özet kartı + ay seçici + aylık ızgara.
class VardiyaMonthCalendarPanel extends StatelessWidget {
  const VardiyaMonthCalendarPanel({
    super.key,
    required this.year,
    required this.month,
    required this.cells,
    required this.tallies,
    required this.shiftId,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final int year;
  final int month;
  final List<VardiyaMonthCell> cells;
  final VardiyaMonthTallies tallies;
  final String shiftId;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final title =
        '${_monthNamesTr[month].toUpperCase()} $year';

    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingBlanks = firstWeekday - 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final gridCount = leadingBlanks + lastDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        icon: Icons.wb_sunny_rounded,
                        iconColor: Colors.orange.shade700,
                        label: 'Gündüz',
                        value: tallies.gun,
                      ),
                    ),
                    Expanded(
                      child: _SummaryChip(
                        icon: Icons.nightlight_round,
                        iconColor: Colors.deepPurple.shade400,
                        label: 'Gece',
                        value: tallies.gece,
                      ),
                    ),
                    Expanded(
                      child: _SummaryChip(
                        icon: Icons.weekend_rounded,
                        iconColor: Colors.green.shade600,
                        label: 'OFF',
                        value: tallies.off,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: onPrevMonth,
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: 'Önceki ay',
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: const Color(0xFF1A1D23),
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: onNextMonth,
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: 'Sonraki ay',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Text(
                          _weekdayLabelsTr[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: gridCount,
                  itemBuilder: (context, index) {
                    if (index < leadingBlanks) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white),
                      );
                    }
                    final day = index - leadingBlanks + 1;
                    final cell = cells[day - 1];
                    return _MonthDayTile(
                      day: day,
                      kind: cell.kind,
                      shiftId: shiftId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1D23),
          ),
        ),
      ],
    );
  }
}

class _MonthDayTile extends StatelessWidget {
  const _MonthDayTile({
    required this.day,
    required this.kind,
    required this.shiftId,
  });

  final int day;
  final VardiyaCalendarDayKind? kind;
  final String shiftId;

  @override
  Widget build(BuildContext context) {
    if (kind == null) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    final style = _tileStyle(kind!, shiftId);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: style.numberColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            style.shortLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: shiftId == 'cakma_12_36' ? 9 : 10,
              fontWeight: FontWeight.w800,
              color: style.labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TileStyle {
  const _TileStyle({
    required this.bg,
    required this.border,
    required this.numberColor,
    required this.labelColor,
    required this.shortLabel,
  });

  final Color bg;
  final Color border;
  final Color numberColor;
  final Color labelColor;
  final String shortLabel;
}

_TileStyle _tileStyle(VardiyaCalendarDayKind kind, String shiftId) {
  if (shiftId == 'cakma_12_36') {
    switch (kind) {
      case VardiyaCalendarDayKind.cakmaDayDuty:
        return _TileStyle(
          bg: Colors.orange.shade100,
          border: Colors.orange.shade400,
          numberColor: Colors.orange.shade900,
          labelColor: Colors.orange.shade900.withValues(alpha: 0.92),
          shortLabel: 'GÜN',
        );
      case VardiyaCalendarDayKind.cakmaNightDuty:
        return _TileStyle(
          bg: Colors.deepPurple.shade50,
          border: Colors.deepPurple.shade300,
          numberColor: Colors.deepPurple.shade900,
          labelColor: Colors.deepPurple.shade900.withValues(alpha: 0.92),
          shortLabel: 'GECE',
        );
      case VardiyaCalendarDayKind.rest:
      case VardiyaCalendarDayKind.cakmaTransitionRest:
        return _TileStyle(
          bg: Colors.green.shade100,
          border: Colors.green.shade400,
          numberColor: Colors.green.shade900,
          labelColor: Colors.green.shade900.withValues(alpha: 0.9),
          shortLabel: 'İST',
        );
      default:
        return _TileStyle(
          bg: Colors.blueGrey.shade50,
          border: Colors.blueGrey.shade200,
          numberColor: const Color(0xFF1A1D23),
          labelColor: Colors.blueGrey.shade700,
          shortLabel: '—',
        );
    }
  }

  switch (kind) {
    case VardiyaCalendarDayKind.work:
      return _TileStyle(
        bg: Colors.orange.shade100,
        border: Colors.orange.shade400,
        numberColor: Colors.orange.shade900,
        labelColor: Colors.orange.shade900.withValues(alpha: 0.92),
        shortLabel: 'GÜN',
      );
    case VardiyaCalendarDayKind.rest:
      return _TileStyle(
        bg: Colors.green.shade100,
        border: Colors.green.shade400,
        numberColor: Colors.green.shade900,
        labelColor: Colors.green.shade900.withValues(alpha: 0.9),
        shortLabel: 'İST',
      );
    default:
      return _TileStyle(
        bg: Colors.blueGrey.shade50,
        border: Colors.blueGrey.shade200,
        numberColor: const Color(0xFF1A1D23),
        labelColor: Colors.blueGrey.shade700,
        shortLabel: '—',
      );
  }
}
