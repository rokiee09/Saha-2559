import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_puan_cetvel_policy.dart';
import 'gorev_puanlari_data.dart';

/// Günlük görev puanları cetveli — tek giriş, 2025 / 2026 yıl seçimi.
class GorevPuanlariPage extends ConsumerStatefulWidget {
  const GorevPuanlariPage({super.key, this.baslangicYil});

  /// İlk açılışta seçili yıl (varsayılan 2025).
  final int? baslangicYil;

  @override
  ConsumerState<GorevPuanlariPage> createState() => _GorevPuanlariPageState();
}

class _GorevPuanlariPageState extends ConsumerState<GorevPuanlariPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late int _seciliYil;

  @override
  void initState() {
    super.initState();
    _seciliYil = widget.baslangicYil ?? 2025;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gorevPuanlariByYilProvider(_seciliYil));
    final digerYil = _seciliYil == 2025 ? 2026 : 2025;
    final digerAsync = ref.watch(gorevPuanlariByYilProvider(digerYil));

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Günlük Görev Puanları'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Puan cetveli yüklenemedi.',
            style: TextStyle(color: PoliceColors.textMuted),
          ),
        ),
        data: (set) {
          final digerSet = digerAsync.valueOrNull;
          final items = set.ara(_query);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _YilSecici(
                      secili: _seciliYil,
                      onChanged: (y) {
                        setState(() {
                          _seciliYil = y;
                          _query = '';
                          _searchCtrl.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${set.yil} görev yeri puanları',
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gorevPuanCetvelYilAciklama(set.yil),
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    if (set.bos && set.uyari != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        set.uyari!,
                        style: TextStyle(
                          color: PoliceColors.primaryBlue.withValues(alpha: 0.9),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: PoliceColors.titleOnDark),
                      decoration: InputDecoration(
                        hintText: 'İl veya ilçe ara',
                        hintStyle: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.65),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: PoliceColors.textMuted,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Temizle',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        filled: true,
                        fillColor: PoliceColors.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _query.trim().isEmpty
                          ? '${set.kayitlar.length} kayıt'
                          : '${items.length} sonuç',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                    if (digerSet != null && !digerSet.bos) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Diğer yıl ($digerYil) cetvelinde de puanlar mevcut; '
                        'yukarıdan yıl değiştirerek bakabilirsiniz.',
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.75),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            set.bos
                                ? '$_seciliYil cetveli henüz yüklenmedi.\n'
                                    'JSON dosyasına kayıtlar eklendiğinde liste dolacaktır.'
                                : _query.trim().isEmpty
                                    ? 'Kayıt bulunamadı.'
                                    : 'Aramanızla eşleşen yer yok.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: PoliceColors.textMuted),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color:
                              PoliceColors.outlineMuted.withValues(alpha: 0.25),
                        ),
                        itemBuilder: (context, i) {
                          final k = items[i];
                          final digerPuan =
                              digerSet?.bul(k.yer)?.puan;
                          return _PuanRow(
                            kayit: k,
                            seciliYil: _seciliYil,
                            digerYil: digerYil,
                            digerPuan: digerPuan,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _YilSecici extends StatelessWidget {
  const _YilSecici({required this.secili, required this.onChanged});

  final int secili;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 2025, label: Text('2025')),
        ButtonSegment(value: 2026, label: Text('2026')),
      ],
      selected: {secili},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PoliceColors.titleOnDark;
          }
          return PoliceColors.textMuted;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PoliceColors.primaryBlue;
          }
          return PoliceColors.surfaceDark;
        }),
      ),
    );
  }
}

class _PuanRow extends StatelessWidget {
  const _PuanRow({
    required this.kayit,
    required this.seciliYil,
    required this.digerYil,
    this.digerPuan,
  });

  final GorevPuaniKayit kayit;
  final int seciliYil;
  final int digerYil;
  final double? digerPuan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final digerMetin = digerPuan != null
            ? ' · $digerYil: ${formatGorevPuani(digerPuan!)}'
            : '';
        await Clipboard.setData(
          ClipboardData(
            text:
                '${kayit.yer}: $seciliYil ${formatGorevPuani(kayit.puan)}$digerMetin',
          ),
        );
        HapticFeedback.selectionClick();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${kayit.yer} kopyalandı.')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayGorevYeriAdi(kayit.yer),
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (digerPuan != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$digerYil: ${formatGorevPuani(digerPuan!)}',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.75),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$seciliYil: ${kayit.puanMetni}',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
