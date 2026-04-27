import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants/app_disclaimer.dart';
import '../../common/theme/police_colors.dart';
import 'mevzuat_provider.dart';

class MevzuatArticleDetailPage extends ConsumerWidget {
  final String entryId;

  const MevzuatArticleDetailPage({super.key, required this.entryId});

  String _reviewLine(MevzuatDocumentData content, MevzuatSection s) {
    return s.lastReviewed ?? content.lastContentReview ?? '—';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(mevzuatEntryProvider(entryId));
    final contentAsync = ref.watch(mevzuatDocumentContentProvider(entryId));
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(entryId) ?? false;

    return entryAsync.when(
      data: (entry) {
        if (entry == null) {
          return Scaffold(
            backgroundColor: PoliceColors.mevzuatScreenBackground,
            appBar: AppBar(
              backgroundColor: PoliceColors.navy,
              foregroundColor: PoliceColors.mevzuatTitleGrey,
              title: const Text('Mevzuat'),
            ),
            body: const Center(
              child: Text(
                'Kayıt bulunamadı.',
                style: TextStyle(color: PoliceColors.mevzuatTitleGrey),
              ),
            ),
          );
        }
        return contentAsync.when(
          data: (content) {
            return Scaffold(
              backgroundColor: PoliceColors.mevzuatScreenBackground,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: PoliceColors.navy,
                    foregroundColor: PoliceColors.mevzuatTitleGrey,
                    leading: const BackButton(color: PoliceColors.mevzuatTitleGrey),
                    expandedHeight: 100,
                    shape: const Border(
                      bottom: BorderSide(color: PoliceColors.gold, width: 1.2),
                    ),
                    actions: [
                      IconButton(
                        tooltip:
                            isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
                        icon: Icon(
                          isFavorite
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: isFavorite
                              ? PoliceColors.gold
                              : PoliceColors.mevzuatTitleGrey,
                        ),
                        onPressed: () =>
                            mevzuatToggleFavorite(ref, entryId),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsetsDirectional.only(
                        start: 48,
                        end: 48,
                        bottom: 12,
                      ),
                      title: Text(
                        content.law,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: PoliceColors.mevzuatTitleGrey,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        entry.categoryLabel,
                        style: TextStyle(
                          color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (content.sections.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Bu kayıt için metin yüklenmedi.',
                          style: const TextStyle(
                            color: PoliceColors.mevzuatBodyText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= content.sections.length) {
                            if (index == content.sections.length) {
                              return _SourceFooter(content: content);
                            }
                            if (index == content.sections.length + 1) {
                              return _DisclaimerBlock();
                            }
                            return const SizedBox.shrink();
                          }
                          final s = content.sections[index];
                          return _ArticleSection(
                            section: s,
                            review: _reviewLine(content, s),
                            isLast: index == content.sections.length - 1,
                          );
                        },
                        childCount: content.sections.isEmpty
                            ? 0
                            : content.sections.length + 2,
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Scaffold(
            backgroundColor: PoliceColors.mevzuatScreenBackground,
            body: Center(
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
          error: (e, _) => Scaffold(
            backgroundColor: PoliceColors.mevzuatScreenBackground,
            body: Center(
              child: Text(
                'Hata: $e',
                style: const TextStyle(color: PoliceColors.mevzuatBodyText),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: PoliceColors.mevzuatScreenBackground,
        body: Center(
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
      error: (e, _) => Scaffold(
        backgroundColor: PoliceColors.mevzuatScreenBackground,
        body: Center(
          child: Text(
            'Hata: $e',
            style: const TextStyle(color: PoliceColors.mevzuatBodyText),
          ),
        ),
      ),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  const _ArticleSection({
    required this.section,
    required this.review,
    required this.isLast,
  });

  final MevzuatSection section;
  final String review;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            section.article.toUpperCase(),
            style: const TextStyle(
              color: PoliceColors.mevzuatNumberGold,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.title,
            style: const TextStyle(
              color: PoliceColors.mevzuatTitleGrey,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            section.text,
            style: const TextStyle(
              color: PoliceColors.mevzuatBodyText,
              height: 1.55,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kaynak: ${section.source}',
            style: TextStyle(
              color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Son kontrol: $review',
            style: TextStyle(
              color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.85),
              fontSize: 11.5,
            ),
          ),
          SizedBox(height: isLast ? 8 : 0),
          if (!isLast) ...[
            const SizedBox(height: 20),
            Divider(
              height: 1,
              thickness: 1,
              color: PoliceColors.mevzuatListBorder.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter({required this.content});

  final MevzuatDocumentData content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: PoliceColors.mevzuatListBorder,
          ),
          const SizedBox(height: 16),
          Text(
            'Kaynak: ${content.source}',
            style: TextStyle(
              color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            content.sourceUrl,
            style: TextStyle(
              color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.9),
              fontSize: 12.5,
            ),
          ),
          if (content.lastContentReview != null &&
              content.lastContentReview!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Belge son kontrol: ${content.lastContentReview}',
              style: TextStyle(
                color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.9),
                fontSize: 11.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DisclaimerBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Text(
        kAppFullDisclaimer,
        style: TextStyle(
          color: PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.9),
          height: 1.35,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
