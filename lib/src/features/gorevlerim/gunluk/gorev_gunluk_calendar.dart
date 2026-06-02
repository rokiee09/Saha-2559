import 'package:flutter/material.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_gunluk_models.dart';
import 'gorev_gunluk_stats.dart';
const _weekdays = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

/// Ay takvimi — görev olan günler işaretlenir.
class GorevGunlukCalendar extends StatefulWidget {
  const GorevGunlukCalendar({
    super.key,
    required this.kayitlar,
    required this.onDayTap,
    this.initialMonth,
  });

  final List<GorevGunlukKayit> kayitlar;
  final void Function(DateTime day, List<GorevGunlukKayit> dayKayitlar) onDayTap;
  final DateTime? initialMonth;

  @override
  State<GorevGunlukCalendar> createState() => _GorevGunlukCalendarState();
}

class _GorevGunlukCalendarState extends State<GorevGunlukCalendar> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final d = widget.initialMonth ?? DateTime.now();
    _year = d.year;
    _month = d.month;
  }

  Set<int> get _busyDays {
    final s = <int>{};
    for (final k in widget.kayitlar) {
      if (k.tarih.year == _year && k.tarih.month == _month) {
        s.add(k.tarih.day);
      }
    }
    return s;
  }

  void _prev() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _next() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_year, _month, 1).weekday;
    final leading = firstWeekday - 1;
    final lastDay = DateTime(_year, _month + 1, 0).day;
    final busy = _busyDays;
    final monthKayit = kayitlarForMonth(widget.kayitlar, _year, _month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _prev,
              icon: const Icon(Icons.chevron_left_rounded,
                  color: PoliceColors.titleOnDark),
            ),
            Expanded(
              child: Text(
                '${kAyAdlari[_month].toUpperCase()} $_year',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
              onPressed: _next,
              icon: const Icon(Icons.chevron_right_rounded,
                  color: PoliceColors.titleOnDark),
            ),
          ],
        ),
        if (monthKayit.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${monthKayit.length} görev · '
              '${formatSaat(monthKayit.fold<double>(0, (s, e) => s + e.sureSaat))} saat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 12.5,
              ),
            ),
          ),
        Row(
          children: [
            for (final w in _weekdays)
              Expanded(
                child: Text(
                  w,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: leading + lastDay,
          itemBuilder: (_, index) {
            if (index < leading) return const SizedBox.shrink();
            final day = index - leading + 1;
            final has = busy.contains(day);
            final isToday = _year == DateTime.now().year &&
                _month == DateTime.now().month &&
                day == DateTime.now().day;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: has
                    ? () {
                        final d = DateTime(_year, _month, day);
                        widget.onDayTap(
                          d,
                          kayitlarForDay(widget.kayitlar, d),
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: has
                        ? PoliceColors.primaryBlue.withValues(alpha: 0.22)
                        : PoliceColors.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: PoliceColors.gold, width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: has
                              ? PoliceColors.titleOnDark
                              : PoliceColors.textMuted.withValues(alpha: 0.6),
                          fontWeight:
                              has ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (has)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: PoliceColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
