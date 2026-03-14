import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/primary_card.dart';
import '../../data/models/mevzuat_article.dart';
import 'mevzuat_provider.dart';

class MevzuatArticleDetailPage extends ConsumerWidget {
  final String articleId;

  const MevzuatArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(mevzuatArticleProvider(articleId));
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(articleId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Madde Detayı'),
      ),
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Madde bulunamadı.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        article.displaySubtitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border_outlined,
                        color: isFavorite
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                      onPressed: () async {
                        await mevzuatToggleFavorite(ref, article.id);
                      },
                    ),
                  ],
                ),
                if (article.title.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                PrimaryCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      article.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kaynak: ${article.source}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://www.mevzuat.gov.tr',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'mevzuat.gov.tr',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
