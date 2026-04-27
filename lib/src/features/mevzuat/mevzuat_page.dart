import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../home/root_drawer_scope.dart';
import 'mevzuat_article_detail_page.dart';
import 'mevzuat_provider.dart';

class MevzuatPage extends ConsumerWidget {
  const MevzuatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mevzuatSearchTabProvider);
    final query = ref.watch(mevzuatSearchQueryProvider);

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
        shape: const Border(
          bottom: BorderSide(color: PoliceColors.gold, width: 1.2),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _TabChip(
                      label: 'Kanunlar',
                      selected: tab == MevzuatTab.kanunlar,
                      onTap: () =>
                          ref.read(mevzuatSearchTabProvider.notifier).state =
                              MevzuatTab.kanunlar,
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Yönetmelikler',
                      selected: tab == MevzuatTab.yonetmelikler,
                      onTap: () =>
                          ref.read(mevzuatSearchTabProvider.notifier).state =
                              MevzuatTab.yonetmelikler,
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Favoriler',
                      selected: tab == MevzuatTab.favoriler,
                      onTap: () =>
                          ref.read(mevzuatSearchTabProvider.notifier).state =
                              MevzuatTab.favoriler,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: TextField(
                  onChanged: (v) =>
                      ref.read(mevzuatSearchQueryProvider.notifier).state = v,
                  style: const TextStyle(
                    color: PoliceColors.mevzuatBodyText,
                    fontSize: 15,
                  ),
                  cursorColor: PoliceColors.mevzuatTitleGrey,
                  decoration: InputDecoration(
                    hintText: 'Madde ara… (kanun adı, numara, kısa ad)',
                    hintStyle: TextStyle(
                      color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.9),
                    ),
                    filled: true,
                    fillColor: PoliceColors.mevzuatListCard,
                    prefixIcon: Icon(
                      Icons.search,
                      color: PoliceColors.gold.withValues(alpha: 0.85),
                      size: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PoliceColors.mevzuatListBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PoliceColors.mevzuatListBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: PoliceColors.gold.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ref.watch(mevzuatSearchResultsProvider).when(
            data: (items) {
              if (items.isEmpty && query.trim().isNotEmpty) {
                return const Center(
                  child: Text(
                    'Sonuç bulunamadı.',
                    style: TextStyle(color: PoliceColors.mevzuatTitleGrey),
                  ),
                );
              }
              if (items.isEmpty && tab == MevzuatTab.favoriler) {
                return const Center(
                  child: Text(
                    'Favori kayıt yok.',
                    style: TextStyle(color: PoliceColors.mevzuatTitleGrey),
                  ),
                );
              }
              if (items.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: PoliceColors.gold,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _LawCard(entry: items[index]);
                },
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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? PoliceColors.gold
                    : PoliceColors.mevzuatListBorder.withValues(alpha: 0.4),
                width: selected ? 2 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? PoliceColors.mevzuatBodyText
                  : PoliceColors.mevzuatMetaGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class _LawCard extends ConsumerWidget {
  final MevzuatEntry entry;

  const _LawCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaAsync = ref.watch(mevzuatEntryMetaProvider(entry.id));
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite = favoritesAsync.valueOrNull?.contains(entry.id) ?? false;
    final codeLine = entry.code != null && entry.code!.isNotEmpty
        ? '${entry.code}  ·  ${entry.catalogTag}'
        : entry.catalogTag;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: Material(
        color: PoliceColors.mevzuatListCard,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              fadeRoute(MevzuatArticleDetailPage(entryId: entry.id)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PoliceColors.mevzuatListBorder, width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 26,
                  color: PoliceColors.gold.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (codeLine.isNotEmpty)
                        Text(
                          codeLine,
                          style: const TextStyle(
                            color: PoliceColors.mevzuatNumberGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            letterSpacing: 0.25,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        entry.name,
                        style: const TextStyle(
                          color: PoliceColors.mevzuatTitleGrey,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      metaAsync.when(
                        data: (m) {
                          final madde = m.maddeCount;
                          final last = m.lastReview ?? '—';
                          return Text(
                            'Madde: $madde  ·  Son güncelleme: $last',
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
                      const SizedBox(height: 4),
                      Text(
                        entry.categoryLabel,
                        style: TextStyle(
                          color: PoliceColors.mevzuatMetaGrey
                              .withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite
                        ? PoliceColors.gold
                        : PoliceColors.mevzuatMetaGrey,
                    size: 22,
                  ),
                  onPressed: () => mevzuatToggleFavorite(ref, entry.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
