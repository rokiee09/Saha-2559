import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widgets/turkish_flag_circle_icon.dart';
import 'martyr_provider.dart';

class MartyrDetailPage extends ConsumerWidget {
  final int martyrId;

  const MartyrDetailPage({super.key, required this.martyrId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final martyrAsync = ref.watch(martyrProvider(martyrId));

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt')),
      body: martyrAsync.when(
        data: (martyr) {
          if (martyr == null) {
            return const Center(child: Text('Kayıt bulunamadı.'));
          }

          final dateText = martyr.dateOfMartyrdom != null
              ? martyr.dateOfMartyrdom!
                  .toLocal()
                  .toIso8601String()
                  .split("T")
                  .first
              : '—';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RowLabel(
                  label: 'Ad soyad / ünvan (kayıtlı metin)',
                  value: martyr.fullName,
                  strong: true,
                  valueLeading: const TurkishFlagAssetCircleIcon(size: 48),
                ),
                const SizedBox(height: 16),
                _RowLabel(label: 'İl', value: martyr.cityName),
                const SizedBox(height: 12),
                _RowLabel(label: 'Tarih', value: dateText),
                const SizedBox(height: 20),
                Text(
                  'Bu alanda anı metni veya yorum yoktur. '
                  'Güncel ve eksiksiz resmî kayıt için kurum duyuruları esas alınmalıdır.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
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
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({
    required this.label,
    required this.value,
    this.strong = false,
    this.valueLeading,
  });

  final String label;
  final String value;
  final bool strong;
  final Widget? valueLeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        valueLeading != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: valueLeading!,
                  ),
                  Expanded(
                    child: SelectableText(
                      value,
                      style: strong
                          ? Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              )
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              )
            : SelectableText(
                value,
                style: strong
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                    : Theme.of(context).textTheme.bodyLarge,
              ),
      ],
    );
  }
}
