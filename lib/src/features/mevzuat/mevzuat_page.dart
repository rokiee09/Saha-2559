import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/routing/transitions.dart';
import '../../common/widgets/primary_card.dart';
import '../../data/models/law_article.dart';
import 'law_detail_page.dart';
import 'law_search_controller.dart';

class MevzuatPage extends ConsumerWidget {
  const MevzuatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(lawSearchResultsProvider);
    final query = ref.watch(lawSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mevzuat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Kanun adı, madde no veya kelime ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                isDense: true,
              ),
              onChanged: (value) =>
                  ref.read(lawSearchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: resultsAsync.when(
        data: (items) {
          if (items.isEmpty && query.isNotEmpty) {
            return const Center(child: Text('Sonuç bulunamadı.'));
          }
          if (items.isEmpty) {
            return const Center(
              child: Text('Son görüntülenen maddeler burada listelenecek.'),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final article = items[index];
              return _LawArticleTile(article: article);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class _LawArticleTile extends StatelessWidget {
  final LawArticle article;

  const _LawArticleTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${article.lawName} - Madde ${article.articleNumber.toString()}';

    return PrimaryCard(
      onTap: () async {
        await markArticleViewed(article);
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          fadeRoute(
            LawDetailPage(articleId: article.id),
          ),
        );
      },
      child: ListTile(
        title: Text(
          subtitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          article.plainSummary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          article.isFavorite ? Icons.star : Icons.star_border,
          color: article.isFavorite
              ? Theme.of(context).colorScheme.secondary
              : null,
        ),
      ),
    );
  }
}

