import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_hizmet_sureleri_data.dart';
import 'gorev_puanlari_data.dart';

/// EK-1 sayılı cetvel — il / ilçe zorunlu hizmet süreleri (2026 düzenlemesi).
class GorevHizmetSureleriPage extends ConsumerStatefulWidget {
  const GorevHizmetSureleriPage({super.key});

  @override
  ConsumerState<GorevHizmetSureleriPage> createState() =>
      _GorevHizmetSureleriPageState();
}

class _GorevHizmetSureleriPageState
    extends ConsumerState<GorevHizmetSureleriPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _bolgeFiltre;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gorevHizmetSureleriProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Zorunlu Hizmet Süreleri'),
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
            'Hizmet süreleri cetveli yüklenemedi.',
            style: TextStyle(color: PoliceColors.textMuted),
          ),
        ),
        data: (set) {
          final items = set.ara(_query, bolgeFiltre: _bolgeFiltre);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EK-1 Sayılı Cetvel',
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5 Aralık 2025 tarihli Cumhurbaşkanlığı Kararı (10665) ile '
                      'güncellenen zorunlu hizmet süreleri ve bölge bilgisi.',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    if (set.kaynak != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        set.kaynak!,
                        style: TextStyle(
                          color: PoliceColors.primaryBlue.withValues(alpha: 0.85),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                    if (set.eksikSnAraligi != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D2E10).withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: PoliceColors.gold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Cetvelde eksik kayıt: ${set.eksikSnAraligi}. '
                          'Resmî EK-1 ile karşılaştırın.',
                          style: TextStyle(
                            color: PoliceColors.gold.withValues(alpha: 0.95),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _BolgeFiltre(
                      secili: _bolgeFiltre,
                      onChanged: (v) => setState(() => _bolgeFiltre = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: PoliceColors.titleOnDark),
                      decoration: InputDecoration(
                        hintText: 'İl, ilçe veya birim ara',
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
                      _query.trim().isEmpty && _bolgeFiltre == null
                          ? '${set.kayitlar.length} kayıt'
                          : '${items.length} sonuç',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                    if (set.uyari != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        set.uyari!,
                        style: TextStyle(
                          color: PoliceColors.textMuted.withValues(alpha: 0.75),
                          fontSize: 11.5,
                          height: 1.35,
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
                                ? 'Cetvel henüz yüklenmedi.'
                                : 'Aramanızla eşleşen kayıt yok.',
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
                        itemBuilder: (context, i) => _HizmetRow(kayit: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BolgeFiltre extends StatelessWidget {
  const _BolgeFiltre({required this.secili, required this.onChanged});

  final int? secili;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Tümü'),
          selected: secili == null,
          onSelected: (_) => onChanged(null),
          selectedColor: PoliceColors.primaryBlue.withValues(alpha: 0.35),
          checkmarkColor: PoliceColors.titleOnDark,
          labelStyle: TextStyle(
            color: secili == null
                ? PoliceColors.titleOnDark
                : PoliceColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        FilterChip(
          label: const Text('1. bölge'),
          selected: secili == 1,
          onSelected: (_) => onChanged(1),
          selectedColor: PoliceColors.primaryBlue.withValues(alpha: 0.35),
          checkmarkColor: PoliceColors.titleOnDark,
          labelStyle: TextStyle(
            color: secili == 1
                ? PoliceColors.titleOnDark
                : PoliceColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        FilterChip(
          label: const Text('2. bölge (şark)'),
          selected: secili == 2,
          onSelected: (_) => onChanged(2),
          selectedColor: PoliceColors.gold.withValues(alpha: 0.25),
          checkmarkColor: PoliceColors.titleOnDark,
          labelStyle: TextStyle(
            color: secili == 2
                ? PoliceColors.titleOnDark
                : PoliceColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _HizmetRow extends StatelessWidget {
  const _HizmetRow({required this.kayit});

  final GorevHizmetSuresiKayit kayit;

  @override
  Widget build(BuildContext context) {
    final bolgeRenk =
        kayit.bolge == 2 ? PoliceColors.gold : PoliceColors.primaryBlue;

    return InkWell(
      onTap: () async {
        await Clipboard.setData(
          ClipboardData(
            text:
                '${kayit.yer}: ${kayit.bolgeMetni}, ${kayit.yilMetni}',
          ),
        );
        HapticFeedback.selectionClick();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${displayGorevYeriAdi(kayit.yer)} kopyalandı.')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36,
              child: Text(
                '${kayit.sn}',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                displayGorevYeriAdi(kayit.yer),
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  kayit.yilMetni,
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bolgeRenk.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    kayit.bolgeMetni,
                    style: TextStyle(
                      color: bolgeRenk,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
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
