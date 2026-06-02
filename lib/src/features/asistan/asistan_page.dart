import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../home/root_drawer_scope.dart';
import '../mevzuat/mevzuat_article_detail_page.dart';
import 'asistan_domain.dart';
import 'asistan_provider.dart';

/// Polis çalışma asistanı: senaryo tabanlı mevzuat kullanım rehberi (offline).
class AsistanPage extends ConsumerStatefulWidget {
  const AsistanPage({super.key});

  @override
  ConsumerState<AsistanPage> createState() => _AsistanPageState();
}

class _AsistanPageState extends ConsumerState<AsistanPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runQuery(String value) {
    ref.read(asistanQueryProvider.notifier).state = value;
  }

  void _applyScenario(AsistanScenario scenario) {
    HapticFeedback.selectionClick();
    final q = scenario.situation.isNotEmpty
        ? scenario.situation
        : scenario.triggers.first;
    _controller.text = q;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );
    _runQuery(q);
    _focusNode.unfocus();
  }

  void _openSection(String entryId, String? sectionId) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeRoute(
        MevzuatArticleDetailPage(
          entryId: entryId,
          focusSectionId: sectionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(asistanQueryProvider).trim();
    final selectedDomain = ref.watch(asistanSelectedDomainProvider);
    final scenariosAsync = ref.watch(asistanScenariosProvider);
    final inScope = ref.watch(asistanScopeProvider);
    final resultsAsync = ref.watch(asistanResultsProvider);
    final answer = ref.watch(asistanAnswerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Çalışma Asistanı',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Görev senaryonuz nedir?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PVSK, CMK, TCK, izin, tayin, lojman ve maaş — '
                  'mevzuatı aratmak yerine nasıl kullanacağınızı gösterir.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                _SearchField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _runQuery,
                  onClear: () {
                    _controller.clear();
                    _runQuery('');
                  },
                ),
                const SizedBox(height: 10),
                scenariosAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (all) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _DomainChip(
                                label: 'Tümü',
                                selected: selectedDomain == null,
                                onTap: () => ref
                                    .read(
                                        asistanSelectedDomainProvider.notifier)
                                    .state = null,
                              ),
                              for (final d in asistanAllDomains) ...[
                                const SizedBox(width: 8),
                                _DomainChip(
                                  label: d.label,
                                  selected: selectedDomain == d,
                                  onTap: () => ref
                                      .read(asistanSelectedDomainProvider
                                          .notifier)
                                      .state = d,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? scenariosAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: PoliceColors.primaryBlue,
                      ),
                    ),
                    error: (_, __) => const _AsistanIntro(
                      scenarios: [],
                      onScenarioTap: null,
                    ),
                    data: (all) {
                      final filtered =
                          asistanScenariosForDomain(all, selectedDomain);
                      return _AsistanIntro(
                        scenarios:
                            asistanFeaturedScenarios(filtered).take(6).toList(),
                        onScenarioTap: _applyScenario,
                      );
                    },
                  )
                : !inScope
                    ? const _OutOfScopeMessage()
                    : resultsAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: PoliceColors.primaryBlue,
                          ),
                        ),
                        error: (_, __) => const _AsistanMessage(
                          icon: Icons.error_outline_rounded,
                          title: 'Yanıt üretilemedi',
                          message: 'Lütfen tekrar deneyin.',
                        ),
                        data: (hits) {
                          if (answer == null && hits.isEmpty) {
                            return const _AsistanMessage(
                              icon: Icons.search_off_rounded,
                              title: 'Senaryo bulunamadı',
                              message:
                                  'Sorunuzu farklı kelimelerle yazın veya yukarıdan '
                                  'bir uzmanlık alanı ve örnek senaryo seçin.',
                            );
                          }
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              if (answer != null)
                                _StructuredAnswerCard(
                                  answer: answer,
                                  onOpenRef: _openSection,
                                ),
                              if (hits.isNotEmpty) ...[
                                if (answer != null) const SizedBox(height: 16),
                                Text(
                                  'İlgili maddeler (ek)',
                                  style: TextStyle(
                                    color: PoliceColors.textMuted
                                        .withValues(alpha: 0.9),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final hit in hits) ...[
                                  _ResultCard(
                                    hit: hit,
                                    onTap: () => _openSection(
                                      hit.entry.id,
                                      hit.section.id,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Örn. "Gözaltında müdafi hakkı" veya "refakat izni"',
        prefixIcon: Icon(
          Icons.support_agent_rounded,
          color: cs.primary.withValues(alpha: 0.9),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: onClear,
              tooltip: 'Temizle',
            );
          },
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        isDense: true,
      ),
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: PoliceColors.primaryBlue.withValues(alpha: 0.25),
      checkmarkColor: PoliceColors.primaryBlue,
      labelStyle: TextStyle(
        color: selected
            ? PoliceColors.titleOnDark
            : PoliceColors.textMuted.withValues(alpha: 0.95),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected
            ? PoliceColors.primaryBlue.withValues(alpha: 0.6)
            : PoliceColors.outlineMuted.withValues(alpha: 0.4),
      ),
      backgroundColor: PoliceColors.surfaceDark,
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario, required this.onTap});

  final AsistanScenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.domain.label,
                      style: TextStyle(
                        color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.title,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    if (scenario.situation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        scenario.situation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.88),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                color: PoliceColors.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StructuredAnswerCard extends StatelessWidget {
  const _StructuredAnswerCard({
    required this.answer,
    required this.onOpenRef,
  });

  final AsistanStructuredAnswer answer;
  final void Function(String entryId, String? sectionId) onOpenRef;

  @override
  Widget build(BuildContext context) {
    final s = answer.scenario;
    final primaryRef =
        answer.resolvedRefs.isNotEmpty ? answer.resolvedRefs.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.domain.label,
                  style: const TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.title,
                  style: const TextStyle(
                    color: PoliceColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AnswerSection(
            number: '1',
            title: 'Kısa Özet',
            body: s.summary,
          ),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '2',
            title: 'Uygulamada Ne Anlama Geliyor',
            body: s.appContext,
          ),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '3',
            title: 'Kaynak Mevzuat',
            body: s.source,
          ),
          const SizedBox(height: 14),
          Text(
            '4 · Tam Metni Aç',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.95),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          if (answer.resolvedRefs.isEmpty)
            Text(
              'Bu senaryo için pakette doğrudan madde bağlantısı yok; '
              'Mevzuat sekmesinden ilgili kanunu arayın.',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.4,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in answer.resolvedRefs)
                  _OpenTextButton(
                    label: r.label,
                    onTap: () => onOpenRef(r.entryId, r.sectionId),
                  ),
              ],
            ),
          if (primaryRef != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    onOpenRef(primaryRef.entryId, primaryRef.sectionId),
                icon: const PhosphorIcon(
                  PhosphorIconsRegular.scroll,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Tam metni aç',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: PoliceColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            asistanDisclaimer,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerSection extends StatelessWidget {
  const _AnswerSection({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number · $title',
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.95),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(
            color: PoliceColors.titleOnDark.withValues(alpha: 0.94),
            height: 1.45,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _OpenTextButton extends StatelessWidget {
  const _OpenTextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDarkElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PhosphorIcon(
                PhosphorIconsRegular.scroll,
                size: 15,
                color: PoliceColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
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

class _OutOfScopeMessage extends StatelessWidget {
  const _OutOfScopeMessage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _AsistanMessage(
          icon: Icons.block_rounded,
          title: 'Bu konu çalışma alanım dışında',
          message:
              'Çalışma asistanı yalnızca polis mevzuatı ve görev konularında '
              'yardımcı olur: PVSK, CMK, TCK, 657 DMK, disiplin, izin, tayin, '
              'lojman ve maaş.\n\n'
              'Genel sohbet, kişisel hukuk veya görev dışı sorular için '
              'ilgili uzmana başvurun.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in asistanAllDomains)
              Chip(
                label: Text(d.label),
                backgroundColor: PoliceColors.surfaceDark,
                side: BorderSide(
                  color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.hit, required this.onTap});

  final AsistanHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hit.section.title.trim().isNotEmpty)
                Text(
                  hit.section.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                hit.snippet(160),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hit.sourceLabel,
                style: const TextStyle(
                  color: PoliceColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AsistanIntro extends StatelessWidget {
  const _AsistanIntro({
    required this.scenarios,
    required this.onScenarioTap,
  });

  final List<AsistanScenario> scenarios;
  final ValueChanged<AsistanScenario>? onScenarioTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (scenarios.isNotEmpty) ...[
          Text(
            'Örnek senaryolar',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          for (final scenario in scenarios)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ScenarioCard(
                scenario: scenario,
                onTap: () => onScenarioTap?.call(scenario),
              ),
            ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PoliceColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.shieldCheck,
                    color: PoliceColors.primaryBlue,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Polis çalışma asistanı',
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Genel sohbet botu değildir. Görev senaryonuzu seçin veya yazın; '
                'kısa özet, uygulamada ne yapmanız gerektiği ve kaynak mevzuat '
                'tek kartta sunulur.',
                style: TextStyle(
                  color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.9),
                  height: 1.45,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                asistanDisclaimer,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AsistanMessage extends StatelessWidget {
  const _AsistanMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 52,
              color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
