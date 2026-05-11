import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants/app_branding.dart';
import '../../common/legal/user_agreement_document_body.dart';
import '../../common/theme/police_colors.dart';
import '../root_gate.dart';
import '../../data/repositories/preference_repository.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  final _agreementScrollController = ScrollController();
  int _index = 0;
  bool _accepted = false;

  @override
  void dispose() {
    _pageController.dispose();
    _agreementScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _buildPage(
                    title: kOnboardingPage1Title,
                    description: kOnboardingPage1Body,
                  ),
                  _buildPage(
                    title: kOnboardingPage2Title,
                    description: kOnboardingPage2Body,
                  ),
                  _buildDisclaimerPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _index == 2 && !_accepted
                        ? null
                        : _index == 2
                            ? () async {
                                await acceptUserAgreement();
                                if (context.mounted) {
                                  ref.invalidate(appStateProvider);
                                }
                              }
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                              },
                    child: Text(_index == 2 ? 'Başla' : 'İleri'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerPage() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Scrollbar(
            controller: _agreementScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _agreementScrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: const UserAgreementDocumentBody(),
            ),
          ),
        ),
        Material(
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Bu sözleşmeyi okudum, kabul ediyorum.',
                  style: TextStyle(
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.98),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                subtitle: Text(
                  'Onayınız ve sürüm bilgisi yalnızca bu cihazda saklanır.',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

