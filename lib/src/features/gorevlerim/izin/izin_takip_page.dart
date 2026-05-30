import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import 'izin_provider.dart';

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Araçlar → İzin takip: İzinlerim'de başlatılan iznin geri sayımı, işe başlama
/// tarihi ve başlamadan 2 gün önce hatırlatma. Cihazda kalır.
class IzinTakipPage extends ConsumerWidget {
  const IzinTakipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(izinRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'İzin takip',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
          final aktif = izinAktifVeyaYaklasan(records);
          final upcoming = records
              .where((r) => !r.returnDate
                  .isBefore(DateTime.now().subtract(const Duration(days: 1))))
              .toList()
            ..sort((a, b) => a.startMs.compareTo(b.startMs));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              if (aktif == null)
                _EmptyState()
              else ...[
                _CountdownCard(record: aktif),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                const Text(
                  'Planlı / süren izinler',
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 10),
                for (final r in upcoming) _TakipTile(record: r),
              ],
              const SizedBox(height: 16),
              Text(
                'Hatırlatma bu sayfa açıkken gösterilir. İzin günleri İzinlerim '
                '(Görevlerim) bölümünden eklenir; veriler cihazda kalır.',
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
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PoliceColors.outlineMuted.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.beach_access_rounded,
            size: 40,
            color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aktif veya yaklaşan izin yok',
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Görevlerim → İzinlerim bölümünden "İzin başlat" ile bir izin '
            'oluştur; burada geri sayım ve işe başlama tarihi görünür.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.record});
  final LeaveRecord record;

  @override
  Widget build(BuildContext context) {
    final kalanBaslangic = izinBaslangicaKalanGun(record);
    final donuse = iseDonuseKalanGun(record);
    final basladi = kalanBaslangic <= 0;

    final String big;
    final String label;
    if (basladi) {
      big = '$donuse';
      label = 'gün sonra işe dönüş';
    } else {
      big = '$kalanBaslangic';
      label = 'gün sonra izin başlıyor';
    }

    final showReminder = !basladi && kalanBaslangic <= 2;

    return Column(
      children: [
        if (showReminder)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    kalanBaslangic == 0
                        ? 'Hatırlatma: İzniniz bugün başlıyor.'
                        : 'Hatırlatma: İzniniz $kalanBaslangic gün içinde '
                            'başlıyor (${_fmtDate(record.start)}).',
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (basladi ? Colors.green : PoliceColors.primaryBlue)
                    .withValues(alpha: 0.30),
                PoliceColors.surfaceDark,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (basladi ? Colors.green : PoliceColors.primaryBlue)
                  .withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    basladi ? Icons.flight_rounded : Icons.flight_takeoff_rounded,
                    color: PoliceColors.gold,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    basladi ? 'İzindesin' : record.type.label,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    big,
                    style: const TextStyle(
                      color: PoliceColors.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.95),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoRow(
                icon: Icons.event_available_rounded,
                text: 'Başlangıç: ${_fmtDate(record.start)}',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.event_busy_rounded,
                text: 'Toplam izinli: ${record.totalOffDays} gün'
                    '${record.roadDays > 0 ? ' (${record.days} izin + ${record.roadDays} yol)' : ''}',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.work_history_rounded,
                text: 'İşe başlama: ${_fmtDate(record.returnDate)}',
                strong: true,
              ),
              if (record.fromCity.isNotEmpty && record.toCity.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.alt_route_rounded,
                  text:
                      '${record.fromCity} → ${record.toCity}${record.km > 0 ? ' (~${record.km} km)' : ''}',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
        Icon(icon, size: 18, color: PoliceColors.primaryBlue.withValues(alpha: 0.95)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _TakipTile extends StatelessWidget {
  const _TakipTile({required this.record});
  final LeaveRecord record;

  @override
  Widget build(BuildContext context) {
    final kalan = izinBaslangicaKalanGun(record);
    final donuse = iseDonuseKalanGun(record);
    final basladi = kalan <= 0;
    final durum = basladi
        ? 'Sürüyor · dönüşe $donuse gün'
        : '$kalan gün sonra başlıyor';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PoliceColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PoliceColors.outlineMuted.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    basladi ? '$donuse' : '$kalan',
                    style: TextStyle(
                      color: basladi ? Colors.green : PoliceColors.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'gün',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.type.label} · ${_fmtDate(record.start)}',
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$durum · işe başlama ${_fmtDate(record.returnDate)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
