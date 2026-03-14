import 'package:flutter/material.dart';

import '../../common/routing/transitions.dart';
import 'haklar_data.dart';
import 'haklar_detail_page.dart';

class HaklarPage extends StatelessWidget {
  const HaklarPage({super.key});

  static IconData _iconFor(String key) {
    switch (key) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'calendar':
        return Icons.calendar_today;
      case 'health':
        return Icons.health_and_safety;
      case 'school':
        return Icons.school;
      case 'group':
        return Icons.group;
      case 'gavel':
        return Icons.gavel;
      case 'badge':
        return Icons.badge;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Haklar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personel Hakları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Polis personelinin maaş, izin, sağlık, disiplin itirazı ve diğer hakları 2559 sayılı Polis Vazife ve Salahiyet Kanunu ile 657 sayılı DMK ve ilgili mevzuatla güvence altındadır. '
                    'Kartlara dokunarak her hakla ilgili detaylı açıklama, ilgili mevzuat ve özet bilgiye ulaşabilirsiniz.',
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(rightsData.length, (index) {
            final right = rightsData[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 60)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    Navigator.of(context).push(
                      fadeRoute(HaklarDetailPage(item: right)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconFor(right.iconKey),
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                right.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                right.shortDescription,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Detay için dokunun',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
