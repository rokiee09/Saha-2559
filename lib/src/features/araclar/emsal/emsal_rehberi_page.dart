import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../../mevzuat/mevzuat_article_detail_page.dart';
import '../icerik/icerik_uyari.dart';
import 'emsal_rehberi_data.dart';

class EmsalRehberiPage extends StatefulWidget {
  const EmsalRehberiPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<EmsalRehberiPage> createState() => _EmsalRehberiPageState();
}

class _EmsalRehberiPageState extends State<EmsalRehberiPage> {
  final TextEditingController _search = TextEditingController();
  List<EmsalKayit> _filtered = kEmsalKayitlari;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) {
      _search.text = q;
      _filtered = emsalEslestir(q);
      if (_filtered.isEmpty) _filtered = kEmsalKayitlari;
    }
    _search.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _search.text.trim();
    setState(() {
      _filtered = q.isEmpty ? kEmsalKayitlari : emsalEslestir(q);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openRef(EmsalMevzuatRef ref) {
    final entryId = ref.entryId;
    if (entryId == null || entryId.isEmpty) return;
    Navigator.of(context).push(
      fadeRoute(
        MevzuatArticleDetailPage(
          entryId: entryId,
          focusSectionId: ref.sectionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Emsal özetleri'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            'Anonim uygulama özetleri ve kontrol listeleri. Yargı kararı veya '
            'kurum görüşü değildir; mevzuatla birlikte kullanın.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Konu ara (yediemin, refakat, arama…)',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_filtered.isEmpty)
            Text(
              'Eşleşen özet bulunamadı.',
              style: TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
            )
          else
            for (final e in _filtered) _EmsalCard(kayit: e, onOpenRef: _openRef),
          const SizedBox(height: 8),
          Text(
            kIcerikTaslakUyari,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.75),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmsalCard extends StatelessWidget {
  const _EmsalCard({required this.kayit, required this.onOpenRef});

  final EmsalKayit kayit;
  final void Function(EmsalMevzuatRef ref) onOpenRef;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kayit.title,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                kayit.situation,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.92),
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                kayit.summary,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.95),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kontrol listesi',
                style: TextStyle(
                  color: PoliceColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              for (final c in kayit.checklist)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: PoliceColors.primaryBlue)),
                      Expanded(
                        child: Text(
                          c,
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.9),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (kayit.riskNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  kayit.riskNote,
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              if (kayit.mevzuatRefs.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final ref in kayit.mevzuatRefs)
                      if (ref.entryId != null)
                        ActionChip(
                          label: Text(ref.label),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            onOpenRef(ref);
                          },
                        ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
