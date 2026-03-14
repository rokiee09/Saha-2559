import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widgets/primary_card.dart';
import 'saha_providers.dart';

class SahaPage extends ConsumerWidget {
  const SahaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(fieldCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saha')),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saha Kartları',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sahada karşılaşabileceğiniz durumlar, uygulama örnekleri ve ilgili mevzuat referansları burada yer alır. '
                          'İçerik yüklemek için Teşkilat > Ayarlar üzerinden "Offline paket indir" seçeneğini kullanın.',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Örnek: Kimlik kontrolü, trafik denetimi, devriye, olay yeri inceleme',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Text(
                  'Sahada kullanabileceğiniz kartlar ve ilgili mevzuat referansları.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ...List.generate(cards.length, (index) {
                final card = cards[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: PrimaryCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (card.iconKey != null)
                              Icon(
                                _getIcon(card.iconKey!),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                card.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(card.description),
                        if (card.lawRef != null && card.lawRef!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'İlgili mevzuat: ${card.lawRef}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key.toLowerCase()) {
      case 'traffic':
        return Icons.traffic;
      case 'security':
        return Icons.security;
      case 'patrol':
        return Icons.directions_walk;
      case 'investigation':
        return Icons.search;
      default:
        return Icons.info;
    }
  }
}

