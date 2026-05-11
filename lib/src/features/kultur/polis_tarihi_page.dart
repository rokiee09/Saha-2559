import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'polis_tarihi_parser.dart';

class PolisTarihiPage extends StatefulWidget {
  const PolisTarihiPage({super.key});

  @override
  State<PolisTarihiPage> createState() => _PolisTarihiPageState();
}

class _PolisTarihiPageState extends State<PolisTarihiPage> {
  late final Future<List<PolisTarihiBlock>> _blocksFuture;

  @override
  void initState() {
    super.initState();
    _blocksFuture = _loadBlocks();
  }

  static Future<List<PolisTarihiBlock>> _loadBlocks() async {
    final buf = StringBuffer();
    const parts = <String>[
      'assets/kultur/polis_p1.txt',
      'assets/kultur/polis_p2.txt',
      'assets/kultur/polis_p3.txt',
      'assets/kultur/polis_p4.txt',
    ];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) buf.writeln('\n---\n');
      buf.write((await rootBundle.loadString(parts[i])).trim());
    }
    return parsePolisTarihiRaw(buf.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polis Tarihi')),
      body: FutureBuilder<List<PolisTarihiBlock>>(
        future: _blocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Metin yüklenemedi.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final blocks = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarihte Polis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Türk polis teşkilatının tarihsel gelişimi; eski Türk devletlerinden Osmanlı’ya ve Cumhuriyet dönemine uzanan özet bir anlatıdır. Bölüm başlıklarına göre düzenlenmiştir.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                for (var b = 0; b < blocks.length; b++) ...[
                  _SectionBlock(block: blocks[b]),
                  if (b < blocks.length - 1) const SizedBox(height: 28),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final PolisTarihiBlock block;

  const _SectionBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          block.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < block.paragraphs.length; i++) ...[
          SelectableText(
            block.paragraphs[i],
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
          if (i < block.paragraphs.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
