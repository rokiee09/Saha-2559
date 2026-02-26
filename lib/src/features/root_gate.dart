import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home/home_shell.dart';
import 'onboarding/ataturk_quote_welcome_page.dart';
import 'onboarding/onboarding_page.dart';

import '../data/repositories/preference_repository.dart';

/// Uygulama açılış durumu: (disclaimer kabul, Atatürk sözü görüldü mü)
final appStateProvider = FutureProvider<(bool accepted, bool quoteSeen)>((ref) async {
  final accepted = await getDisclaimerAccepted();
  final quoteSeen = await getAtaturkQuoteSeen();
  return (accepted, quoteSeen);
});

class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return appState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Hata: $err')),
      ),
      data: (state) {
        final accepted = state.$1;
        final quoteSeen = state.$2;
        if (!accepted) {
          return const OnboardingPage();
        }
        if (!quoteSeen) {
          return const AtaturkQuoteWelcomePage();
        }
        return const HomeShell();
      },
    );
  }
}

