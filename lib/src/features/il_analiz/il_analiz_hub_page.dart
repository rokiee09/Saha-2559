import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import 'il_analiz_compare_page.dart';
import 'il_analiz_display.dart';
import 'il_analiz_data.dart';
import 'il_analiz_detail_page.dart';
import 'il_analiz_models.dart';
import 'tazminat_tablo_page.dart';

/// İl analiz ve tayin karar destek — ana giriş.
class IlAnalizHubPage extends ConsumerStatefulWidget {
  const IlAnalizHubPage({super.key});

  @override
  ConsumerState<IlAnalizHubPage> createState() => _IlAnalizHubPageState();
}

class _IlAnalizHubPageState extends ConsumerState<IlAnalizHubPage> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openProfil(IlAnalizProfil p) {
    Navigator.of(context).push(
      fadeRoute(IlAnalizDetailPage(profil: p)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ilAnalizKatalogProvider);
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('İl Analizi'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.table),
            tooltip: 'Tazminat tablosu',
            onPressed: () => Navigator.of(context).push(
              fadeRoute(const TazminatTabloPage()),
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowsLeftRight),
            tooltip: 'İl karşılaştır',
            onPressed: () => Navigator.of(context).push(
              fadeRoute(const IlAnalizComparePage(initialLeft: 'aydin')),
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Yüklenemedi: $e')),
        data: (k) {
          final list = k.ara(_q);
          final hazir = k.hazirProfiller().length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Text(
                'Tayin, lojman ve yaşam kalitesi için 30 saniyede il profili. '
                'Kart ve puan odaklı — uzun metin değil.',
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$hazir il detaylı profil · ${k.iller.length} il listeleniyor',
                style: TextStyle(
                  color: PoliceColors.gold.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _q = v),
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: InputDecoration(
                  hintText: 'İl veya plaka ara…',
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
              if (list.isEmpty)
                Text(
                  'Eşleşen il yok.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  ),
                )
              else
                for (final il in list)
                  _IlListTile(
                    il: il,
                    onTap: () {
                      final p = il.profil;
                      if (p != null && (il.hazir || il.polisOzetiVar)) {
                        _openProfil(p);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${il.ad} detaylı profili hazırlanıyor.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
              const SizedBox(height: 8),
              Text(
                k.kaynakNotu,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.65),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IlListTile extends StatelessWidget {
  const _IlListTile({required this.il, required this.onTap});

  final IlAnalizOzet il;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = il.profil;
    final skor = p != null ? ilGenelSkorFromProfil(p) : null;
    final manualSkor = p != null ? ilGenelSkor(p.puanlar) : null;
    final skorRenk = manualSkor != null
        ? PoliceColors.gold
        : PoliceColors.primaryBlue;
    return Card(
      color: PoliceColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (il.hazir
                          ? PoliceColors.primaryBlue
                          : PoliceColors.textMuted)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  il.plaka,
                  style: TextStyle(
                    color: il.hazir
                        ? PoliceColors.primaryBlue
                        : PoliceColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      il.ad,
                      style: const TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      il.hazir
                          ? (p != null
                              ? (ilListePolisOzeti(p).isNotEmpty
                                  ? ilListePolisOzeti(p)
                                  : 'Profil hazır')
                              : 'Profil hazır')
                          : (p != null && ilListePolisOzeti(p).isNotEmpty
                              ? ilListePolisOzeti(p)
                              : 'Özet profil yakında'),
                      style: TextStyle(
                        color: PoliceColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (skor != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: skorRenk.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$skor',
                    style: TextStyle(
                      color: skorRenk.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                Icon(
                  PhosphorIconsRegular.clock,
                  color: PoliceColors.textMuted.withValues(alpha: 0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
