import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants/app_disclaimer.dart';
import '../mevzuat/mevzuat_provider.dart';

/// Mevzuat içeriğinin kaynağını, "resmî değildir" uyarısını ve her metnin
/// son içerik kontrol tarihini gösteren bilgilendirme ekranı.
class DataFreshnessPage extends ConsumerWidget {
  const DataFreshnessPage({super.key});

  static const String officialSourceUrl = 'https://www.mevzuat.gov.tr/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(mevzuatCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Veri güncelliği')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Mevzuat kataloğu yüklenemedi.'),
          ),
        ),
        data: (catalog) {
          final all = <MevzuatEntry>[
            ...catalog.kanunlar,
            ...catalog.yonetmelikler,
          ];
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              _headerCard(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Metin bazında son içerik kontrolü',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Tarih belirtilmeyen metinlerde, yayından önce karşılaştırma yapmanız önerilir.',
                  style: TextStyle(fontSize: 12.5),
                ),
              ),
              const Divider(height: 0),
              for (final entry in all) _LawFreshnessTile(entry: entry),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_outlined,
                      color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Kaynak ve güncellik',
                        style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _kv('Kaynak', 'mevzuat.gov.tr (resmî metinlerden derlenmiştir)'),
              const SizedBox(height: 6),
              _kv('Erişim', 'Çevrimdışı — metinler uygulama paketinde gelir'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 20, color: theme.colorScheme.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        kAppFullDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openOfficialSource(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Güncel metin için resmî kaynağı aç'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(v)),
      ],
    );
  }

  Future<void> _openOfficialSource(BuildContext context) async {
    final uri = Uri.parse(officialSourceUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resmî kaynak açılamadı.')),
      );
    }
  }
}

class _LawFreshnessTile extends ConsumerWidget {
  const _LawFreshnessTile({required this.entry});

  final MevzuatEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaAsync = ref.watch(mevzuatEntryMetaProvider(entry.id));
    final theme = Theme.of(context);

    return metaAsync.when(
      loading: () => ListTile(
        title: Text(entry.displayTitle),
        subtitle: const Text('Yükleniyor…'),
      ),
      error: (_, __) => ListTile(
        title: Text(entry.displayTitle),
        subtitle: const Text('Okunamadı'),
      ),
      data: (meta) {
        final review = (meta.lastReview != null && meta.lastReview!.trim().isNotEmpty)
            ? meta.lastReview!.trim()
            : 'belirtilmemiş';
        return ListTile(
          dense: true,
          title: Text(entry.displayTitle),
          subtitle: Text(
            '${entry.categoryLabel} · ${meta.maddeCount} madde · Son kontrol: $review',
            style: theme.textTheme.bodySmall,
          ),
        );
      },
    );
  }
}
