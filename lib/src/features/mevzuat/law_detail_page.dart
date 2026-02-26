import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/law_article.dart';
import 'law_article_provider.dart';
import 'law_search_controller.dart';

class LawDetailPage extends ConsumerStatefulWidget {
  final int articleId;

  const LawDetailPage({super.key, required this.articleId});

  @override
  ConsumerState<LawDetailPage> createState() => _LawDetailPageState();
}

class _LawDetailPageState extends ConsumerState<LawDetailPage> {
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(lawArticleProvider(widget.articleId));

    return Scaffold(
      appBar: AppBar(),
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Madde bulunamadı.'));
          }

          _noteController.text = article.userNote ?? '';

          final title =
              '${article.lawName} - Madde ${article.articleNumber.toString()}';

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
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        article.isFavorite
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: article.isFavorite
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                      onPressed: () async {
                        await toggleFavorite(article);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  article.lawCode,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  'Resmî Metin',
                  article.officialText,
                ),
                _buildSection(
                  context,
                  'Özet (Sade Dil)',
                  article.plainSummary,
                ),
                if (article.fieldExample != null &&
                    article.fieldExample!.trim().isNotEmpty)
                  _buildSection(
                    context,
                    'Saha Örneği',
                    article.fieldExample!,
                  ),
                if (article.commonMistakes != null &&
                    article.commonMistakes!.trim().isNotEmpty)
                  _buildSection(
                    context,
                    'Sık Yapılan Hatalar',
                    article.commonMistakes!,
                  ),
                if (article.sourceUrl != null)
                  _buildSection(
                    context,
                    'Kaynak',
                    article.sourceUrl!,
                  ),
                if (article.lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Son güncelleme: ${article.lastUpdated!.toLocal().toIso8601String().split("T").first}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Notun',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sadece senin görebileceğin notlar...',
                  ),
                  onChanged: (value) => updateNote(article, value),
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

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}

