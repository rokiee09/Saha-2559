import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import '../icerik/icerik_uyari.dart';
import 'mutalaa_ozel_data.dart';

class MutalaaOzelPage extends ConsumerStatefulWidget {
  const MutalaaOzelPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<MutalaaOzelPage> createState() => _MutalaaOzelPageState();
}

class _MutalaaOzelPageState extends ConsumerState<MutalaaOzelPage> {
  final TextEditingController _search = TextEditingController();
  List<MutalaaKayit> _filtered = const [];
  MutalaaOzelSet? _set;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) _search.text = q;
    _search.addListener(_applyFilter);
  }

  void _applyFilter() {
    final set = _set;
    if (set == null) return;
    final q = _search.text.trim();
    setState(() {
      _filtered =
          q.isEmpty ? set.kayitlar : mutalaaEslestir(q, set.kayitlar);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openDetail(MutalaaKayit k) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MutalaaDetailPage(
          kayit: k,
          kaynak: _set?.kaynak ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mutalaaOzelProvider);
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Mütalaa Özel'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Mütalaa verisi yüklenemedi.\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
        data: (set) {
          if (!_initialized) {
            _initialized = true;
            _set = set;
            final q = widget.initialQuery?.trim();
            _filtered = q != null && q.isNotEmpty
                ? mutalaaEslestir(q, set.kayitlar)
                : set.kayitlar;
            if (_filtered.isEmpty) _filtered = set.kayitlar;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Text(
                set.kaynak,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${set.kayitlar.length} görüş · Asistan bu kaynaktan da yararlanır.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: InputDecoration(
                  hintText: 'Konu ara (aday memur, rapor, kademe…)',
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
                  'Eşleşen mütalaa bulunamadı.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  ),
                )
              else
                for (final k in _filtered.take(80))
                  _MutalaaCard(kayit: k, onTap: () => _openDetail(k)),
              if (_filtered.length > 80)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Liste 80 kayıtla sınırlandı; aramayı daraltın.',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                set.uyari,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.75),
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                kIcerikTaslakUyari,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.65),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MutalaaCard extends StatelessWidget {
  const _MutalaaCard({required this.kayit, required this.onTap});

  final MutalaaKayit kayit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PoliceColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kayit.ref.isNotEmpty)
                Text(
                  kayit.ref,
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                kayit.baslik,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              if (kayit.cevapMetni.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  kayit.cevapMetni,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.92),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MutalaaDetailPage extends StatelessWidget {
  const _MutalaaDetailPage({required this.kayit, required this.kaynak});

  final MutalaaKayit kayit;
  final String kaynak;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(
          kayit.ref.isNotEmpty ? kayit.ref : 'Mütalaa',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Metni kopyala',
            onPressed: () {
              final buf = StringBuffer();
              if (kayit.ref.isNotEmpty) buf.writeln(kayit.ref);
              buf.writeln(kayit.baslik);
              if (kayit.soruMetni.isNotEmpty) {
                buf.writeln('\nSoru / özet:\n${kayit.soruMetni}');
              }
              if (kayit.cevapMetni.isNotEmpty) {
                buf.writeln('\nGörüş:\n${kayit.cevapMetni}');
              }
              if (kayit.metin.isNotEmpty) buf.writeln('\n${kayit.metin}');
              Clipboard.setData(ClipboardData(text: buf.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metin panoya kopyalandı')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            kaynak,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            kayit.baslik,
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (kayit.soruMetni.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Soru / özet',
              style: TextStyle(
                color: PoliceColors.gold.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              kayit.soruMetni,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                height: 1.45,
              ),
            ),
          ],
          if (kayit.cevapMetni.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Başkanlık görüşü',
              style: TextStyle(
                color: PoliceColors.gold.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              kayit.cevapMetni,
              style: TextStyle(
                color: PoliceColors.titleOnDark.withValues(alpha: 0.92),
                height: 1.45,
              ),
            ),
          ],
          if (kayit.metin.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tam metin',
              style: TextStyle(
                color: PoliceColors.gold.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              kayit.metin,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
