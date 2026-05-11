import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../common/constants/app_branding.dart';
import '../../common/theme/police_colors.dart';
import '../mevzuat/mevzuat_provider.dart';
import '../saha/saha_categories.dart';
import '../saha/saha_category_page.dart';
import '../saha/saha_store.dart';

enum DashboardModule { mevzuat, teskilat, haklar, kultur }

/// Ana “dashboard”: hızlı erişim, günün maddesi.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.onContinueReading,
    required this.onOpenModule,
    required this.onOpenGununMaddesi,
    required this.onOpenFavorites,
  });

  final VoidCallback onContinueReading;
  final void Function(DashboardModule module) onOpenModule;
  final ValueChanged<String> onOpenGununMaddesi;
  final VoidCallback onOpenFavorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(mevzuatCatalogProvider);
    final hasRecentToContinue = ref.watch(mevzuatRecentItemsProvider).maybeWhen(
          data: (list) => list.isNotEmpty,
          orElse: () => false,
        );
    final recentAsync = ref.watch(mevzuatRecentItemsProvider);

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 3,
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            PoliceColors.primaryBlue,
                            PoliceColors.gold.withValues(alpha: 0.88),
                          ],
                        ),
                      ),
                    ),
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
                        onOpenEntry: onOpenGununMaddesi,
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
                  const _SahaLocalGridSection(),
                  const SizedBox(height: 20),
                  Text(
                    kDashboardChannelsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SectorCard(
                          icon: PhosphorIconsRegular.bookBookmark,
                          title: 'Mevzuat',
                          subtitle: 'Kanun ve yönetmelikler',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenModule(DashboardModule.mevzuat);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SectorCard(
                          icon: PhosphorIconsRegular.scales,
                          title: 'Haklar',
                          subtitle: 'Özet haklar ve araçlar',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenModule(DashboardModule.haklar);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SectorCard(
                          icon: PhosphorIconsRegular.buildings,
                          title: 'Teşkilat',
                          subtitle: 'Yapı ve birimler',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenModule(DashboardModule.teskilat);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SectorCard(
                          icon: PhosphorIconsRegular.palette,
                          title: 'Kültür',
                          subtitle: 'Tarih ve tören',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOpenModule(DashboardModule.kultur);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  catalogAsync.when(
                    loading: () => const SizedBox(height: 120),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (cat) => _GununMaddesiCard(
                      catalog: cat,
                      onTapEntry: onOpenGununMaddesi,
                    ),
                  ),
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

class _SahaLocalGridSection extends ConsumerWidget {
  const _SahaLocalGridSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(sahaNotesProvider);
    final counts = notesAsync.maybeWhen(
      data: (notes) {
        final m = <String, int>{};
        for (final n in notes) {
          m.update(n.categoryId, (c) => c + 1, ifAbsent: () => 1);
        }
        return m;
      },
      orElse: () => <String, int>{},
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PoliceColors.primaryBlue.withValues(alpha: 0.28),
            PoliceColors.surfaceDark.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kSahaHubTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            kSahaHubSubtitle,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.92),
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final n = c.maxWidth >= 340 ? 4 : 3;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: n,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.74,
                children: [
                  for (final cat in SahaCategoryDef.all)
                    _SahaGridTile(
                      category: cat,
                      noteCount: counts[cat.id] ?? 0,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SahaGridTile extends StatelessWidget {
  const _SahaGridTile({
    required this.category,
    required this.noteCount,
  });

  final SahaCategoryDef category;
  final int noteCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SahaCategoryPage(categoryId: category.id),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.25),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  PhosphorIcon(
                    category.icon,
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                    size: 26,
                  ),
                  if (noteCount > 0)
                    Positioned(
                      right: -10,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: PoliceColors.primaryBlue,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          noteCount > 99 ? '99+' : '$noteCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                noteCount == 0 ? 'Kayıt yok' : '$noteCount kayıt',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: noteCount > 0
                      ? PoliceColors.primaryBlue.withValues(alpha: 0.85)
                      : PoliceColors.textMuted.withValues(alpha: 0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
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

class _SectorCard extends StatefulWidget {
  const _SectorCard({
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
  State<_SectorCard> createState() => _SectorCardState();
}

class _SectorCardState extends State<_SectorCard> {
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

class _GununMaddesiCard extends StatelessWidget {
  const _GununMaddesiCard({
    required this.catalog,
    required this.onTapEntry,
  });

  final MevzuatCatalog catalog;
  final ValueChanged<String> onTapEntry;

  @override
  Widget build(BuildContext context) {
    final kanunlar = catalog.kanunlar;
    if (kanunlar.isEmpty) return const SizedBox.shrink();

    final daySeed = DateTime.now().difference(DateTime(2020)).inDays;
    final pick = kanunlar[daySeed % kanunlar.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTapEntry(pick.id);
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
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pick.displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kDailyPickSubtitle,
                style: TextStyle(
                  color: PoliceColors.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Aç →',
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
