import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../common/theme/police_colors.dart';
import '../kariyer_file_store.dart';
import 'basari_editor_page.dart';
import 'basari_models.dart';
import 'basari_store.dart';

class BasariPage extends ConsumerWidget {
  const BasariPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final belgelerAsync = ref.watch(basariBelgelerProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Başarı Dosyam'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Belge ekle'),
      ),
      body: belgelerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Kayıtlar okunamadı.')),
        data: (list) {
          final h = hesaplaBasari(list);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
            children: [
              _hesapKart(h),
              const SizedBox(height: 8),
              Text(
                '3 başarı belgesi = 1 üstün başarı belgesi hakkı. Üstün belgeleri '
                'aldığınızda ayrıca kaydedin.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.85),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                Text(
                  'Henüz belge yok.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                for (final b in list) _tile(context, ref, b),
            ],
          );
        },
      ),
    );
  }

  Widget _hesapKart(BasariHesap h) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.gold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          _row('Başarı Belgesi', '${h.basariSayisi}'),
          _row('Üstün Başarı Belgesi', '${h.ustunSayisi}'),
          const Divider(height: 20),
          Text(
            'Sonraki üstün başarı için: ${h.sonrakiUstunIcinKalan} başarı belgesi kaldı',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PoliceColors.gold.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          if (h.hakEdilenUstun > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Hesaplanan hak: ${h.hakEdilenUstun} üstün başarı',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(k,
                  style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9))),
            ),
            Text(v,
                style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ],
        ),
      );

  Widget _tile(BuildContext context, WidgetRef ref, BasariBelge b) {
    final tarih = DateTime.fromMillisecondsSinceEpoch(b.tarihMs);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: () => _openEditor(context, ref, existing: b),
          leading: b.fotoPath.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(File(b.fotoPath), width: 48, height: 48, fit: BoxFit.cover),
                )
              : PhosphorIcon(
                  PhosphorIconsRegular.medal,
                  color: PoliceColors.gold,
                ),
          title: Text(b.tur.label,
              style: const TextStyle(
                  color: PoliceColors.titleOnDark, fontWeight: FontWeight.w700)),
          subtitle: Text(
            '${tarih.day}.${tarih.month}.${tarih.year}'
            '${b.verenMakam.isNotEmpty ? ' · ${b.verenMakam}' : ''}',
            style: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.85)),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            onPressed: () async {
              HapticFeedback.selectionClick();
              if (b.fotoPath.isNotEmpty) await kariyerDeleteFile(b.fotoPath);
              if (b.pdfPath.isNotEmpty) await kariyerDeleteFile(b.pdfPath);
              await basariDelete(ref, b);
            },
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
      MaterialPageRoute(builder: (_) => BasariEditorPage(existing: existing)),
    );
    if (result != null) await basariUpsert(ref, result);
  }
}
