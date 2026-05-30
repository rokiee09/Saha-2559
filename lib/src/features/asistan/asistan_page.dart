import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../home/root_drawer_scope.dart';
import '../mevzuat/mevzuat_article_detail_page.dart';
import 'asistan_provider.dart';

/// Asistan: paket içindeki mevzuat üzerinde offline anahtar kelime araması.
/// "Kanun GPT" mantığı — soru yaz, ilgili maddeyi ve kaynağı gör.
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

  void _applyTopic(String query) {
    HapticFeedback.selectionClick();
    _controller.text = query;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _runQuery(query);
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
    final resultsAsync = ref.watch(asistanResultsProvider);
    final answer = ref.watch(asistanAnswerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Asistan',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
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
                  'Bugün ne öğrenmek istiyorsun?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final topic in asistanQuickTopics)
                      _TopicChip(
                        label: topic.label,
                        onTap: () => _applyTopic(topic.query),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? const _AsistanIntro()
                : resultsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: PoliceColors.primaryBlue,
                      ),
                    ),
                    error: (_, __) => const _AsistanMessage(
                      icon: Icons.error_outline_rounded,
                      title: 'Arama yapılamadı',
                      message: 'Lütfen tekrar deneyin.',
                    ),
                    data: (hits) {
                      if (hits.isEmpty && answer == null) {
                        return const _AsistanMessage(
                          icon: Icons.search_off_rounded,
                          title: 'Sonuç bulunamadı',
                          message:
                              'Farklı bir kelime deneyin. Örnek: yakalama, zor kullanma, arama, ifade.',
                        );
                      }
                      final hasAnswer = answer != null;
                      final leadCount = hasAnswer ? 1 : 0;
                      final headerIndex = leadCount;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: leadCount + 1 + hits.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          if (hasAnswer && i == 0) {
                            return _AnswerCard(
                              answer: answer,
                              onOpenRef: _openSection,
                            );
                          }
                          if (i == headerIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 2),
                              child: Text(
                                hits.isEmpty
                                    ? 'İlgili madde yukarıda · paket içi mevzuattan'
                                    : '${hits.length} sonuç · paket içi mevzuattan',
                                style: TextStyle(
                                  color: PoliceColors.textMuted
                                      .withValues(alpha: 0.9),
                                  fontSize: 12.5,
                                ),
                              ),
                            );
                          }
                          final hit = hits[i - leadCount - 1];
                          return _ResultCard(
                            hit: hit,
                            onTap: () =>
                                _openSection(hit.entry.id, hit.section.id),
                          );
                        },
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
        hintText: 'Örn. "PVSK zor kullanma" veya "refakat izni"',
        prefixIcon: Icon(
          Icons.auto_awesome_outlined,
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

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
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
          padding: const EdgeInsets.all(16),
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
                    fontSize: 15.5,
                    height: 1.25,
                  ),
                ),
              if (hit.section.title.trim().isNotEmpty)
                const SizedBox(height: 6),
              Text(
                hit.snippet(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.92),
                  height: 1.42,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.scroll,
                    size: 16,
                    color: PoliceColors.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kaynak: ${hit.sourceLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PoliceColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const PhosphorIcon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: PoliceColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soru-cevap kartı: kavram özeti + "Kaynağa Git" derin linkleri.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer, required this.onOpenRef});

  final AsistanAnswer answer;
  final void Function(String entryId, String? sectionId) onOpenRef;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsFill.sparkle,
                size: 18,
                color: PoliceColors.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer.concept.label.isEmpty
                      ? 'Özet cevap'
                      : answer.concept.label,
                  style: const TextStyle(
                    color: PoliceColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            answer.concept.answer,
            style: TextStyle(
              color: PoliceColors.titleOnDark.withValues(alpha: 0.95),
              height: 1.5,
              fontSize: 14.5,
            ),
          ),
          if (answer.resolvedRefs.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Kaynağa git',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in answer.resolvedRefs)
                  _RefButton(
                    label: r.label,
                    onTap: () => onOpenRef(r.entryId, r.sectionId),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Bilgilendirme amaçlıdır; hukuki görüş değildir. Bağlayıcı metin için kaynağa bakın.',
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

class _RefButton extends StatelessWidget {
  const _RefButton({required this.label, required this.onTap});

  final String label;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.5),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const PhosphorIcon(
                PhosphorIconsRegular.arrowRight,
                size: 13,
                color: PoliceColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AsistanIntro extends StatelessWidget {
  const _AsistanIntro();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
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
                    PhosphorIconsRegular.magnifyingGlass,
                    color: PoliceColors.primaryBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yaz, kanunu bul',
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
                'Bir konu veya kelime yaz; uygulamadaki kanun ve yönetmeliklerde '
                'eşleşen maddeleri ve kaynağını gösterir. İnternet kullanmaz, '
                'her şey cihazda kalır.',
                style: TextStyle(
                  color: PoliceColors.mevzuatBodyText.withValues(alpha: 0.9),
                  height: 1.45,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bilgilendirme amaçlıdır; hukuki görüş veya resmî kaynak değildir. '
                'Güncel ve bağlayıcı metin için resmî kaynağa bakın.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.85),
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: PoliceColors.primaryBlue.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PoliceColors.titleOnDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
