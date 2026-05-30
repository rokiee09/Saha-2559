import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/search_highlight.dart';
import '../asistan/asistan_provider.dart';
import '../home/root_drawer_scope.dart';
import 'mevzuat_article_detail_page.dart';
import 'mevzuat_law_hero_badge.dart';
import 'mevzuat_provider.dart';

Future<void> _mevzuatPullRefresh(WidgetRef ref) async {
  ref.invalidate(mevzuatCatalogProvider);
  ref.invalidate(mevzuatSearchResultsProvider);
  ref.invalidate(mevzuatRecentItemsProvider);
  ref.invalidate(mevzuatFavoritesProvider);
  await Future.wait([
    ref.read(mevzuatSearchResultsProvider.future),
    ref.read(mevzuatRecentItemsProvider.future),
  ]);
}

class MevzuatPage extends ConsumerStatefulWidget {
  const MevzuatPage({super.key});

  @override
  ConsumerState<MevzuatPage> createState() => _MevzuatPageState();
}

class _MevzuatPageState extends ConsumerState<MevzuatPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(mevzuatSearchTabProvider);
    final query = ref.watch(mevzuatSearchQueryProvider);
    final recentAsync = ref.watch(mevzuatRecentItemsProvider);
    final smartConcept = ref.watch(asistanConceptsProvider).maybeWhen(
          data: (cs) =>
              query.trim().isEmpty ? null : asistanMatchConcept(query, cs),
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: PoliceColors.mevzuatScreenBackground,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text('Mevzuat'),
        foregroundColor: PoliceColors.mevzuatTitleGrey,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PoliceColors.mevzuatTitleGrey,
        ),
        iconTheme: const IconThemeData(color: PoliceColors.mevzuatTitleGrey),
        shape: Border(
          bottom: BorderSide(
            color: PoliceColors.accentMix(0.34),
            width: 1,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ref.watch(mevzuatSearchResultsProvider).when(
            data: (items) {
              final trimmedQuery = query.trim();
              Widget scrollChild;

              if (items.isEmpty && trimmedQuery.isNotEmpty) {
                scrollChild = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (smartConcept != null)
                      SliverToBoxAdapter(
                        child: _SmartConceptCard(concept: smartConcept),
                      ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            smartConcept != null
                                ? 'Kanun adında doğrudan eşleşme yok; yukarıdaki akıllı sonuçtan ilgili maddeye gidebilirsin.'
                                : 'Sonuç bulunamadı.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: PoliceColors.mevzuatTitleGrey,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (items.isEmpty && tab == MevzuatTab.favoriler) {
                scrollChild = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Favori kayıt yok.',
                          style: TextStyle(color: PoliceColors.mevzuatTitleGrey),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (items.isEmpty) {
                scrollChild = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: PoliceColors.gold,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                final showGrouping =
                    tab == MevzuatTab.kanunlar && trimmedQuery.isEmpty;

                scrollChild = CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _heroFade,
                        child: SlideTransition(
                          position: _heroSlide,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Mevzuat Merkezi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.35,
                                    color: PoliceColors.mevzuatBodyText,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Polis mevzuatına hızlı erişim',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: PoliceColors.mevzuatMetaGrey
                                        .withValues(alpha: 0.95),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: PoliceColors.gold
                                        .withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 520),
                                    child: TextField(
                                      onChanged: (v) => ref
                                          .read(mevzuatSearchQueryProvider
                                              .notifier)
                                          .state = v,
                                      style: const TextStyle(
                                        color: PoliceColors.mevzuatBodyText,
                                        fontSize: 16,
                                      ),
                                      cursorColor:
                                          PoliceColors.mevzuatTitleGrey,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Madde ara… (kanun adı, numara, kısa ad)',
                                        hintStyle: TextStyle(
                                          color: PoliceColors.mevzuatMetaGrey
                                              .withValues(alpha: 0.9),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: PoliceColors.mevzuatListCard,
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          color: PoliceColors.primaryBlue
                                              .withValues(alpha: 0.92),
                                          size: 26,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                            color:
                                                PoliceColors.mevzuatListBorder,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: const BorderSide(
                                            color:
                                                PoliceColors.mevzuatListBorder,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: PoliceColors.primaryBlue
                                                .withValues(alpha: 0.65),
                                            width: 1.4,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 4),
                                    child: _MevzuatSearchHints(
                                      trimmedQuery: trimmedQuery,
                                      filteredEntries: items,
                                      onPick: (picked) => ref
                                          .read(mevzuatSearchQueryProvider
                                              .notifier)
                                          .state = picked,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (smartConcept != null)
                      SliverToBoxAdapter(
                        child: _SmartConceptCard(concept: smartConcept),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _TabChip(
                                label: 'Kanunlar',
                                selected: tab == MevzuatTab.kanunlar,
                                onTap: () => ref
                                    .read(mevzuatSearchTabProvider.notifier)
                                    .state = MevzuatTab.kanunlar,
                              ),
                              const SizedBox(width: 8),
                              _TabChip(
                                label: 'Yönetmelikler',
                                selected: tab == MevzuatTab.yonetmelikler,
                                onTap: () => ref
                                    .read(mevzuatSearchTabProvider.notifier)
                                    .state = MevzuatTab.yonetmelikler,
                              ),
                              const SizedBox(width: 8),
                              _TabChip(
                                label: 'Favoriler',
                                selected: tab == MevzuatTab.favoriler,
                                onTap: () => ref
                                    .read(mevzuatSearchTabProvider.notifier)
                                    .state = MevzuatTab.favoriler,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (tab == MevzuatTab.kanunlar && trimmedQuery.isEmpty)
                      recentAsync.when(
                        data: (recent) {
                          if (recent.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: SizedBox.shrink(),
                            );
                          }
                          return SliverToBoxAdapter(
                            child: _RecentBlock(items: recent),
                          );
                        },
                        loading: () =>
                            const SliverToBoxAdapter(child: SizedBox.shrink()),
                        error: (_, __) =>
                            const SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),
                    if (showGrouping)
                      ..._buildGroupedKanunSlivers(
                        items,
                        trimmedQuery.isNotEmpty ? trimmedQuery : null,
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _MevzuatLawCard(
                                entry: items[index],
                                animationIndex: index,
                                highlightQuery: trimmedQuery.isNotEmpty
                                    ? trimmedQuery
                                    : null,
                              );
                            },
                            childCount: items.length,
                          ),
                        ),
                      ),
                  ],
                );
              }

              return RefreshIndicator(
                color: PoliceColors.primaryBlue,
                backgroundColor: PoliceColors.surfaceDarkElevated,
                onRefresh: () => _mevzuatPullRefresh(ref),
                child: scrollChild,
              );
            },
            loading: () => const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: PoliceColors.gold,
                      strokeWidth: 2,
                    ),
                  ),
                ),
            error: (e, _) => Center(
                  child: Text(
                    'Hata: $e',
                    style: const TextStyle(color: PoliceColors.mevzuatBodyText),
                  ),
                ),
          ),
        ),
    );
  }

  List<Widget> _buildGroupedKanunSlivers(
    List<MevzuatEntry> items,
    String? highlightQuery,
  ) {
    final split = _splitPopularRest(items);
    final popular = split.$1;
    final others = split.$2;
    var globalIndex = 0;

    final children = <Widget>[
      SliverToBoxAdapter(
        child: _SectionHeader(
          icon: Icons.star_rounded,
          title: 'En çok kullanılanlar',
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final idx = globalIndex++;
              return _MevzuatLawCard(
                entry: popular[i],
                animationIndex: idx,
                highlightQuery: highlightQuery,
              );
            },
            childCount: popular.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: _SectionHeader(
          icon: Icons.menu_book_rounded,
          title: 'Diğer kanunlar',
          subtitle:
              'Örnek: ${kanunHighlightedOtherExamples.join(", ")} ve diğerleri',
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final idx = globalIndex++;
              return _MevzuatLawCard(
                entry: others[i],
                animationIndex: idx,
                highlightQuery: highlightQuery,
              );
            },
            childCount: others.length,
          ),
        ),
      ),
    ];

    return children;
  }
}

