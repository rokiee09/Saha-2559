import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/routing/transitions.dart';
import '../../common/widgets/primary_card.dart';
import '../../data/models/mevzuat_article.dart';
import 'mevzuat_article_detail_page.dart';
import 'mevzuat_provider.dart';

const _disclaimerText =
    'Bu uygulamada yer alan mevzuatlar bilgilendirme amaçlıdır.\n'
    'Resmi ve güncel mevzuat için mevzuat.gov.tr referans alınmalıdır.';

class MevzuatPage extends ConsumerWidget {
  const MevzuatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mevzuatSearchTabProvider);
    final query = ref.watch(mevzuatSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mevzuat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _disclaimerText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _TabChip(
                      label: 'KANUNLAR',
                      selected: tab == MevzuatTab.kanunlar,
                      onTap: () =>
                          ref.read(mevzuatSearchTabProvider.notifier).state =
                              MevzuatTab.kanunlar,
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'YÖNETMELİKLER',
                      selected: tab == MevzuatTab.yonetmelikler,
                      onTap: () =>
                          ref.read(mevzuatSearchTabProvider.notifier).state =
                              MevzuatTab.yonetmelikler,
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'FAVORİ',
                      selected: tab == MevzuatTab.favoriler,
                      onTap: () =>
                          ref.read(mevzuatSearchTabProvider.notifier).state =
                              MevzuatTab.favoriler,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '🔎 Kanun adı, madde no veya kelime ara',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      ref.read(mevzuatSearchQueryProvider.notifier).state = v,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ref.watch(mevzuatSearchResultsProvider).when(
            data: (items) {
              if (items.isEmpty && query.trim().isNotEmpty) {
                return const Center(child: Text('Sonuç bulunamadı.'));
              }
              if (items.isEmpty && tab == MevzuatTab.favoriler) {
                return const Center(
                  child: Text(
                    'Henüz favori madde eklenmedi.\nMaddelere yıldız ile favori ekleyebilirsiniz.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final article = items[index];
                  return _MevzuatArticleTile(article: article);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
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
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _MevzuatArticleTile extends ConsumerWidget {
  final MevzuatArticle article;

  const _MevzuatArticleTile({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite = favoritesAsync.valueOrNull?.contains(article.id) ?? false;

    return PrimaryCard(
      onTap: () {
        Navigator.of(context).push(
          fadeRoute(MevzuatArticleDetailPage(articleId: article.id)),
        );
      },
      child: ListTile(
        title: Text(
          article.displaySubtitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.title.isNotEmpty)
              Text(
                article.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            Text(
              article.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite
                ? Theme.of(context).colorScheme.secondary
                : null,
          ),
          onPressed: () async {
            await mevzuatToggleFavorite(ref, article.id);
          },
        ),
      ),
    );
  }
}
