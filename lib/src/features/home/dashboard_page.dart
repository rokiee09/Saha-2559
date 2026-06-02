import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/constants/app_branding.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/police_siren_accent_bar.dart';
import '../gorevlerim/izin/izin_provider.dart';
import '../gorevlerim/kariyer/widgets/gazi_tesekkur_kart.dart';
import '../gorevlerim/kariyer/widgets/personel_ozet_kart.dart';
import '../haklar/vardiya/vardiya_cycle_calculator.dart';
import '../haklar/vardiya/vardiya_today_provider.dart';
import '../mevzuat/mevzuat_provider.dart';

/// Madde aç: opsiyonel [sectionId] verilirse o maddeye derin link.
typedef OpenMaddeCallback = void Function(String entryId, {String? sectionId});

/// Ana sayfa: günlük işe yarayanlar — son baktığın madde, hızlı geçişler,
/// izin durumu ve günün seçkisi. Az kart, net akış.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.onContinueReading,
    required this.onOpenGununMaddesi,
    required this.onOpenFavorites,
    required this.onOpenAsistan,
    required this.onOpenIzin,
    required this.onOpenVardiya,
    required this.onOpenMevzuat,
    required this.onOpenProfilim,
  });

  final VoidCallback onContinueReading;
  final OpenMaddeCallback onOpenGununMaddesi;
  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenAsistan;
  final VoidCallback onOpenIzin;
  final VoidCallback onOpenVardiya;
  final VoidCallback onOpenMevzuat;
  final VoidCallback onOpenProfilim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRecentToContinue = ref.watch(mevzuatRecentItemsProvider).maybeWhen(
          data: (list) => list.isNotEmpty,
          orElse: () => false,
        );
    final recentAsync = ref.watch(mevzuatRecentItemsProvider);

    final izinRecords =
        ref.watch(izinRecordsProvider).valueOrNull ?? const <LeaveRecord>[];
    final serviceYears = ref.watch(hizmetYiliProvider).valueOrNull ?? 0;
    final izinDevir =
        ref.watch(izinDevirProvider).valueOrNull ?? (yillik: 0, yol: 0);
    final izinDurum = computeYillikDurum(
      records: izinRecords,
      serviceYears: serviceYears,
      devirYillik: izinDevir.yillik,
      devirYol: izinDevir.yol,
    );
    final kalanYillik = izinDurum.kalanYillik;
    final izinSubtitle = serviceYears <= 0
        ? 'İzin günlerini takip et'
        : (kalanYillik >= 0
            ? '$kalanYillik gün yıllık izin kaldı'
            : 'Yıllık izin aşıldı');

    final vardiyaToday = ref.watch(vardiyaTodayProvider).valueOrNull;
    final upcomingLeave =
        izinRecords.isEmpty ? null : izinAktifVeyaYaklasan(izinRecords);

    return ColoredBox(
      color: PoliceColors.backgroundDark,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    kAppDisplayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: PoliceSirenAccentBar(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kAppTagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PoliceColors.textMuted,
                          height: 1.42,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const GaziTesekkurKart(),
                  PersonelOzetKart(onTap: onOpenProfilim),
                  _DutyTodayPanel(
                    vardiya: vardiyaToday,
                    leave: upcomingLeave,
                    onOpenVardiya: onOpenVardiya,
                    onOpenIzin: onOpenIzin,
                  ),
                  const SizedBox(height: 20),
                  if (hasRecentToContinue) ...[
                    _ActionPill(
                      icon: PhosphorIconsRegular.playCircle,
                      label: 'Devam et',
                      subtitle: kContinueReadingSubtitle,
                      color: PoliceColors.primaryBlue,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onContinueReading();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 20),
                  recentAsync.when(
                    data: (recent) {
                      if (recent.isEmpty) return const SizedBox.shrink();
                      return _DashboardRecentStrip(
                        items: recent,
                        onOpenEntry: (id) => onOpenGununMaddesi(id),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onOpenFavorites();
                      },
                      icon: PhosphorIcon(
                        PhosphorIconsRegular.bookmarkSimple,
                        color: PoliceColors.primaryBlue,
                        size: 20,
                      ),
                      label: const Text(
                        kFavoritesShortcutLabel,
                        style: TextStyle(
                          color: PoliceColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hızlı geçiş',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HomeQuickCard(
                          icon: PhosphorIconsRegular.sparkle,
                          title: 'Çalışma Asistanı',
                          subtitle: 'Senaryo · mevzuat rehberi',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenAsistan();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HomeQuickCard(
                          icon: PhosphorIconsRegular.bookBookmark,
                          title: 'Mevzuat',
                          subtitle: 'Kanun ve yönetmelik',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenMevzuat();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HomeQuickCard(
                          icon: PhosphorIconsRegular.calendarBlank,
                          title: 'İzinlerim',
                          subtitle: izinSubtitle,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenIzin();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HomeQuickCard(
                          icon: PhosphorIconsRegular.calendarCheck,
                          title: 'Vardiyam',
                          subtitle: 'Vardiya türünü seç',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenVardiya();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _GununMaddesiCard(onTapEntry: onOpenGununMaddesi),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dp2(int v) => v.toString().padLeft(2, '0');
String _hhmm(DateTime d) => '${_dp2(d.hour)}:${_dp2(d.minute)}';
String _ddmm(DateTime d) => '${_dp2(d.day)}.${_dp2(d.month)}';

String _humanDuration(Duration d) {
  if (d.isNegative) return '0 dk';
  if (d.inHours < 1) return '${d.inMinutes} dk';
  if (d.inHours < 24) {
    final mins = d.inMinutes % 60;
    return mins == 0 ? '${d.inHours} sa' : '${d.inHours} sa $mins dk';
  }
  return '${d.inDays} gün';
}

/// "Bugün görevdeyim" paneli: bugünkü vardiya + kalan süre + yaklaşan izin.
class _DutyTodayPanel extends StatelessWidget {
  const _DutyTodayPanel({
    required this.vardiya,
    required this.leave,
    required this.onOpenVardiya,
    required this.onOpenIzin,
  });

  final VardiyaTodayStatus? vardiya;
  final LeaveRecord? leave;
  final VoidCallback onOpenVardiya;
  final VoidCallback onOpenIzin;

  ({String title, String detail, IconData icon, Color color}) _vardiyaLine() {
    final v = vardiya;
    final now = DateTime.now();
    if (v == null) {
      return (
        title: 'Vardiya seçili değil',
        detail: 'Vardiya türünü seç',
        icon: PhosphorIconsRegular.calendarPlus,
        color: PoliceColors.textMuted,
      );
    }
    if (!v.configured) {
      return (
        title: v.title,
        detail: 'Referans tarihi seç',
        icon: PhosphorIconsRegular.calendarPlus,
        color: PoliceColors.textMuted,
      );
    }
    if (v.phased) {
      final active = v.active;
      if (active != null) {
        final rem = active.end.difference(now);
        return (
          title: active.night ? 'Gece nöbeti' : 'Gündüz nöbeti',
          detail: 'Şu an görevde · bitiş ${_hhmm(active.end)} '
              '(≈${_humanDuration(rem)})',
          icon: active.night ? PhosphorIconsFill.moon : PhosphorIconsFill.sun,
          color: active.night ? const Color(0xFF9C8CF0) : PoliceColors.gold,
        );
      }
      final next = v.next;
      if (next != null) {
        final rem = next.start.difference(now);
        return (
          title: next.night ? 'Sıradaki: gece' : 'Sıradaki: gündüz',
          detail: '${_ddmm(next.start)} ${_hhmm(next.start)} '
              'başlıyor (≈${_humanDuration(rem)} sonra)',
          icon: PhosphorIconsRegular.clock,
          color: PoliceColors.primaryBlue,
        );
      }
      return (
        title: v.title,
        detail: 'Yaklaşan nöbet bulunamadı',
        icon: PhosphorIconsRegular.calendarCheck,
        color: PoliceColors.textMuted,
      );
    }
    // Basit kalıp düzen.
    final kind = v.todayKind;
    final isWork = kind == VardiyaCalendarDayKind.work;
    return (
      title: isWork ? 'Bugün görev günü' : 'Bugün dinlenme',
      detail: v.title,
      icon:
          isWork ? PhosphorIconsFill.shieldCheck : PhosphorIconsRegular.coffee,
      color: isWork ? PoliceColors.gold : PoliceColors.primaryBlue,
    );
  }

  ({String title, String detail}) _leaveLine() {
    final r = leave;
    if (r == null) {
      return (title: 'Yaklaşan izin yok', detail: 'İzin planla');
    }
    final toStart = izinBaslangicaKalanGun(r);
    if (toStart > 0) {
      final yer = r.toCity.isNotEmpty ? ' · ${r.toCity}' : '';
      return (
        title: '${r.type.label} yaklaşıyor',
        detail: '${_ddmm(r.start)} başlıyor · $toStart gün kaldı$yer',
      );
    }
    final toReturn = iseDonuseKalanGun(r);
    return (
      title: 'İzindesin',
      detail: 'İşe dönüş ${_ddmm(r.returnDate)} · $toReturn gün kaldı',
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _vardiyaLine();
    final l = _leaveLine();
    return Container(
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIconsFill.shieldStar,
                color: PoliceColors.gold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Bugün görevdeyim',
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _DutyRow(
            icon: v.icon,
            iconColor: v.color,
            title: v.title,
            detail: v.detail,
            onTap: onOpenVardiya,
          ),
          Divider(
            height: 1,
            color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
          ),
          _DutyRow(
            icon: PhosphorIconsRegular.airplaneTilt,
            iconColor: leave == null
                ? PoliceColors.textMuted
                : PoliceColors.primaryBlue,
            title: l.title,
            detail: l.detail,
            onTap: onOpenIzin,
          ),
          Divider(
            height: 1,
            color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
          ),
          const _DutyRow(
            icon: PhosphorIconsRegular.mapPinLine,
            iconColor: PoliceColors.textMuted,
            title: 'Tayin dönemi',
            detail: 'Veri eklenince aktif olacak',
          ),
        ],
      ),
    );
  }
}

class _DutyRow extends StatelessWidget {
  const _DutyRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.detail,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            PhosphorIcon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      color: PoliceColors.textMuted,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                color: PoliceColors.textMuted.withValues(alpha: 0.7),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: PhosphorIcon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: PoliceColors.textMuted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                color: PoliceColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeQuickCard extends StatefulWidget {
  const _HomeQuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_HomeQuickCard> createState() => _HomeQuickCardState();
}

class _HomeQuickCardState extends State<_HomeQuickCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: PoliceColors.surfaceDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorIcon(
                widget.icon,
                color: PoliceColors.primaryBlue,
                size: 34,
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: PoliceColors.textMuted,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GununMaddesiCard extends ConsumerWidget {
  const _GununMaddesiCard({required this.onTapEntry});

  final OpenMaddeCallback onTapEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maddeAsync = ref.watch(gununMaddesiProvider);
    final madde = maddeAsync.valueOrNull;
    if (madde == null) return const SizedBox.shrink();

    final code = madde.entry.code;
    final lawLabel = (code != null && code.trim().isNotEmpty)
        ? '$code · ${madde.entry.name}'
        : madde.entry.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTapEntry(madde.entry.id, sectionId: madde.section.id);
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PoliceColors.primaryBlue.withValues(alpha: 0.35),
                PoliceColors.surfaceDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.sparkle,
                    color: PoliceColors.primaryBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    kDailyPickTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PoliceColors.primaryBlue.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '30 sn özet',
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lawLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PoliceColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                madde.maddeLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                madde.ozet,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PoliceColors.textMuted,
                  fontSize: 13,
                  height: 1.42,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tam metni aç →',
                  style: TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardRecentStrip extends StatelessWidget {
  const _DashboardRecentStrip({
    required this.items,
    required this.onOpenEntry,
  });

  final List<MevzuatRecentItem> items;
  final ValueChanged<String> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final slice = items.length > 12 ? items.sublist(0, 12) : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.clockCounterClockwise,
              color: PoliceColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              kRecentStripTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: slice.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final r = slice[i];
              return _RecentMiniCard(
                code: r.entry.code ?? '',
                maddeLabel: r.maddeLabel,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onOpenEntry(r.entry.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentMiniCard extends StatelessWidget {
  const _RecentMiniCard({
    required this.code,
    required this.maddeLabel,
    required this.onTap,
  });

  final String code;
  final String maddeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 168,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PoliceColors.surfaceDark,
                PoliceColors.surfaceDarkElevated.withValues(alpha: 0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code.isEmpty ? '—' : code,
                style: const TextStyle(
                  color: PoliceColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  maddeLabel,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
