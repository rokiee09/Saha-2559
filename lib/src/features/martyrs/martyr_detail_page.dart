import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'martyr_provider.dart';

class MartyrDetailPage extends ConsumerWidget {
  final int martyrId;

  const MartyrDetailPage({super.key, required this.martyrId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final martyrAsync = ref.watch(martyrProvider(martyrId));

    return Scaffold(
      appBar: AppBar(title: const Text('Şehit Detayı')),
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
              : null;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  martyr.fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    martyr.cityName,
                    if (dateText != null) dateText,
                    if (martyr.location != null && martyr.location!.isNotEmpty)
                      martyr.location!,
                  ].join(' • '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Anısına',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      martyr.story ??
                          'Bu alan, şehidimizin hayatı ve hatırasına dair saygı odaklı bilgileri içerir.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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

