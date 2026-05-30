import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/constants/app_disclaimer.dart';
import '../../common/text/tr_text.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/search_highlight.dart';
import 'mevzuat_law_hero_badge.dart';
import 'mevzuat_provider.dart';

/// Belge okuma kipi: Özet (kısa) veya Tam Metin (tümü açık).
enum DocReadMode { ozet, tamMetin }

class MevzuatArticleDetailPage extends ConsumerStatefulWidget {
  const MevzuatArticleDetailPage({
    super.key,
    required this.entryId,
    this.focusSectionId,
  });

  final String entryId;

  /// Asistan/akıllı arama "Kaynağa Git" ile gelindiğinde açılacak madde.
  final String? focusSectionId;

  @override
  ConsumerState<MevzuatArticleDetailPage> createState() =>
      _MevzuatArticleDetailPageState();
}

class _MevzuatArticleDetailPageState
    extends ConsumerState<MevzuatArticleDetailPage> {
  String _inPageQuery = '';
  bool _comfortReading = false;
  bool _deepNight = false;
  DocReadMode _readMode = DocReadMode.ozet;
  String? _focusSectionId;

  @override
  void initState() {
    super.initState();
    _focusSectionId = widget.focusSectionId;
    // Belirli bir maddeye yönlendirildiyse tam metni göster (kısaltma yok).
    if (_focusSectionId != null) {
      _readMode = DocReadMode.tamMetin;
    }
  }

  String _reviewLine(MevzuatDocumentData content, MevzuatSection s) {
    return s.lastReviewed ?? content.lastContentReview ?? '—';
  }

  MevzuatSection? _focusSection(MevzuatDocumentData content) {
    final id = _focusSectionId;
    if (id == null) return null;
    for (final s in content.sections) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<MevzuatSection> _filteredSections(MevzuatDocumentData content) {
    final q = trFold(_inPageQuery.trim());
    if (q.isEmpty) {
      // Derin link: sadece hedef madde gösterilir ("Tüm metin" ile açılır.)
      final focus = _focusSection(content);
      if (focus != null) return [focus];
      return content.sections;
    }
    return content.sections
        .where(
          (s) =>
              trFold(s.article).contains(q) ||
              trFold(s.title).contains(q) ||
              trFold(s.text).contains(q),
        )
        .toList();
  }

  void _showInPageSearchSheet() {
    final controller = TextEditingController(text: _inPageQuery);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PoliceColors.mevzuatListCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Metinde ara',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: PoliceColors.mevzuatTitleGrey,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: PoliceColors.mevzuatBodyText),
                cursorColor: PoliceColors.gold,
                decoration: InputDecoration(
                  hintText: 'Kelime, madde numarası veya başlık…',
                  hintStyle: TextStyle(
                    color:
                        PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.85),
                  ),
                  filled: true,
                  fillColor: PoliceColors.mevzuatScreenBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (v) {
                  setState(() {
                    _inPageQuery = v;
                    _focusSectionId = null;
                  });
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _inPageQuery = '');
                      Navigator.pop(ctx);
                    },
                    child: const Text('Temizle'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _inPageQuery = controller.text;
                        _focusSectionId = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Ara'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _friendlyErrorBody(String userMessage, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: PoliceColors.gold.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              userMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PoliceColors.mevzuatBodyText,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Yeniden dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(mevzuatEntryProvider(widget.entryId));
    final contentAsync =
        ref.watch(mevzuatDocumentContentProvider(widget.entryId));
    final favoritesAsync = ref.watch(mevzuatFavoritesProvider);
    final isFavorite =
        favoritesAsync.valueOrNull?.contains(widget.entryId) ?? false;

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
            final filtered = _filteredSections(content);
            final q = _inPageQuery.trim();
            final showSearchBanner = q.isNotEmpty;
            final focusSection = _focusSection(content);
            final showFocusBanner = focusSection != null && q.isEmpty;
            final scaffoldBg = _deepNight
                ? PoliceColors.readerNightBackground
                : PoliceColors.mevzuatScreenBackground;
            final appBarBg = _deepNight
                ? PoliceColors.readerNightSurface
                : PoliceColors.navy;
            final cmkBoost = widget.entryId == mevzuatCmkCatalogEntryId;

            return Scaffold(
              backgroundColor: scaffoldBg,
              body: SafeArea(
                top: false,
                bottom: true,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: appBarBg,
                          foregroundColor: PoliceColors.mevzuatTitleGrey,
                          leading: const BackButton(
                            color: PoliceColors.mevzuatTitleGrey,
                          ),
                          expandedHeight: 100,
                          shape: Border(
                            bottom: BorderSide(
                              color: PoliceColors.accentMix(0.34),
                              width: 1,
                            ),
                          ),
                          actions: [
                            IconButton(
                              tooltip: 'Metinde ara',
                              icon: Icon(
                                Icons.search_rounded,
                                color: _inPageQuery.isNotEmpty
                                    ? PoliceColors.primaryBlue
                                    : PoliceColors.mevzuatTitleGrey,
                              ),
                              onPressed: _showInPageSearchSheet,
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
                                    : PoliceColors.mevzuatTitleGrey,
                              ),
                              onPressed: () async {
                                await HapticFeedback.lightImpact();
                                final nowFavorite = await mevzuatToggleFavorite(
                                  ref,
                                  widget.entryId,
                                );
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
                            PopupMenuButton<String>(
                              tooltip: 'Diğer işlemler',
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: PoliceColors.mevzuatTitleGrey,
                              ),
                              color: PoliceColors.mevzuatListCard,
                              surfaceTintColor: Colors.transparent,
                              onSelected: (value) async {
                                switch (value) {
                                  case 'share':
                                    await _shareMevzuatDocument(content);
                                    break;
                                  case 'copy':
                                    await _copyFirstMevzuatSection(
                                      context,
                                      content,
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(
                                  value: 'share',
                                  child: Text('Paylaş'),
                                ),
                                PopupMenuItem(
                                  value: 'copy',
                                  child: Text('İlk maddeyi kopyala'),
                                ),
                              ],
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: false,
                            titlePadding:
                                const EdgeInsetsDirectional.only(
                              start: 48,
                              end: 48,
                              bottom: 12,
                            ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Hero(
                                  tag: mevzuatLawHeroTag(widget.entryId),
                                  child: MevzuatLawHeroBadge(
                                    category: entry.category,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    content.law,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      height: 1.22,
                                      color: PoliceColors.mevzuatTitleGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              entry.categoryLabel,
                              style: TextStyle(
                                color: PoliceColors.mevzuatMetaGrey
                                    .withValues(alpha: 0.95),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: SegmentedButton<DocReadMode>(
                              showSelectedIcon: false,
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                textStyle: const WidgetStatePropertyAll(
                                  TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                foregroundColor: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      states.contains(WidgetState.selected)
                                          ? PoliceColors.titleOnDark
                                          : PoliceColors.mevzuatMetaGrey,
                                ),
                                backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      states.contains(WidgetState.selected)
                                          ? PoliceColors.primaryBlue
                                              .withValues(alpha: 0.28)
                                          : Colors.transparent,
                                ),
                                side: WidgetStatePropertyAll(
                                  BorderSide(
                                    color: PoliceColors.outlineMuted
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                              segments: const [
                                ButtonSegment(
                                  value: DocReadMode.ozet,
                                  label: Text('Özet'),
                                  icon: Icon(Icons.short_text_rounded, size: 18),
                                ),
                                ButtonSegment(
                                  value: DocReadMode.tamMetin,
                                  label: Text('Tam Metin'),
                                  icon: Icon(Icons.notes_rounded, size: 18),
                                ),
                              ],
                              selected: {_readMode},
                              onSelectionChanged: (s) =>
                                  setState(() => _readMode = s.first),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  selected: _comfortReading,
                                  showCheckmark: true,
                                  checkmarkColor: PoliceColors.primaryBlue,
                                  selectedColor: PoliceColors.primaryBlue
                                      .withValues(alpha: 0.22),
                                  label: const Text('Okuma modu'),
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: _comfortReading
                                        ? PoliceColors.titleOnDark
                                        : PoliceColors.mevzuatTitleGrey,
                                  ),
                                  onSelected: (v) =>
                                      setState(() => _comfortReading = v),
                                  side: BorderSide(
                                    color: PoliceColors.outlineMuted
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                FilterChip(
                                  selected: _deepNight,
                                  showCheckmark: true,
                                  checkmarkColor: PoliceColors.primaryBlue,
                                  selectedColor: PoliceColors.primaryBlue
                                      .withValues(alpha: 0.22),
                                  label: const Text('Gece+'),
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: _deepNight
                                        ? PoliceColors.titleOnDark
                                        : PoliceColors.mevzuatTitleGrey,
                                  ),
                                  onSelected: (v) =>
                                      setState(() => _deepNight = v),
                                  side: BorderSide(
                                    color: PoliceColors.outlineMuted
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showFocusBanner)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Material(
                                color: PoliceColors.gold.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location_rounded,
                                        size: 18,
                                        color: PoliceColors.gold,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${focusSection.article} gösteriliyor.',
                                          style: const TextStyle(
                                            color: PoliceColors.mevzuatBodyText,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => setState(
                                          () => _focusSectionId = null,
                                        ),
                                        child: const Text('Tüm metin'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (showSearchBanner)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Material(
                                color: PoliceColors.primaryBlue
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          filtered.isEmpty
                                              ? '"$q" için eşleşen madde yok.'
                                              : '${filtered.length} madde gösteriliyor.',
                                          style: const TextStyle(
                                            color:
                                                PoliceColors.mevzuatBodyText,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => setState(
                                          () => _inPageQuery = '',
                                        ),
                                        child: const Text('Tümü'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (content.sections.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Bu kayıt için metin yüklenmedi.',
                                style: TextStyle(
                                  color: PoliceColors.mevzuatBodyText,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else if (filtered.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Arama kriterine uyan madde yok. Farklı bir kelime deneyin veya "Tümü" ile sıfırlayın.',
                                style: TextStyle(
                                  color: PoliceColors.mevzuatMetaGrey
                                      .withValues(alpha: 0.95),
                                  fontSize: 15,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= filtered.length) {
                                  if (index == filtered.length) {
                                    return _SourceFooter(content: content);
                                  }
                                  if (index == filtered.length + 1) {
                                    return _DisclaimerBlock();
                                  }
                                  return const SizedBox.shrink();
                                }
                                final s = filtered[index];
                                return _ArticleSection(
                                  key: ValueKey(
                                    '${s.id}-${_readMode.name}',
                                  ),
                                  entryId: widget.entryId,
                                  section: s,
                                  review: _reviewLine(content, s),
                                  isLast: index == filtered.length - 1,
                                  highlightQuery: q,
                                  comfortReading: _comfortReading,
                                  deepNight: _deepNight,
                                  cmkReadingBoost: cmkBoost,
                                  summaryMode: _readMode == DocReadMode.ozet,
                                );
                              },
                              childCount: filtered.length + 2,
                            ),
                          ),
                      ],
                    ),
                    IgnorePointer(
                      child: _MevzuatRecentRecorder(
                        entryId: widget.entryId,
                        content: content,
                      ),
                    ),
                  ],
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
            appBar: AppBar(
              backgroundColor: PoliceColors.navy,
              foregroundColor: PoliceColors.mevzuatTitleGrey,
              title: const Text('Mevzuat'),
            ),
            body: _friendlyErrorBody(
              'Metin yüklenirken bir sorun oluştu. İnternet gerekmez; tekrar deneyebilirsiniz.',
              onRetry: () => ref.invalidate(
                mevzuatDocumentContentProvider(widget.entryId),
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
        appBar: AppBar(
          backgroundColor: PoliceColors.navy,
          foregroundColor: PoliceColors.mevzuatTitleGrey,
          title: const Text('Mevzuat'),
        ),
        body: _friendlyErrorBody(
          'Kayıt bilgisi alınamadı. Tekrar deneyin.',
          onRetry: () =>
              ref.invalidate(mevzuatEntryProvider(widget.entryId)),
        ),
      ),
    );
  }
}

class _MevzuatRecentRecorder extends ConsumerStatefulWidget {
  const _MevzuatRecentRecorder({
    required this.entryId,
    required this.content,
  });

  final String entryId;
  final MevzuatDocumentData content;

  @override
  ConsumerState<_MevzuatRecentRecorder> createState() =>
      _MevzuatRecentRecorderState();
}

class _MevzuatRecentRecorderState extends ConsumerState<_MevzuatRecentRecorder> {
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordOnce());
  }

  void _recordOnce() {
    if (_recorded || !mounted) return;
    final secs = widget.content.sections;
    if (secs.isEmpty) return;
    _recorded = true;
    mevzuatRecordRecent(ref, widget.entryId, secs.first.article);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ArticleSection extends ConsumerWidget {
  const _ArticleSection({
    super.key,
    required this.entryId,
    required this.section,
    required this.review,
    required this.isLast,
    required this.highlightQuery,
    required this.comfortReading,
    required this.deepNight,
    required this.cmkReadingBoost,
    required this.summaryMode,
  });

  final String entryId;
  final MevzuatSection section;
  final String review;
  final bool isLast;
  final String highlightQuery;
  final bool comfortReading;
  final bool deepNight;
  final bool cmkReadingBoost;
  final bool summaryMode;

  Future<void> _openNoteEditor(BuildContext context, WidgetRef ref) async {
    final map = await ref.read(mevzuatSectionNotesMapProvider.future);
    final noteStorageKey = mevzuatSectionNoteStorageKey(entryId, section.id);
    final initial = map[noteStorageKey] ?? '';
    final controller = TextEditingController(text: initial);

    try {
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PoliceColors.mevzuatListCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kişisel not',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: PoliceColors.mevzuatTitleGrey,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Yalnızca bu cihazda saklanır; hukuki sonuç doğurmaz.',
                style: TextStyle(
                  color:
                      PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 5,
                style: const TextStyle(color: PoliceColors.mevzuatBodyText),
                cursorColor: PoliceColors.gold,
                decoration: InputDecoration(
                  hintText: 'Notunuzu yazın…',
                  hintStyle: TextStyle(
                    color:
                        PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.8),
                  ),
                  filled: true,
                  fillColor: PoliceColors.mevzuatScreenBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await mevzuatSaveSectionNote(
                        ref,
                        entryId,
                        section.id,
                        '',
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not silindi.')),
                        );
                      }
                    },
                    child: const Text('Sil'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      await mevzuatSaveSectionNote(
                        ref,
                        entryId,
                        section.id,
                        controller.text,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not kaydedildi.')),
                        );
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(mevzuatSectionNotesMapProvider);
    final noteKey = mevzuatSectionNoteStorageKey(entryId, section.id);
    final hasNote = notesAsync.maybeWhen(
      data: (m) => (m[noteKey] ?? '').trim().isNotEmpty,
      orElse: () => false,
    );

    final hq = highlightQuery.trim();
    var bodySize = comfortReading ? 18.2 : 16.0;
    var titleSize = comfortReading ? 17.2 : 15.5;
    var maddeSize = comfortReading ? 13.5 : 12.5;
    var bodyHeight = comfortReading ? 1.74 : 1.62;
    if (cmkReadingBoost) {
      bodySize += comfortReading ? 0.75 : 0.85;
      titleSize += comfortReading ? 0.55 : 0.48;
      maddeSize += 0.38;
      bodyHeight += 0.075;
    }
    final outerTop = comfortReading ? 20.0 : 18.0;
    final innerPad = comfortReading ? 14.0 : 12.0;

    final sectionTint = deepNight
        ? PoliceColors.readerNightSurface.withValues(alpha: 0.94)
        : Color.lerp(
              PoliceColors.mevzuatScreenBackground,
              PoliceColors.mevzuatListCard,
              0.42,
            )!
            .withValues(alpha: 0.92);

    final borderCol = deepNight
        ? PoliceColors.outlineMuted.withValues(alpha: 0.38)
        : PoliceColors.mevzuatListBorder.withValues(alpha: 0.42);

    Widget hlLine(String text, TextStyle base) {
      if (hq.isEmpty) return Text(text, style: base);
      return Text.rich(
        TextSpan(
          children: highlightTextSpans(text: text, query: hq, baseStyle: base),
        ),
      );
    }

    final bodyStyle = TextStyle(
      color: PoliceColors.mevzuatBodyText,
      fontWeight: FontWeight.w400,
      height: bodyHeight,
      fontSize: bodySize,
      letterSpacing: cmkReadingBoost ? 0.035 : 0.02,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, outerTop, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: sectionTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderCol,
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(innerPad, innerPad, innerPad, innerPad + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hlLine(
                              section.article.toUpperCase(),
                              TextStyle(
                                color: PoliceColors.mevzuatNumberGold,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.55,
                                fontSize: maddeSize,
                              ),
                            ),
                            SizedBox(height: comfortReading ? 12 : 10),
                            hlLine(
                              section.title,
                              TextStyle(
                                color: PoliceColors.mevzuatTitleGrey,
                                fontWeight: FontWeight.w700,
                                fontSize: titleSize,
                                height: 1.34,
                                letterSpacing: 0.18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kişisel not',
                        icon: Icon(
                          hasNote
                              ? Icons.note_alt_rounded
                              : Icons.note_alt_outlined,
                          color: hasNote
                              ? PoliceColors.primaryBlue
                              : PoliceColors.mevzuatMetaGrey,
                        ),
                        onPressed: () => _openNoteEditor(context, ref),
                      ),
                    ],
                  ),
                  if (hasNote)
                    notesAsync.maybeWhen(
                      data: (m) {
                        final t = (m[noteKey] ?? '').trim();
                        if (t.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: PoliceColors.primaryBlue
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: PoliceColors.accentMix(0.45)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                t,
                                style: TextStyle(
                                  color: PoliceColors.mevzuatBodyText
                                      .withValues(alpha: 0.92),
                                  fontSize: 13.5,
                                  height: 1.45,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  _ExpandableArticleBody(
                    text: section.text,
                    query: hq,
                    baseStyle: bodyStyle,
                    summaryMode: summaryMode,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kaynak: ${section.source}',
                    style: TextStyle(
                      color:
                          PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.95),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Son kontrol: $review',
                    style: TextStyle(
                      color:
                          PoliceColors.mevzuatMetaGrey.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isLast ? (comfortReading ? 10 : 8) : 0),
          if (!isLast) ...[
            SizedBox(height: comfortReading ? 18 : 16),
            Divider(
              height: 1,
              thickness: 1,
              color: PoliceColors.mevzuatListBorder.withValues(alpha: 0.55),
            ),
            SizedBox(height: comfortReading ? 8 : 6),
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

Future<void> _shareMevzuatDocument(MevzuatDocumentData content) async {
  final buf = StringBuffer(content.law);
  final secs = content.sections;
  if (secs.isNotEmpty) {
    buf.writeln();
    buf.writeln(secs.first.article);
    buf.writeln(secs.first.title);
    buf.writeln(secs.first.text);
  }
  buf.writeln();
  buf.writeln(content.sourceUrl);
  await Share.share(buf.toString(), subject: content.law);
}

Future<void> _copyFirstMevzuatSection(
  BuildContext context,
  MevzuatDocumentData content,
) async {
  final secs = content.sections;
  if (secs.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kopyalanacak madde yok.')),
      );
    }
    return;
  }
  final s = secs.first;
  final text =
      '${content.law}\n${s.article}\n${s.title}\n${s.text}';
  await Clipboard.setData(ClipboardData(text: text));
  await HapticFeedback.lightImpact();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlk madde panoya kopyalandı.')),
    );
  }
}

/// Özet kipinde madde gövdesini ilk cümlelere kısaltır; "Devamı" ile açar.
class _ExpandableArticleBody extends StatefulWidget {
  const _ExpandableArticleBody({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.summaryMode,
  });

  final String text;
  final String query;
  final TextStyle baseStyle;
  final bool summaryMode;

  @override
  State<_ExpandableArticleBody> createState() => _ExpandableArticleBodyState();
}

class _ExpandableArticleBodyState extends State<_ExpandableArticleBody> {
  bool _expanded = false;

  static const int _summaryChars = 240;

  /// Metni ilk cümle(ler)e ya da yaklaşık [_summaryChars] karaktere kısaltır.
  String _summary(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= _summaryChars) return clean;
    final cut = clean.substring(0, _summaryChars);
    final lastDot = cut.lastIndexOf('. ');
    if (lastDot > 90) {
      return clean.substring(0, lastDot + 1);
    }
    return '${cut.trimRight()}…';
  }

  @override
  Widget build(BuildContext context) {
    final clean = widget.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final showSummary = widget.summaryMode && !_expanded;
    final isTruncatable = clean.length > _summaryChars;

    if (!showSummary || !isTruncatable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText.rich(
            TextSpan(
              children: highlightTextSpans(
                text: widget.text,
                query: widget.query,
                baseStyle: widget.baseStyle,
              ),
            ),
          ),
          if (widget.summaryMode && isTruncatable && _expanded)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Daha az'),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: highlightTextSpans(
              text: _summary(widget.text),
              query: widget.query,
              baseStyle: widget.baseStyle,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _expanded = true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.unfold_more_rounded, size: 18),
            label: const Text('Devamını oku'),
          ),
        ),
      ],
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
