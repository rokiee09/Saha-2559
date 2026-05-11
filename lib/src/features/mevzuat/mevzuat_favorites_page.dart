import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import 'mevzuat_article_detail_page.dart';
import 'mevzuat_law_hero_badge.dart';
import 'mevzuat_provider.dart';

/// Tam favori listesi — çekmece kısayollarına ek olarak tam ekran erişim.
class MevzuatFavoritesPage extends ConsumerWidget {
  const MevzuatFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(mevzuatFavoritesProvider);
    final catalogAsync = ref.watch(mevzuatCatalogProvider);

    return Scaffold(
      backgroundColor: PoliceColors.mevzuatScreenBackground,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.mevzuatTitleGrey,
        title: const Text('Favoriler'),
        shape: Border(
          bottom: BorderSide(
            color: PoliceColors.accentMix(0.34),
            width: 1,
          ),
        ),
      ),
      body: favAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: PoliceColors.primaryBlue,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Favoriler yüklenemedi.',
            style: TextStyle(color: PoliceColors.mevzuatBodyText),
          ),
        ),
        data: (ids) => catalogAsync.when(
          loading: () => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: PoliceColors.primaryBlue,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => const Center(
            child: Text(
              'Katalog okunamadı.',
              style: TextStyle(color: PoliceColors.mevzuatBodyText),
            ),
          ),
          data: (cat) {
            if (ids.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Henüz favori yok.\nMevzuat listesinden yer işaretine dokunarak ekleyebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }
            final all = [...cat.kanunlar, ...cat.yonetmelikler];
            final map = {for (final e in all) e.id: e};
            final entries = ids
                .map((id) => map[id])
                .whereType<MevzuatEntry>()
                .toList()
              ..sort((a, b) => a.displayTitle.compareTo(b.displayTitle));

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = entries[i];
                final code = e.code ?? '';
                return Material(
                  color: PoliceColors.mevzuatListCard,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: PoliceColors.accentMix(0.38).withValues(alpha: 0.45),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        fadeRoute(MevzuatArticleDetailPage(entryId: e.id)),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          Hero(
                            tag: mevzuatLawHeroTag(e.id),
                            child: MevzuatLawHeroBadge(category: e.category),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (code.isNotEmpty)
                                  Text(
                                    code,
                                    style: const TextStyle(
                                      color: PoliceColors.mevzuatNumberGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                if (code.isNotEmpty) const SizedBox(height: 6),
                                Text(
                                  e.displayTitle,
                                  style: const TextStyle(
                                    color: PoliceColors.mevzuatTitleGrey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  e.categoryLabel,
                                  style: TextStyle(
                                    color: PoliceColors.mevzuatMetaGrey
                                        .withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.85),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
