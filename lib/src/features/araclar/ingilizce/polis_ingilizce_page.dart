import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'polis_ingilizce_data.dart';

/// Polis İngilizcesi: kategorili hazır kalıplar (TR-EN + okunuş), offline.
class PolisIngilizcePage extends StatefulWidget {
  const PolisIngilizcePage({super.key});

  @override
  State<PolisIngilizcePage> createState() => _PolisIngilizcePageState();
}

class _PolisIngilizcePageState extends State<PolisIngilizcePage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fold(String s) => s
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c');

  bool _match(IngilizceKalip k, String q) =>
      _fold(k.tr).contains(q) ||
      _fold(k.en).contains(q) ||
      _fold(k.okunus).contains(q);

  @override
  Widget build(BuildContext context) {
    final q = _fold(_query.trim());
    final categories = q.isEmpty
        ? IngilizceKategori.all
        : [
            for (final c in IngilizceKategori.all)
              if (c.kaliplar.any((k) => _match(k, q)))
                IngilizceKategori(
                  id: c.id,
                  title: c.title,
                  icon: c.icon,
                  kaliplar: c.kaliplar.where((k) => _match(k, q)).toList(),
                ),
          ];

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Polis İngilizcesi'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Kalıp ara (ör. pasaport, dur, ehliyet)',
              hintStyle: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: PoliceColors.textMuted),
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'Eşleşen kalıp bulunamadı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
            )
          else
            for (final c in categories) ...[
              Row(
                children: [
                  PhosphorIcon(c.icon,
                      color: PoliceColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    c.title,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final k in c.kaliplar) _KalipCard(kalip: k),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 4),
          Text(
            'Okunuşlar yaklaşıktır. Bu kalıplar iletişimi kolaylaştırmak içindir; '
            'resmî tebligat ve haklar bildirimi mevzuata uygun şekilde yapılmalıdır.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _KalipCard extends StatelessWidget {
  const _KalipCard({required this.kalip});

  final IngilizceKalip kalip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PoliceColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kalip.tr,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    kalip.en,
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Kopyala',
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: PoliceColors.textMuted,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: kalip.en));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kopyalandı.'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (kalip.okunus.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '[${kalip.okunus}]',
                style: TextStyle(
                  color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
