import 'package:flutter/material.dart';

import '../../common/routing/transitions.dart';

class AtaturkPage extends StatelessWidget {
  const AtaturkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      _Quote(
        text: 'Benim naçiz vücudum elbet bir gün toprak olacaktır, ancak Türkiye Cumhuriyeti ilelebet payidar kalacaktır.',
        year: 1923,
      ),
      _Quote(
        text: 'Polis, vatandaşın huzur ve güvenini sağlamakla görevlidir. Bu görev, en kutsal görevdir.',
        year: null,
      ),
      _Quote(
        text: 'Yurtta sulh, cihanda sulh.',
        year: 1931,
      ),
      _Quote(
        text: 'Ordular, ilk hedefiniz Akdeniz\'dir. İleri!',
        year: 1922,
      ),
      _Quote(
        text: 'Benim için en büyük korunma yeri, milletimin kalbidir.',
        year: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Atatürk Köşesi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mustafa Kemal Atatürk',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1881 - 1938',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sözleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...quotes.asMap().entries.map((entry) {
              final index = entry.key;
              final quote = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 80)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote.text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (quote.year != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            quote.year.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Hakkında',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Mustafa Kemal Atatürk, Türkiye Cumhuriyeti\'nin kurucusu ve ilk Cumhurbaşkanıdır. '
                  'Askeri deha, devlet adamı ve reformcu kimliğiyle Türk milletinin önderi olmuştur. '
                  'Modern Türkiye\'nin temellerini atan Atatürk, eğitim, hukuk, ekonomi ve toplumsal alanlarda '
                  'kapsamlı reformlar gerçekleştirmiştir. Onun ilke ve devrimleri, Türk milletinin '
                  'çağdaş medeniyetler seviyesine çıkması için rehber olmuştur.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Quote {
  final String text;
  final int? year;

  _Quote({required this.text, this.year});
}
