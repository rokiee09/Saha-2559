import 'package:flutter/material.dart';

class AtaturkPage extends StatelessWidget {
  const AtaturkPage({super.key});

  static const _policeQuotes = [
    'Polis hukukçu kadar hukuk adamı, asker kadar disiplinli, anne kadar şefkatli olmalıdır.',
    'Polis, vatandaşın huzur ve güvenini sağlamakla görevlidir. Bu görev, en kutsal görevdir.',
    'Asayişi korumak, vatandaşın can ve mal güvenliğini sağlamak polisin birincil vazifesidir.',
    'Polis, kanunun hâkimi değil hizmetkârıdır; görevi hukuku uygulamak ve toplum düzenini korumaktır.',
  ];

  static const _biography =
      'Mustafa Kemal Atatürk, Türkiye Cumhuriyeti\'nin kurucusu ve ilk Cumhuriyet Başkanıdır. '
      'Askerî deha, devlet adamı ve reformcu kimliğiyle Türk milletinin önderi olmuştur. '
      'Modern Türkiye\'nin temellerini atan Atatürk, eğitim, hukuk, ekonomi ve toplumsal alanlarda '
      'kapsamlı reformlar gerçekleştirmiştir. Onun ilke ve devrimleri, Türk milletinin '
      'çağdaş medeniyetler seviyesine çıkması için rehber olmuştur. 1881–1938.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atatürk Köşesi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 200,
                  height: 240,
                  child: _AtaturkImage(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    'Mustafa Kemal Atatürk',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1881 – 1938',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Polislik ile ilgili sözleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._policeQuotes.asMap().entries.map((entry) {
              final index = entry.key;
              final quote = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 350 + (index * 60)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 28,
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            quote,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
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
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _biography,
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

/// Atatürk resmi: asset varsa gösterir, yoksa saygılı bir placeholder.
class _AtaturkImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/atatürk.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Mustafa Kemal Atatürk',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
