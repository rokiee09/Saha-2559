import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants/app_branding.dart';
import '../common/theme/police_colors.dart';
import '../security/vault_gate.dart';
import 'onboarding/ataturk_quote_welcome_page.dart';
import 'onboarding/onboarding_page.dart';

import '../data/repositories/preference_repository.dart';

/// Uygulama açılış durumu: (kullanıcı sözleşmesi kabulü, Atatürk sözü görüldü mü)
final appStateProvider = FutureProvider<(bool accepted, bool quoteSeen)>((ref) async {
  final accepted = await getUserAgreementAccepted();
  final quoteSeen = await getAtaturkQuoteSeen();
  return (accepted, quoteSeen);
});

class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return appState.when(
      loading: () => Scaffold(
        backgroundColor: PoliceColors.backgroundDark,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                height: 88,
                width: 88,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shield_outlined,
                  size: 72,
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                kAppDisplayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  kAppTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontSize: 14,
                    height: 1.42,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: PoliceColors.primaryBlue,
                  strokeWidth: 2.8,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: PoliceColors.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Consumer(
              builder: (ctx, ref, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 44,
                    color: PoliceColors.gold.withValues(alpha: 0.85),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Açılış ayarları okunamadı. Bu genelde geçicidir; yeniden deneyebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.95),
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => ref.invalidate(appStateProvider),
                    child: const Text('Yeniden dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        return const VaultGate();
      },
    );
  }
}

