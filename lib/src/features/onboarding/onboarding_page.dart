import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../root_gate.dart';
import '../../data/repositories/preference_repository.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;
  bool _accepted = false;

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
                    title: 'Sahada Yalnız Değilsin',
                    description: 'Mevzuat, saha kartları ve pratik örnekler tek uygulamada.',
                  ),
                  _buildPage(
                    title: 'Offline Çalışma',
                    description: 'İnternet olmasa da mevzuat ve içeriklere eriş.',
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
                    onPressed: _index == 2 && _accepted
                        ? () async {
                            await setDisclaimerAccepted(true);
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sorumluluk Reddi (Disclaimer)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu uygulama bilgilendirme amaçlıdır. Resmî mevzuat ve talimatlar her zaman önceliklidir. '
            'Uygulama geliştiricileri ve içerik üreticileri, uygulama kullanımından doğabilecek sonuçlardan '
            'sorumlu tutulamaz.',
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _accepted,
            onChanged: (v) => setState(() => _accepted = v ?? false),
            title: const Text('Metni okudum ve kabul ediyorum.'),
          ),
        ],
      ),
    );
  }
}

