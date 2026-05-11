import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme/police_colors.dart';
import 'saha_categories.dart';
import 'saha_editor_page.dart';
import 'saha_store.dart';

/// Tek kategori altındaki yerel kayıt listesi.
class SahaCategoryPage extends ConsumerWidget {
  const SahaCategoryPage({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = SahaCategoryDef.byId(categoryId);
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
                categoryId: categoryId,
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
          final items = all.where((n) => n.categoryId == categoryId).toList();
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
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = items[i];
              return Material(
                color: PoliceColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => SahaEditorPage(
                          categoryId: categoryId,
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
                          n.title.trim().isEmpty ? '(Başlıksız)' : n.title,
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
                              color: PoliceColors.textMuted.withValues(alpha: 0.92),
                              height: 1.35,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _fmtDate(n.updatedAtMs),
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.75),
                            fontSize: 11.5,
                          ),
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
    );
  }

  static String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
