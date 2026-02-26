import 'package:flutter/material.dart';

class HaklarPage extends StatelessWidget {
  const HaklarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rights = [
      _RightItem(
        title: 'Maaş ve Özlük Hakları',
        description: 'Personelin maaş, ikramiye ve diğer mali hakları kanunla korunur.',
        icon: Icons.account_balance_wallet,
      ),
      _RightItem(
        title: 'İzin Hakları',
        description: 'Yıllık izin, mazeret izni ve özel izin hakları mevzuatla belirlenmiştir.',
        icon: Icons.calendar_today,
      ),
      _RightItem(
        title: 'Sağlık ve Emeklilik',
        description: 'Sağlık hizmetleri ve emeklilik hakları güvence altındadır.',
        icon: Icons.health_and_safety,
      ),
      _RightItem(
        title: 'Mesleki Gelişim',
        description: 'Eğitim ve kariyer gelişimi için fırsatlar sunulur.',
        icon: Icons.school,
      ),
      _RightItem(
        title: 'Sendika ve Temsil',
        description: 'Sendika üyeliği ve temsil hakları kanunla korunur.',
        icon: Icons.group,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Haklar')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rights.length,
        itemBuilder: (context, index) {
          final right = rights[index];
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        right.icon,
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            right.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RightItem {
  final String title;
  final String description;
  final IconData icon;

  _RightItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

