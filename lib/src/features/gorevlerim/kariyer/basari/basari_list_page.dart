import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/theme/police_colors.dart';
import '../../../../common/widgets/police_module_icon.dart';
import '../kariyer_file_store.dart';
import 'basari_editor_page.dart';
import 'basari_models.dart';
import 'basari_store.dart';

class BasariBelgeListPage extends ConsumerWidget {
  const BasariBelgeListPage({super.key, required this.tur});

  final BasariBelgeTuru tur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final belgelerAsync = ref.watch(basariBelgelerProvider);
    final style = tur == BasariBelgeTuru.basari
        ? PoliceModules.basari
        : PoliceModules.ustunBasari;

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(tur.label),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kayıt ekle'),
      ),
      body: belgelerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Kayıtlar okunamadı.')),
        data: (all) {
          final list = all.where((b) => b.tur == tur).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
            children: [
              if (list.isEmpty)
                Text(
                  'Henüz ${tur.label.toLowerCase()} kaydı yok.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                for (final b in list) _tile(context, ref, b, style),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    BasariBelge b,
    PoliceModuleStyle style,
  ) {
    final tarih = DateTime.fromMillisecondsSinceEpoch(b.tarihMs);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _openEditor(context, ref, existing: b),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: style.color.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.fotoPath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(b.fotoPath),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  PoliceModuleIconBadge(
                    style: style,
                    size: 20,
                    padding: 8,
                    borderRadius: 10,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.aciklama.isNotEmpty ? b.aciklama : tur.label,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tarih.day}.${tarih.month}.${tarih.year}'
                        '${b.verenMakam.isNotEmpty ? ' · ${b.verenMakam}' : ''}',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.88),
                          fontSize: 12.5,
                        ),
                      ),
                      if (b.evrakNo.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Evrak: ${b.evrakNo}',
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.75),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    if (b.fotoPath.isNotEmpty) {
                      await kariyerDeleteFile(b.fotoPath);
                    }
                    if (b.pdfPath.isNotEmpty) await kariyerDeleteFile(b.pdfPath);
                    await basariDelete(ref, b);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    BasariBelge? existing,
  }) async {
    final result = await Navigator.of(context).push<BasariBelge>(
      MaterialPageRoute(
        builder: (_) => BasariEditorPage(
          existing: existing,
          tur: tur,
        ),
      ),
    );
    if (result != null) await basariUpsert(ref, result);
  }
}