/// (popular ordered, others sorted)
(List<MevzuatEntry>, List<MevzuatEntry>) _splitPopularRest(
  List<MevzuatEntry> kanunlar,
) {
  final byCode = <String, MevzuatEntry>{};
  for (final k in kanunlar) {
    final c = k.code;
    if (c != null && c.isNotEmpty) {
      byCode.putIfAbsent(c, () => k);
    }
  }
  final popular = <MevzuatEntry>[];
  for (final code in kanunPopularCodesOrdered) {
    final e = byCode[code];
    if (e != null) {
      popular.add(e);
    }
  }
  final popularIds = popular.map((e) => e.id).toSet();
  final others = kanunlar
      .where((k) => !popularIds.contains(k.id))
      .toList()
    ..sort((a, b) {
      final ca = a.code ?? '';
      final cb = b.code ?? '';
      return ca.compareTo(cb);
    });
  return (popular, others);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PoliceColors.gold.withValues(alpha: 0.9), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                    color: PoliceColors.mevzuatTitleGrey,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.9),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PoliceColors.accentMix(0.48),
                  PoliceColors.accentMix(0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentBlock extends StatelessWidget {
  const _RecentBlock({required this.items});

  final List<MevzuatRecentItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: PoliceColors.accentMix(0.42).withValues(alpha: 0.55),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: PoliceColors.gold.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Son görüntülenenler',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: PoliceColors.mevzuatBodyText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final r in items.take(5)) ...[
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      fadeRoute(MevzuatArticleDetailPage(entryId: r.entry.id)),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  splashColor: PoliceColors.gold.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          r.entry.code ?? '—',
                          style: const TextStyle(
                            color: PoliceColors.mevzuatNumberGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          ' / ',
                          style: TextStyle(
                            color: PoliceColors.mevzuatMetaGrey,
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            r.maddeLabel,
                            style: const TextStyle(
                              color: PoliceColors.mevzuatTitleGrey,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PoliceColors.mevzuatListCard
          : PoliceColors.mevzuatScreenBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: PoliceColors.gold.withValues(alpha: 0.08),
        highlightColor: PoliceColors.gold.withValues(alpha: 0.04),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? PoliceColors.accentMix(0.5).withValues(alpha: 0.65)
                  : PoliceColors.mevzuatListBorder.withValues(alpha: 0.35),
              width: selected ? 1 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? PoliceColors.mevzuatBodyText
                      : PoliceColors.mevzuatMetaGrey,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: selected ? 2 : 2,
                width: selected ? 32 : 22,
                decoration: BoxDecoration(
                  color: selected
                      ? PoliceColors.accentMix(0.62)
                      : PoliceColors.accentMix(0.22).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MevzuatLawCard extends ConsumerWidget {
  final MevzuatEntry entry;
  final int animationIndex;
  final String? highlightQuery;

  const _MevzuatLawCard({
    required this.entry,
    required this.animationIndex,
    this.highlightQuery,
  });

  Widget _maybeHighlight(String text, TextStyle base) {
    final hq = highlightQuery?.trim();
    if (hq == null || hq.isEmpty) {
      return Text(text, style: base);
    }
    return Text.rich(
      TextSpan(
        children: highlightTextSpans(text: text, query: hq, baseStyle: base),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaAsync = ref.watch(mevzuatEntryMetaProvider(entry.id));
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite = favoritesAsync.valueOrNull?.contains(entry.id) ?? false;

    final lawLine = entry.code != null && entry.code!.isNotEmpty
        ? '${entry.code}'
        : entry.catalogTag;
    final subLine = entry.name;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 380 + math.min(animationIndex, 18) * 28,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: PoliceColors.mevzuatListCard,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: PoliceColors.accentMix(0.4).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                fadeRoute(MevzuatArticleDetailPage(entryId: entry.id)),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: PoliceColors.accentMix(0.58),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: mevzuatLawHeroTag(entry.id),
                            child: MevzuatLawHeroBadge(
                              category: entry.category,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PoliceColors.gold
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: PoliceColors.accentMix(0.45)
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Text(
                                    entry.categoryLabel.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.9,
                                      color: PoliceColors.gold
                                          .withValues(alpha: 0.82),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _maybeHighlight(
                                  lawLine,
                                  const TextStyle(
                                    color: PoliceColors.mevzuatNumberGold,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _maybeHighlight(
                                  subLine,
                                  const TextStyle(
                                    color: PoliceColors.mevzuatTitleGrey,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 1.5,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: PoliceColors.accentMix(0.38)
                                        .withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                metaAsync.when(
                                  data: (m) {
                                    return Text(
                                      'Toplam madde: ${m.maddeCount}',
                                      style: const TextStyle(
                                        color: PoliceColors.mevzuatMetaGrey,
                                        fontSize: 12.5,
                                        height: 1.3,
                                      ),
                                    );
                                  },
                                  loading: () => const Text(
                                    'Yükleniyor…',
                                    style: TextStyle(
                                      color: PoliceColors.mevzuatMetaGrey,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: isFavorite
                                ? 'Favorilerden çıkar'
                                : 'Favorilere ekle',
                            icon: Icon(
                              isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isFavorite
                                  ? PoliceColors.gold
                                  : PoliceColors.mevzuatMetaGrey,
                              size: 22,
                            ),
                            onPressed: () async {
                              await HapticFeedback.lightImpact();
                              final nowFavorite =
                                  await mevzuatToggleFavorite(ref, entry.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    nowFavorite
                                        ? 'Favorilere eklendi'
                                        : 'Favorilerden çıkarıldı',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Akıllı Mevzuat: kavram eşleşince çok-kanunlu ilgili maddeleri gösterir.
class _SmartConceptCard extends ConsumerWidget {
  const _SmartConceptCard({required this.concept});

  final AsistanConcept concept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(mevzuatCatalogProvider).valueOrNull;
    final entryIds = <String>{
      if (catalog != null)
        for (final e in [...catalog.kanunlar, ...catalog.yonetmelikler]) e.id,
    };
    final refs = concept.refs
        .where((r) => entryIds.isEmpty || entryIds.contains(r.entryId))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: PoliceColors.gold.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Akıllı sonuç · ${concept.label}',
                    style: const TextStyle(
                      color: PoliceColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              concept.answer,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.95),
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
            if (refs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'İlgili kanunlar',
                style: TextStyle(
                  color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in refs)
                    _SmartRefChip(
                      label: r.label,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          fadeRoute(
                            MevzuatArticleDetailPage(
                              entryId: r.entryId,
                              focusSectionId: r.sectionId,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmartRefChip extends StatelessWidget {
  const _SmartRefChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.mevzuatListCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: PoliceColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _defaultSearchSuggestions = [
  'yakalama süresi',
  'kimlik sorma',
  'üst arama',
];

class _MevzuatSearchHints extends StatelessWidget {
  const _MevzuatSearchHints({
    required this.trimmedQuery,
    required this.filteredEntries,
    required this.onPick,
  });

  final String trimmedQuery;
  final List<MevzuatEntry> filteredEntries;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (trimmedQuery.isEmpty) {
      for (final s in _defaultSearchSuggestions) {
        chips.add(_SearchPickChip(label: s, onTap: () => onPick(s)));
      }
    } else {
      for (final e in filteredEntries.take(8)) {
        var label = e.displayTitle;
        if (label.length > 44) {
          label = '${label.substring(0, 44)}…';
        }
        chips.add(
          _SearchPickChip(
            label: label,
            onTap: () => onPick(e.displayTitle),
          ),
        );
      }
      if (chips.isEmpty) {
        return const SizedBox.shrink();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trimmedQuery.isEmpty ? 'Hızlı arama' : 'Önerilen kayıtlar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: chips,
        ),
      ],
    );
  }
}

class _SearchPickChip extends StatelessWidget {
  const _SearchPickChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.mevzuatScreenBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: PoliceColors.primaryBlue.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PoliceColors.mevzuatListBorder.withValues(alpha: 0.65),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: PoliceColors.mevzuatBodyText,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
