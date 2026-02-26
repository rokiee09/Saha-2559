import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../root_gate.dart';
import '../../data/repositories/preference_repository.dart';

const _quote =
    'Polis hukukçu kadar hukuk adamı, asker kadar disiplinli, anne kadar şefkatli olmalıdır.';

class AtaturkQuoteWelcomePage extends ConsumerStatefulWidget {
  const AtaturkQuoteWelcomePage({super.key});

  @override
  ConsumerState<AtaturkQuoteWelcomePage> createState() =>
      _AtaturkQuoteWelcomePageState();
}

class _AtaturkQuoteWelcomePageState extends ConsumerState<AtaturkQuoteWelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 48,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _quote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '— Mustafa Kemal Atatürk',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton(
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
      ),
    );
  }
}
