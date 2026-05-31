import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/police_colors.dart';
import 'gorev_puanlari_data.dart';

/// 2025 görev yeri puanları cetveli (il / il-ilçe).
class GorevPuanlariPage extends ConsumerStatefulWidget {
  const GorevPuanlariPage({super.key});

  @override
  ConsumerState<GorevPuanlariPage> createState() => _GorevPuanlariPageState();
}

class _GorevPuanlariPageState extends ConsumerState<GorevPuanlariPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gorevPuanlariProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Görev Puanları'),
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
          final items = set.ara(_query);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'İl ve ilçe günlük görev yeri puanları. Tayin/atama '
                      'hesabında referans amaçlıdır; resmî tebliğ esas alınır.',
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: PoliceColors.titleOnDark),
                      decoration: InputDecoration(
                        hintText: 'Ara',
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
                    Row(
                      children: [
                        Text(
                          _query.trim().isEmpty
                              ? '${set.kayitlar.length} kayıt'
                              : '${items.length} sonuç',
                          style: TextStyle(
                            color: PoliceColors.textMuted.withValues(alpha: 0.9),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          _query.trim().isEmpty
                              ? 'Kayıt bulunamadı.'
                              : 'Aramanızla eşleşen yer yok.',
                          style: const TextStyle(color: PoliceColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: PoliceColors.outlineMuted.withValues(alpha: 0.25),
                        ),
                        itemBuilder: (context, i) {
                          final k = items[i];
                          return _PuanRow(kayit: k);
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

class _PuanRow extends StatelessWidget {
  const _PuanRow({required this.kayit});

  final GorevPuaniKayit kayit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(
          ClipboardData(text: '${kayit.yer}: ${kayit.puanMetni}'),
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
          children: [
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
            Text(
              kayit.puanMetni,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.95),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
