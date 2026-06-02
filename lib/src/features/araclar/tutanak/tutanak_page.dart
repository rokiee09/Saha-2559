import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import 'tutanak_favorites.dart';
import 'tutanak_form_page.dart';
import 'tutanak_templates.dart';

/// Hazır tutanak şablonları — sık kullanılanlar üstte.
class TutanakPage extends StatefulWidget {
  const TutanakPage({super.key});

  @override
  State<TutanakPage> createState() => _TutanakPageState();
}

class _TutanakPageState extends State<TutanakPage> {
  Map<String, int> _usage = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final counts = await TutanakFavoritesStore.loadCounts();
    if (mounted) {
      setState(() {
        _usage = counts;
        _loading = false;
      });
    }
  }

  List<TutanakTemplate> get _sorted {
    final ids = TutanakFavoritesStore.sortByUsage(
      TutanakTemplate.all.map((t) => t.id).toList(),
      _usage,
    );
    return ids
        .map(TutanakTemplate.byId)
        .whereType<TutanakTemplate>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final templates = _sorted;
    final hasFavorites = _usage.values.any((c) => c > 0);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Hazır Şablonlar'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.info,
                  color: PoliceColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Şablonu seç, alanları doldur. Tutanak kontrolü eksik '
                    'bilgileri uyarır; PDF paylaşabilirsin.',
                    style: TextStyle(
                      color: PoliceColors.titleOnDark.withValues(alpha: 0.9),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasFavorites && !_loading) ...[
            const SizedBox(height: 14),
            Text(
              'Sık kullanılanlar',
              style: TextStyle(
                color: PoliceColors.gold.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            for (final t in templates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TemplateTile(
                  template: t,
                  useCount: _usage[t.id] ?? 0,
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await Navigator.of(context).push(
                      fadeRoute(TutanakFormPage(templateId: t.id)),
                    );
                    await _loadUsage();
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.useCount,
    required this.onTap,
  });

  final TutanakTemplate template;
  final int useCount;
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PhosphorIcon(
                  template.icon,
                  color: PoliceColors.primaryBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      template.description,
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (useCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '×$useCount',
                    style: TextStyle(
                      color: PoliceColors.gold.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                color: PoliceColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
