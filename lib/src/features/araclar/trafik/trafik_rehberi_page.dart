import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common/routing/transitions.dart';
import '../../../common/theme/police_colors.dart';
import '../idari_para_ceza/idari_para_ceza_page.dart';
import '../icerik/icerik_uyari.dart';
import 'trafik_rehberi_data.dart';

class TrafikRehberiPage extends StatefulWidget {
  const TrafikRehberiPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<TrafikRehberiPage> createState() => _TrafikRehberiPageState();
}

class _TrafikRehberiPageState extends State<TrafikRehberiPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) _search.text = q;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TrafikKonu> get _visible {
    final q = _search.text.trim();
    if (q.isEmpty) return kTrafikKonulari;
    final hits = trafikEslestir(q);
    return hits.isEmpty ? kTrafikKonulari : hits;
  }

  void _openIdariPara() {
    Navigator.of(context).push(
      fadeRoute(IdariParaCezaPage(initialQuery: _search.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Trafik rehberi'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            'Saha trafik kontrolünde adım adım kontrol listesi. İdari para '
            'cezaları için ayrı modüle geçebilirsiniz.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Alkol, hız, kaza…',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              _openIdariPara();
            },
            icon: const Icon(Icons.payments_outlined),
            label: const Text('İdari para cezaları listesi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PoliceColors.primaryBlue,
              side: BorderSide(color: PoliceColors.primaryBlue.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(height: 14),
          for (final konu in _visible) _KonuCard(konu: konu),
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

class _KonuCard extends StatelessWidget {
  const _KonuCard({required this.konu});

  final TrafikKonu konu;

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
                konu.title,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                konu.summary,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.92),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              if (konu.mevzuatNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  konu.mevzuatNote,
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.85),
                    fontSize: 11.5,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              for (var i = 0; i < konu.steps.length; i++) ...[
                Text(
                  '${i + 1}. ${konu.steps[i].title}',
                  style: const TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  konu.steps[i].detail,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
