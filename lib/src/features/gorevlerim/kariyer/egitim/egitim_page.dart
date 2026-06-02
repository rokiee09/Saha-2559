import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../common/theme/police_colors.dart';
import '../kariyer_file_store.dart';
import 'egitim_editor_page.dart';
import 'egitim_models.dart';
import 'egitim_store.dart';

class EgitimPage extends ConsumerWidget {
  const EgitimPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kayitlarAsync = ref.watch(egitimKayitlarProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Eğitim ve Sertifikalarım'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context, ref),
        backgroundColor: PoliceColors.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ekle'),
      ),
      body: kayitlarAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(child: Text('Kayıtlar okunamadı.')),
        data: (list) {
          final stat = egitimIstatistik(list);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PoliceColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _statRow('Toplam eğitim', '${stat.toplamEgitim}'),
                    _statRow('Toplam sertifika', '${stat.toplamSertifika}'),
                    if (stat.sonKayitAd != null)
                      _statRow('Son tamamlanan', stat.sonKayitAd!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                Text('Henüz kayıt yok.',
                    style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic))
              else
                for (final k in list) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: PhosphorIcon(
                      k.sertifika
                          ? PhosphorIconsRegular.certificate
                          : PhosphorIconsRegular.graduationCap,
                      color: PoliceColors.primaryBlue,
                    ),
                    title: Text(k.ad,
                        style: const TextStyle(
                            color: PoliceColors.titleOnDark,
                            fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      [
                        if (k.kurum.isNotEmpty) k.kurum,
                        if (k.sure.isNotEmpty) k.sure,
                      ].join(' · '),
                      style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.85)),
                    ),
                    onTap: () => _open(context, ref, existing: k),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        if (k.belgePath.isNotEmpty) {
                          await kariyerDeleteFile(k.belgePath);
                        }
                        if (k.sertifikaPath.isNotEmpty) {
                          await kariyerDeleteFile(k.sertifikaPath);
                        }
                        await egitimDelete(ref, k.id);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                ],
            ],
          );
        },
      ),
    );
  }

  Widget _statRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
                child: Text(k,
                    style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9)))),
            Text(v,
                style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Future<void> _open(BuildContext context, WidgetRef ref,
      {EgitimKayit? existing}) async {
    final r = await Navigator.of(context).push<EgitimKayit>(
      MaterialPageRoute(builder: (_) => EgitimEditorPage(existing: existing)),
    );
    if (r != null) await egitimUpsert(ref, r);
  }
}
