import 'package:flutter/material.dart';

import '../../common/routing/transitions.dart';
import '../../common/widgets/primary_card.dart';
import 'ataturk_page.dart';

class KulturPage extends StatelessWidget {
  const KulturPage({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [
      _CultureValue(
        title: 'Vatanseverlik',
        description: 'Ülkeye ve millete bağlılık, görev bilinci.',
        icon: Icons.flag,
        color: Colors.red,
      ),
      _CultureValue(
        title: 'Dürüstlük',
        description: 'Doğruluk, şeffaflık ve güvenilirlik.',
        icon: Icons.verified,
        color: Colors.blue,
      ),
      _CultureValue(
        title: 'Adalet',
        description: 'Hukuka saygı, eşitlik ve hakkaniyet.',
        icon: Icons.balance,
        color: Colors.green,
      ),
      _CultureValue(
        title: 'Cesaret',
        description: 'Zorluklar karşısında kararlılık ve özveri.',
        icon: Icons.shield,
        color: Colors.orange,
      ),
      _CultureValue(
        title: 'Mesleki Etik',
        description: 'Meslek ahlakı ve sorumluluk bilinci.',
        icon: Icons.handshake,
        color: Colors.purple,
      ),
      _CultureValue(
        title: 'Takım Ruhu',
        description: 'Birlik, dayanışma ve iş birliği.',
        icon: Icons.people,
        color: Colors.teal,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Kültür')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          PrimaryCard(
            onTap: () {
              Navigator.of(context).push(
                fadeRoute(const AtaturkPage()),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atatürk Köşesi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mustafa Kemal Atatürk\'ün sözleri ve hatırası',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            values.length,
            (index) {
              final value = values[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 350 + (index * 50)),
                builder: (context, animValue, child) {
                  return Opacity(
                    opacity: animValue,
                    child: Transform.scale(
                      scale: 0.9 + (0.1 * animValue),
                      child: child,
                    ),
                  );
                },
                child: PrimaryCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: value.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          value.icon,
                          color: value.color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              value.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CultureValue {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _CultureValue({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

