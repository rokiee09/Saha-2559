import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../araclar/dilekce/dilekce_merkezi_page.dart';
import '../araclar/emsal/emsal_rehberi_page.dart';
import '../araclar/mutalaa/mutalaa_ozel_page.dart';
import '../araclar/idari_para_ceza/idari_para_ceza_page.dart';
import '../araclar/trafik/trafik_rehberi_page.dart';
import '../araclar/idari_para_ceza/widgets/idari_para_ceza_card.dart';
import '../araclar/tutanak/tutanak_merkezi_page.dart';
import '../gorevlerim/atis/atis_takip_page.dart';
import '../gorevlerim/kariyer/basari/basari_oduller_hub_page.dart';
import '../gorevlerim/kariyer/egitim/egitim_page.dart';
import '../gorevlerim/kariyer/kariyer_hub_page.dart';
import '../home/root_drawer_scope.dart';
import '../mevzuat/mevzuat_article_detail_page.dart';
import '../saglik/saglik_sosyal_haklar_page.dart';
import 'asistan_domain.dart';
import 'asistan_provider.dart';
import 'search/assistant_models.dart';
import '../../common/theme/saha_module_theme.dart';
import '../../common/widgets/saha_empty_state.dart';
import 'decision_support/legal_clarification_service.dart';
import 'settings/asistan_llm_settings_page.dart';
import 'legal/assistant_answer_builder.dart';
import 'legal/assistant_legal_index.dart';
import 'legal/assistant_legal_search_service.dart';
import 'legal/assistant_query_classifier.dart';

