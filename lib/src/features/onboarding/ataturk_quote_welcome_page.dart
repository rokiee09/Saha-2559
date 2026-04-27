import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme/police_colors.dart';
import '../../common/widgets/ataturk_portrait_hero.dart';
import '../root_gate.dart';
import '../../data/repositories/preference_repository.dart';

const _quote =
    'Polis hukukçu kadar hukuk adamı, asker kadar disiplinli, anne kadar şefkatli olmalıdır.';

class AtaturkQuoteWelcomePage extends ConsumerWidget {
  const AtaturkQuoteWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const AtaturkPortraitHero(
                      assetPath: 'assets/images/ataturk_matem.jpg',
                      height: 280,
                      horizontalInset: 20,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _quote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 120,
                      height: 1,
                      color: PoliceColors.gold.withValues(alpha: 0.75),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '— Mustafa Kemal Atatürk',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await setAtaturkQuoteSeen(true);
                    if (context.mounted) {
                      ref.invalidate(appStateProvider);
                    }
                  },
                  child: const Text('Devam'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
