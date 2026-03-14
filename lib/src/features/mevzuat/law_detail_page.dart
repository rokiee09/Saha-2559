import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

          final officialText = article.officialText.trim().isNotEmpty
              ? article.officialText
              : article.plainSummary.trim().isNotEmpty
                  ? article.plainSummary
                  : 'Bu madde için resmî metin henüz eklenmemiş.';
          final plainSummary = article.plainSummary.trim().isNotEmpty
              ? article.plainSummary
              : 'Bu madde için özet henüz eklenmemiş.';

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
                  officialText,
                ),
                _buildSection(
                  context,
                  'Özet (Sade Dil)',
                  plainSummary,
                ),
                _buildSection(
                  context,
                  'Saha Örneği',
                  article.fieldExample?.trim().isEmpty ?? true
                      ? 'Saha örneği eklenmemiş.'
                      : article.fieldExample!,
                ),
                _buildSection(
                  context,
                  'Sık Yapılan Hatalar',
                  article.commonMistakes?.trim().isEmpty ?? true
                      ? 'Bu madde için sık hatalar listesi eklenmemiş.'
                      : article.commonMistakes!,
                ),
                if (article.sourceUrl != null &&
                    article.sourceUrl!.trim().isNotEmpty)
                  _buildSourceLink(context, article.sourceUrl!),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceLink(BuildContext context, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kaynak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              url,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
