import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import 'il_mesafe.dart';
import 'izin_provider.dart';

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// İzinlerim: yıllık izin + yol izni durumu (batarya göstergesi), geçen yıldan
/// devir (manuel), izin başlatma (nereden-nereye → yol izni + işe başlama).
/// Cihazda kalır, resmî kayıt değildir.
class IzinPage extends ConsumerWidget {
  const IzinPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(izinRecordsProvider);
    final serviceYears = ref.watch(hizmetYiliProvider).valueOrNull ?? 0;
    final devir = ref.watch(izinDevirProvider).valueOrNull ?? (yillik: 0, yol: 0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'İzinlerim',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openStartSheet(context, ref, serviceYears, devir),
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.flight_takeoff_rounded, color: Colors.white),
        label: const Text(
          'İzin başlat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: recordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Kayıtlar okunamadı.',
            style: TextStyle(color: PoliceColors.titleOnDark),
          ),
        ),
        data: (records) {
          final now = DateTime.now();
          final durum = computeYillikDurum(
            records: records,
            serviceYears: serviceYears,
            devirYillik: devir.yillik,
            devirYol: devir.yol,
            year: now.year,
          );
          final used = izinUsedByType(records);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
            children: [
              _CurrentYearCard(
                durum: durum,
                serviceYears: serviceYears,
                onEditYears: () =>
                    _openServiceYearsSheet(context, ref, serviceYears),
              ),
              const SizedBox(height: 12),
              _DevirCard(
                year: now.year - 1,
                devir: devir,
                onEdit: () => _openDevirSheet(context, ref, devir),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Türe göre kullanılan'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final t in LeaveType.values)
                    _UsedChip(label: t.label, days: used[t] ?? 0),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const _SectionLabel('İzin kayıtları'),
                  const Spacer(),
                  Text(
                    '${records.length} kayıt',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (records.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Henüz izin kaydı yok. Sağ alttan "İzin başlat" ile '
                    'tarih ve gün seç; yol izni ve işe başlama otomatik hesaplanır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                )
              else
                for (final r in records)
                  _RecordTile(
                    record: r,
                    onDelete: () async => izinDeleteRecord(ref, r.id),
                  ),
              const SizedBox(height: 16),
              Text(
                'Bu sayfa kişisel takip içindir; girilen günler resmî kayıt '
                'değildir. Yıllık izin 657 sayılı DMK md. 102 esas alınır '
                '(10 yıldan az: 20 gün, 10 yıl ve üzeri: 30 gün) + $kYolIzniYillik gün yol izni. '
                'Yol izni mesafesi tahminîdir; kesin gün ve mesafe kurum işlemine bağlıdır.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 11.5,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Hizmet yılı
  // -------------------------------------------------------------------------
  void _openServiceYearsSheet(BuildContext context, WidgetRef ref, int current) {
    final controller =
        TextEditingController(text: current > 0 ? '$current' : '');
    _showSheet(
      context,
      title: 'Hizmet yılı',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yıllık izin hakkını belirler (10 yıl ve üzeri → 30 gün).',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: const InputDecoration(
              labelText: 'Yıl',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                final v = int.tryParse(controller.text.trim()) ?? 0;
                await izinSaveHizmetYili(ref, v);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Geçen yıldan devir (manuel)
  // -------------------------------------------------------------------------
  void _openDevirSheet(BuildContext context, WidgetRef ref, IzinDevir devir) {
    final yillikC =
        TextEditingController(text: devir.yillik > 0 ? '${devir.yillik}' : '');
    final yolC =
        TextEditingController(text: devir.yol > 0 ? '${devir.yol}' : '');
    _showSheet(
      context,
      title: '${DateTime.now().year - 1} yılından devir',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uygulamayı ilk kez kuruyorsan geçen yıldan kalan günleri buraya '
            'gir. Bu yılın hakkına eklenir.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: yillikC,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: const InputDecoration(
              labelText: 'Kalan yıllık izin (gün)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: yolC,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: const InputDecoration(
              labelText: 'Kalan yol izni (gün)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                final y = int.tryParse(yillikC.text.trim()) ?? 0;
                final yol = int.tryParse(yolC.text.trim()) ?? 0;
                await izinSaveDevir(ref, y, yol);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // İzin başlat
  // -------------------------------------------------------------------------
  void _openStartSheet(
    BuildContext context,
    WidgetRef ref,
    int serviceYears,
    IzinDevir devir,
  ) {
    LeaveType type = LeaveType.yillik;
    DateTime start = DateTime.now();
    final daysC = TextEditingController();
    final noteC = TextEditingController();
    String? fromCity;
    String? toCity;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PoliceColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            final days = int.tryParse(daysC.text.trim()) ?? 0;
            final isYillik = type == LeaveType.yillik;
            final km = (isYillik && fromCity != null && toCity != null)
                ? ilMesafeKm(fromCity!, toCity!)
                : 0;
            final roadDays = isYillik ? yolIzniGunu(km) : 0;
            final totalOff = days + roadDays;
            final returnDate = DateTime(start.year, start.month, start.day)
                .add(Duration(days: totalOff));

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                18 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İzin başlat',
                    style: TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<LeaveType>(
                    value: type,
                    dropdownColor: PoliceColors.surfaceDarkElevated,
                    decoration: const InputDecoration(
                      labelText: 'İzin türü',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: PoliceColors.titleOnDark),
                    items: [
                      for (final t in LeaveType.values)
                        DropdownMenuItem(value: t, child: Text(t.label)),
                    ],
                    onChanged: (v) => setS(() => type = v ?? type),
                  ),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Başlangıç tarihi',
                    value: start,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: start,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 2),
                      );
                      if (picked != null) setS(() => start = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: daysC,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: PoliceColors.titleOnDark),
                    decoration: const InputDecoration(
                      labelText: 'İzin gün sayısı',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setS(() {}),
                  ),
                  if (isYillik) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Yol izni (nereden → nereye)',
                      style: TextStyle(
                        color: PoliceColors.titleOnDark.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _CityDropdown(
                            label: 'Nereden',
                            value: fromCity,
                            onChanged: (v) => setS(() => fromCity = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CityDropdown(
                            label: 'Nereye',
                            value: toCity,
                            onChanged: (v) => setS(() => toCity = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _StartPreview(
                    days: days,
                    roadDays: roadDays,
                    km: km,
                    returnDate: returnDate,
                    showRoad: isYillik,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteC,
                    style: const TextStyle(color: PoliceColors.titleOnDark),
                    decoration: const InputDecoration(
                      labelText: 'Not (isteğe bağlı)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (days <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Geçerli bir gün sayısı girin.'),
                            ),
                          );
                          return;
                        }
                        final startDay =
                            DateTime(start.year, start.month, start.day);
                        await izinAddRecord(
                          ref,
                          LeaveRecord(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            type: type,
                            days: days,
                            roadDays: roadDays,
                            startMs: startDay.millisecondsSinceEpoch,
                            dateMs: DateTime.now().millisecondsSinceEpoch,
                            fromCity: fromCity ?? '',
                            toCity: toCity ?? '',
                            km: km,
                            note: noteC.text.trim(),
                          ),
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Kaydet ve takibe ekle'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

void _showSheet(BuildContext context,
    {required String title, required Widget child}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PoliceColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          18 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
    },
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: PoliceColors.titleOnDark,
        fontWeight: FontWeight.w800,
        fontSize: 15.5,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Batarya göstergesi
// ---------------------------------------------------------------------------

Color _batteryColor(double ratio) {
  if (ratio >= 0.6) {
    return Color.lerp(const Color(0xFF8BC34A), const Color(0xFF2E7D32),
        (ratio - 0.6) / 0.4)!;
  }
  if (ratio >= 0.3) {
    return Color.lerp(const Color(0xFFFF9800), const Color(0xFFCDDC39),
        (ratio - 0.3) / 0.3)!;
  }
  return Color.lerp(const Color(0xFFE53935), const Color(0xFFFF9800),
      (ratio / 0.3).clamp(0.0, 1.0))!;
}

class _LeaveBatteryBar extends StatelessWidget {
  const _LeaveBatteryBar({required this.ratio});
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final r = ratio.clamp(0.0, 1.0);
    final color = _batteryColor(r);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 22,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 2,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: r == 0 ? 0.02 : r,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 2),
          width: 4,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bu yıl kartı
// ---------------------------------------------------------------------------

class _CurrentYearCard extends StatelessWidget {
  const _CurrentYearCard({
    required this.durum,
    required this.serviceYears,
    required this.onEditYears,
  });

  final YillikIzinDurum durum;
  final int serviceYears;
  final VoidCallback onEditYears;

  @override
  Widget build(BuildContext context) {
    final kalan = durum.kalanYillik;
    final color = _batteryColor(durum.yillikRatio);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PoliceColors.primaryBlue.withValues(alpha: 0.30),
            PoliceColors.surfaceDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PoliceColors.primaryBlue.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${durum.yil} yıllık izin',
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEditYears,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(serviceYears > 0 ? '$serviceYears yıl' : 'Hizmet yılı'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$kalan',
                style: TextStyle(
                  color: kalan < 0 ? Colors.redAccent : color,
                  fontWeight: FontWeight.w900,
                  fontSize: 42,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  'gün kaldı',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LeaveBatteryBar(ratio: durum.yillikRatio),
          const SizedBox(height: 8),
          Text(
            'Hak ${durum.hakYillik} + devir ${durum.devirYillik} = '
            '${durum.toplamYillik} gün · kullanılan ${durum.kullanilanYillik} gün',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.95),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alt_route_rounded,
                  size: 18,
                  color: PoliceColors.gold.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yol izni: kalan ${durum.kalanYol} / ${durum.toplamYol} gün',
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  'kullanılan ${durum.kullanilanYol}',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12,
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

// ---------------------------------------------------------------------------
// Devir kartı
// ---------------------------------------------------------------------------

class _DevirCard extends StatelessWidget {
  const _DevirCard({
    required this.year,
    required this.devir,
    required this.onEdit,
  });

  final int year;
  final IzinDevir devir;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final empty = devir.yillik == 0 && devir.yol == 0;
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: PoliceColors.gold.withValues(alpha: 0.9),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$year yılından devir',
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      empty
                          ? 'İlk kurulumda geçen yıldan kalanı gir (dokun).'
                          : 'Kalan: ${devir.yillik} gün yıllık · ${devir.yol} gün yol',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// İzin başlat — yardımcı alanlar
// ---------------------------------------------------------------------------

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          _fmtDate(value),
          style: const TextStyle(
            color: PoliceColors.titleOnDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: PoliceColors.surfaceDarkElevated,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      style: const TextStyle(color: PoliceColors.titleOnDark, fontSize: 14),
      items: [
        for (final ad in kIlAdlariAlfabetik)
          DropdownMenuItem(value: ad, child: Text(ad)),
      ],
      onChanged: onChanged,
    );
  }
}

class _StartPreview extends StatelessWidget {
  const _StartPreview({
    required this.days,
    required this.roadDays,
    required this.km,
    required this.returnDate,
    required this.showRoad,
  });

  final int days;
  final int roadDays;
  final int km;
  final DateTime returnDate;
  final bool showRoad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showRoad)
            _PreviewRow(
              icon: Icons.alt_route_rounded,
              text: km > 0
                  ? 'Mesafe ~$km km → $roadDays gün yol izni'
                  : 'İl seçilince yol izni hesaplanır (>600 km: 4, ≤600 km: 2)',
            ),
          if (showRoad) const SizedBox(height: 8),
          _PreviewRow(
            icon: Icons.event_busy_rounded,
            text: 'Toplam izinli: ${days + roadDays} gün'
                '${showRoad && roadDays > 0 ? ' ($days izin + $roadDays yol)' : ''}',
          ),
          const SizedBox(height: 8),
          _PreviewRow(
            icon: Icons.work_history_rounded,
            text: days > 0
                ? 'İşe başlama: ${_fmtDate(returnDate)}'
                : 'Gün gir → işe başlama tarihi hesaplanır',
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.icon,
    required this.text,
    this.strong = false,
  });

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: PoliceColors.gold.withValues(alpha: 0.95)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _UsedChip extends StatelessWidget {
  const _UsedChip({required this.label, required this.days});

  final String label;
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PoliceColors.outlineMuted.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$days g',
            style: const TextStyle(
              color: PoliceColors.primaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onDelete});

  final LeaveRecord record;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final hasRoute = r.fromCity.isNotEmpty && r.toCity.isNotEmpty;
    final sub = StringBuffer(_fmtDate(r.start));
    if (hasRoute) {
      sub.write(' · ${r.fromCity}→${r.toCity}');
      if (r.roadDays > 0) sub.write(' (+${r.roadDays} yol)');
    }
    if (r.note.isNotEmpty) sub.write(' · ${r.note}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          color: PoliceColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PoliceColors.outlineMuted.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${r.days} g',
                style: const TextStyle(
                  color: PoliceColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.type.label,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sil',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                await onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
