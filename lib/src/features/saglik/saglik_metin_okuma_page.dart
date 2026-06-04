import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/text/tr_text.dart';
import '../../common/theme/police_colors.dart';
import 'saglik_metin.dart';
import 'saglik_metin_provider.dart';

/// Sağlık yönetmeliği / uygulama rehberi okuma ekranı.
class SaglikMetinOkumaPage extends ConsumerStatefulWidget {
  const SaglikMetinOkumaPage({
    super.key,
    required this.metinId,
    this.focusSectionId,
  });

  final SaglikMetinId metinId;
  final String? focusSectionId;

  @override
  ConsumerState<SaglikMetinOkumaPage> createState() =>
      _SaglikMetinOkumaPageState();
}

class _SaglikMetinOkumaPageState extends ConsumerState<SaglikMetinOkumaPage> {
  String _query = '';
  final _scrollCtrl = ScrollController();
  final _keys = <String, GlobalKey>{};

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<SaglikMetinBolum> _filter(SaglikMetinBelge doc) {
    final q = trFold(_query.trim());
    if (q.isEmpty) return doc.sections;
    return doc.sections
        .where(
          (s) =>
              trFold(s.article).contains(q) ||
              trFold(s.title).contains(q) ||
              trFold(s.text).contains(q),
        )
        .toList();
  }

  void _scrollToFocus(SaglikMetinBelge doc) {
    final id = widget.focusSectionId;
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _keys[id];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(saglikMetinProvider(widget.metinId));

    return async.when(
      loading: () => Scaffold(
        backgroundColor: PoliceColors.backgroundDark,
        appBar: AppBar(
          title: Text(widget.metinId.listTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: PoliceColors.backgroundDark,
        appBar: AppBar(title: Text(widget.metinId.listTitle)),
        body: const Center(child: Text('Metin yüklenemedi.')),
      ),
      data: (doc) {
        _scrollToFocus(doc);
        final sections = _filter(doc);
        return Scaffold(
          backgroundColor: PoliceColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: PoliceColors.navy,
            foregroundColor: PoliceColors.titleOnDark,
            title: Text(doc.displayTitle),
            shape: Border(
              bottom: BorderSide(
                color: PoliceColors.accentMix(0.34),
                width: 1,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      doc.subtitle,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    if (doc.disclaimer != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PoliceColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: PoliceColors.gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          doc.disclaimer!,
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.92),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: PoliceColors.titleOnDark),
                      decoration: InputDecoration(
                        hintText: 'Metin içinde ara…',
                        hintStyle: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.55),
                        ),
                        filled: true,
                        fillColor: PoliceColors.surfaceDark,
                        prefixIcon: const PhosphorIcon(
                          PhosphorIconsRegular.magnifyingGlass,
                          color: PoliceColors.textMuted,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  itemCount: sections.length,
                  itemBuilder: (context, i) {
                    final s = sections[i];
                    _keys.putIfAbsent(s.id, GlobalKey.new);
                    final focused = widget.focusSectionId == s.id;
                    return Container(
                      key: _keys[s.id],
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PoliceColors.surfaceDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: focused
                              ? PoliceColors.saglikAccent.withValues(alpha: 0.55)
                              : PoliceColors.outlineMuted.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.article,
                            style: TextStyle(
                              color: PoliceColors.saglikAccent
                                  .withValues(alpha: 0.95),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          if (s.title.isNotEmpty &&
                              !s.title.startsWith('Bölüm')) ...[
                            const SizedBox(height: 4),
                            Text(
                              s.title,
                              style: const TextStyle(
                                color: PoliceColors.titleOnDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                          if (s.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SelectableText(
                              s.text,
                              style: const TextStyle(
                                color: PoliceColors.mevzuatBodyText,
                                fontSize: 13.5,
                                height: 1.48,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
