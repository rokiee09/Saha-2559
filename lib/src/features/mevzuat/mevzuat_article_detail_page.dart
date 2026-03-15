import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/primary_card.dart';
import 'mevzuat_provider.dart';

class MevzuatArticleDetailPage extends ConsumerWidget {
  final String entryId;

  const MevzuatArticleDetailPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(mevzuatEntryProvider(entryId));
    final contentAsync = ref.watch(mevzuatDocumentContentProvider(entryId));
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(entryId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mevzuat Detayı'),
      ),
      body: entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Mevzuat kaydı bulunamadı.'));
          }
          return contentAsync.when(
            data: (content) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.displayTitle,
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
                            await mevzuatToggleFavorite(ref, entry.id);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.categoryLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (content.sections.isEmpty)
                      const PrimaryCard(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Bu mevzuat kaydi listede eklendi. Offline tam metin henüz eklenmemiş olabilir. Güncel ve resmî metin için aşağıdaki kaynağı kullanın.',
                          ),
                        ),
                      ),
                    ...content.sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PrimaryCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  section.article,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (section.title.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    section.title,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                SelectableText(
                                  section.text,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kaynak: ${content.source}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(content.sourceUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(
                        content.sourceUrl,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
