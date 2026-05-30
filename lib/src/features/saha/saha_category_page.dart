import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme/police_colors.dart';
import 'saha_categories.dart';
import 'saha_editor_page.dart';
import 'saha_note.dart';
import 'saha_store.dart';

/// Tek kategori altındaki yerel kayıt listesi.
class SahaCategoryPage extends ConsumerStatefulWidget {
  const SahaCategoryPage({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  ConsumerState<SahaCategoryPage> createState() => _SahaCategoryPageState();
}

class _SahaCategoryPageState extends ConsumerState<SahaCategoryPage> {
  final Set<String> _activeTags = {};

  @override
  Widget build(BuildContext context) {
    final def = SahaCategoryDef.byId(widget.categoryId);
    final title = def?.title ?? 'Kayıtlar';
    final notesAsync = ref.watch(sahaNotesProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.mevzuatTitleGrey,
        title: Text(title),
        shape: Border(
          bottom: BorderSide(
            color: PoliceColors.accentMix(0.34),
            width: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => SahaEditorPage(
                categoryId: widget.categoryId,
                existing: null,
              ),
            ),
          );
          ref.invalidate(sahaNotesProvider);
        },
        backgroundColor: PoliceColors.primaryBlue,
        foregroundColor: PoliceColors.titleOnDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni'),
      ),
      body: notesAsync.when(
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
            'Kayıtlar okunamadı.',
            style: TextStyle(color: PoliceColors.textMuted),
          ),
        ),
        data: (all) {
          final items =
              all.where((n) => n.categoryId == widget.categoryId).toList();
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Henüz kayıt yok.\nSağ alttan yeni ekleyebilirsiniz.\n\nBu notlar yalnızca bu cihazda saklanır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    height: 1.45,
                  ),
                ),
              ),
            );
          }

          final availableTags = <String>{
            for (final n in items) ...n.tags,
          };
          // Artık bulunmayan etiket seçiliyse temizle.
          _activeTags.removeWhere((t) => !availableTags.contains(t));

          final filtered = _activeTags.isEmpty
              ? items
              : items
                  .where((n) => n.tags.any(_activeTags.contains))
                  .toList();

          return Column(
            children: [
              if (availableTags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final tag in SahaTag.all)
                          if (availableTags.contains(tag.id))
                            FilterChip(
                              label: Text(tag.label),
                              selected: _activeTags.contains(tag.id),
                              showCheckmark: true,
                              backgroundColor: PoliceColors.surfaceDark,
                              selectedColor: PoliceColors.primaryBlue
                                  .withValues(alpha: 0.28),
                              checkmarkColor: PoliceColors.titleOnDark,
                              labelStyle: TextStyle(
                                color: _activeTags.contains(tag.id)
                                    ? PoliceColors.titleOnDark
                                    : PoliceColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                              side: BorderSide(
                                color: PoliceColors.outlineMuted
                                    .withValues(alpha: 0.5),
                              ),
                              onSelected: (sel) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  if (sel) {
                                    _activeTags.add(tag.id);
                                  } else {
                                    _activeTags.remove(tag.id);
                                  }
                                });
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final n = filtered[i];
                    return Material(
                      color: PoliceColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (_) => SahaEditorPage(
                                categoryId: widget.categoryId,
                                existing: n,
                              ),
                            ),
                          );
                          ref.invalidate(sahaNotesProvider);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title.trim().isEmpty
                                    ? '(Başlıksız)'
                                    : n.title,
                                style: const TextStyle(
                                  color: PoliceColors.titleOnDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              if (n.body.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  n.body.trim(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: PoliceColors.textMuted
                                        .withValues(alpha: 0.92),
                                    height: 1.35,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                              if (n.tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    for (final t in n.tags)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: PoliceColors.primaryBlue
                                              .withValues(alpha: 0.16),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          SahaTag.labelOf(t),
                                          style: const TextStyle(
                                            color: PoliceColors.titleOnDark,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _fmtDate(n.updatedAtMs),
                                style: TextStyle(
                                  color: PoliceColors.textMuted
                                      .withValues(alpha: 0.75),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