/// Mevzuat kaynaklı soru-cevap asistanı (offline).
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

  void _applyQuery(String q) {
    HapticFeedback.selectionClick();
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

  void _openLegalRecord(LegalIndexRecord record) {
    HapticFeedback.lightImpact();
    if (record.sourceType == LegalSourceType.idariParaCeza) {
      Navigator.of(context).push(
        fadeRoute(IdariParaCezaPage(initialQuery: record.title)),
      );
      return;
    }
    final route = record.moduleRoute?.trim();
    if (route != null && route.isNotEmpty) {
      final page = _pageForModuleRoute(route, record);
      if (page != null) {
        Navigator.of(context).push(fadeRoute(page));
        return;
      }
    }
    if (record.entryId != null && record.entryId!.isNotEmpty) {
      _openSection(record.entryId!, record.sectionId);
    }
  }

  Widget? _pageForModuleRoute(String route, LegalIndexRecord record) {
    return switch (route) {
      'atis_takip' => const AtisTakipPage(),
      'basari_oduller' => const BasariOdullerHubPage(),
      'saglik' => const SaglikSosyalHaklarPage(),
      'tutanak' => const TutanakMerkeziPage(),
      'kariyer' => const KariyerHubPage(),
      'egitim' => const EgitimPage(),
      'idari_para_ceza' =>
        IdariParaCezaPage(initialQuery: record.title),
      'dilekce' => const DilekceMerkeziPage(),
      'emsal' => EmsalRehberiPage(initialQuery: record.title),
      'trafik' => TrafikRehberiPage(initialQuery: record.title),
      'mutalaa_ozel' => MutalaaOzelPage(initialQuery: record.title),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(asistanQueryProvider).trim();
    final searchAsync = ref.watch(legalAssistantAnswerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Mevzuat Asistanı',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'AI özeti ayarları',
            icon: const PhosphorIcon(
              PhosphorIconsRegular.gear,
              color: PoliceColors.textMuted,
            ),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const AsistanLlmSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mevzuat sorunuz nedir?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kanun, yönetmelik, disiplin, izin, idari para cezaları ve '
                  'personel mevzuatında kaynaklı cevap arar. Serbest soru yazın.',
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
              ],
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _AsistanIntro(onExampleTap: _applyQuery)
                : searchAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: PoliceColors.primaryBlue,
                          ),
                        ),
                        error: (_, __) => SahaEmptyState(
                          theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
                          icon: Icons.error_outline_rounded,
                          title: 'Yanıt üretilemedi',
                          message: 'Lütfen tekrar deneyin.',
                        ),
                        data: (answer) {
                          if (answer == null) {
                            return SahaEmptyState(
                              theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
                              icon: Icons.search_off_rounded,
                              title: 'Sonuç yok',
                              message: 'Lütfen sorunuzu yazın.',
                            );
                          }
                          if (answer.sensitiveBlocked) {
                            return SahaEmptyState(
                              theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
                              icon: Icons.shield_outlined,
                              title: 'Hassas konu',
                              message: answer.shortAnswer,
                            );
                          }
                          if (answer.outOfScope) {
                            return SahaEmptyState(
                              theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
                              icon: Icons.info_outline_rounded,
                              title: 'Kapsam dışı',
                              message: answer.shortAnswer,
                            );
                          }
                          if (answer.noStrongMatch) {
                            return SahaEmptyState(
                              theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
                              icon: Icons.search_off_rounded,
                              title: 'Net madde bulunamadı',
                              message: answer.shortAnswer,
                              actionLabel: 'Mevzuat sekmesine git',
                              onAction: () {
                                ref.read(asistanQueryProvider.notifier).state =
                                    '';
                                Navigator.of(context).pop();
                              },
                            );
                          }
                          final primary = answer.primaryIndexRecord!;
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              if (answer.detectedTopics.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _TopicChips(topics: answer.detectedTopics),
                                ),
                              if (primary.sourceType ==
                                  LegalSourceType.idariParaCeza) ...[
                                const _CezaCardCompact(),
                                const SizedBox(height: 12),
                              ],
                              _LegalAnswerCard(
                                answer: answer,
                                onOpenFullText: () => _openLegalRecord(primary),
                              ),
                              if (answer.needsClarification &&
                                  answer.clarificationQuestions.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _ClarificationPanel(
                                  questions: answer.clarificationQuestions,
                                  onPick: _applyQuery,
                                ),
                              ],
                              if (answer.topHits.length > 1) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Diğer ilgili maddeler',
                                  style: TextStyle(
                                    color: PoliceColors.textMuted
                                        .withValues(alpha: 0.9),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final h in answer.topHits.skip(1))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _LegalHitTile(
                                      hit: h,
                                      onTap: () =>
                                          _openLegalRecord(h.record.toIndexRecord()),
                                    ),
                                  ),
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
        hintText: 'Örn. "Kimlik vermeyen şahsa ne yapılır?" veya "dilencilik cezası"',
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
            kLegalAssistantDisclaimer,
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
        SahaEmptyState(
          theme: SahaModuleTheme.forArea(SahaModuleArea.asistan),
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
  const _AsistanIntro({this.onExampleTap});

  final ValueChanged<String>? onExampleTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Örnek sorular',
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.9),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final q in kLegalAsistanOrnekSorular)
              ActionChip(
                label: Text(q, style: const TextStyle(fontSize: 11.5)),
                onPressed: onExampleTap == null ? null : () => onExampleTap!(q),
                backgroundColor: PoliceColors.surfaceDark,
                side: BorderSide(
                  color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
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
                      'Mevzuat kaynaklı asistan',
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
                'Doğal dilde sorularınızı sınıflandırır, yerel mevzuat indeksinde '
                'puanlı arama yapar ve kaynak göstererek cevap üretir. Uydurma '
                'cevap vermez; güçlü eşleşme yoksa bunu açıkça belirtir.',
                style: TextStyle(
                  color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.9),
                  height: 1.45,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                kLegalAssistantDisclaimer,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                  fontSize: 11.5,
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

class _TopicChips extends StatelessWidget {
  const _TopicChips({required this.topics});

  final List<String> topics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final t in topics.take(6))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PoliceColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              t.replaceAll('_', ' '),
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _ClarificationPanel extends StatelessWidget {
  const _ClarificationPanel({
    required this.questions,
    required this.onPick,
  });

  final List<LegalClarificationQuestion> questions;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Netleştirici sorular',
            style: TextStyle(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daha isabetli ön değerlendirme için aşağıdaki hususları soruya ekleyin.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (final q in questions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: PoliceColors.backgroundDark,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onPick(q.question),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PhosphorIcon(
                          PhosphorIconsRegular.question,
                          color: PoliceColors.primaryBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q.question,
                            style: const TextStyle(
                              color: PoliceColors.titleOnDark,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegalAnswerCard extends StatelessWidget {
  const _LegalAnswerCard({
    required this.answer,
    required this.onOpenFullText,
  });

  final LegalAssistantAnswer answer;
  final VoidCallback onOpenFullText;

  @override
  Widget build(BuildContext context) {
    final record = answer.primaryRecord;
    final category = answer.analysis.classification.primary;
    final certainty = answer.certaintyLevel;

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
                  category.label,
                  style: const TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PoliceColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Güven: ${certainty.label}',
                  style: const TextStyle(
                    color: PoliceColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ),
              if (answer.usedLlmSummary) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI özet${answer.llmModelLabel != null ? ' · ${answer.llmModelLabel}' : ''}',
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (answer.llmFallbackNote != null &&
              answer.llmFallbackNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              answer.llmFallbackNote!,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.85),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (record != null) ...[
            const SizedBox(height: 8),
            Text(
              record.title,
              style: const TextStyle(
                color: PoliceColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _AnswerSection(
            number: '1',
            title: 'Kısa Cevap',
            body: answer.shortAnswer,
          ),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '2',
            title: 'Dayanak',
            body: answer.relatedLegislation,
          ),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '3',
            title: 'Gerekçe',
            body: answer.evaluation,
          ),
          if (answer.missingInfoNote.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _AnswerSection(
              number: '4',
              title: answer.needsClarification
                  ? 'Eksik bilgi'
                  : 'Sahada dikkat',
              body: answer.missingInfoNote,
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: record?.entryId != null ||
                      record?.moduleRoute != null ||
                      record?.sourceType == LegalSourceType.idariParaCeza
                  ? onOpenFullText
                  : null,
              icon: const PhosphorIcon(
                PhosphorIconsRegular.scroll,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Tam maddeyi aç',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: PoliceColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            answer.disclaimer,
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

class _LegalHitTile extends StatelessWidget {
  const _LegalHitTile({required this.hit, required this.onTap});

  final LegalSearchHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = hit.record;
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                      r.title,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.sourceLabel,
                      style: const TextStyle(
                        color: PoliceColors.primaryBlue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _UnifiedAnswerCard extends StatelessWidget {
  const _UnifiedAnswerCard({
    required this.result,
    required this.category,
    required this.onOpenDetail,
  });

  final SearchResult result;
  final AssistantCategory? category;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
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
          if (category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category!.label,
                style: const TextStyle(
                  color: PoliceColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            result.title,
            style: const TextStyle(
              color: PoliceColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          _AnswerSection(number: '1', title: 'Kısa Cevap', body: result.shortAnswer),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '2',
            title: 'Bulunan Kaynak',
            body: result.source,
          ),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '3',
            title: 'Uygulamada Ne Anlama Gelir',
            body: result.appContext,
          ),
          const SizedBox(height: 12),
          _AnswerSection(
            number: '4',
            title: 'İlgili Madde / Belge / Modül',
            body: result.title,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: result.nav != null ? onOpenDetail : null,
              icon: const PhosphorIcon(
                PhosphorIconsRegular.arrowSquareOut,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Detayı aç',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: PoliceColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            kLegalAssistantDisclaimer,
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

class _CompactResultTile extends StatelessWidget {
  const _CompactResultTile({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.surfaceDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                      result.title,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.category.label,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                result.relevanceScore.round().toString(),
                style: TextStyle(
                  color: PoliceColors.gold.withValues(alpha: 0.9),
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

class _CezaCardCompact extends ConsumerWidget {
  const _CezaCardCompact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ceza = ref.watch(idariParaCezaAsistanProvider);
    if (ceza == null) return const SizedBox.shrink();
    return IdariParaCezaCard(
      kayit: ceza,
      compact: true,
      onOpenModule: () => Navigator.of(context).push(
        fadeRoute(IdariParaCezaPage(initialQuery: ceza.kabahatAdi)),
      ),
    );
  }
}

