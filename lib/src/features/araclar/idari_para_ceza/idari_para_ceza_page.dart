import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../common/theme/police_colors.dart';
import 'idari_para_ceza_data.dart';
import 'idari_para_ceza_favorites.dart';
import 'widgets/idari_para_ceza_card.dart';

/// 2026 idari para cezaları — arama, filtre, sıralama ve favoriler.
class IdariParaCezaPage extends ConsumerStatefulWidget {
  const IdariParaCezaPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<IdariParaCezaPage> createState() => _IdariParaCezaPageState();
}

class _IdariParaCezaPageState extends ConsumerState<IdariParaCezaPage> {
  late final TextEditingController _searchCtrl;
  String _query = '';
  String? _kanun;
  String? _madde;
  IdariParaCezaSirala _sirala = IdariParaCezaSirala.varsayilan;
  bool _yalnizFavoriler = false;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchCtrl = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onKanunChanged(String? v) {
    setState(() {
      _kanun = v;
      _madde = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(idariParaCezaProvider);
    final favoriler = ref.watch(idariParaCezaFavoritesProvider);

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('İdari Para Cezaları'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
        actions: [
          PopupMenuButton<IdariParaCezaSirala>(
            tooltip: 'Sırala',
            icon: const PhosphorIcon(
              PhosphorIconsRegular.sortAscending,
              color: PoliceColors.titleOnDark,
            ),
            color: PoliceColors.surfaceDarkElevated,
            onSelected: (v) => setState(() => _sirala = v),
            itemBuilder: (context) => [
              _sortItem(
                IdariParaCezaSirala.varsayilan,
                'Varsayılan',
                _sirala == IdariParaCezaSirala.varsayilan,
              ),
              _sortItem(
                IdariParaCezaSirala.cezaDesc,
                'Ceza (yüksek → düşük)',
                _sirala == IdariParaCezaSirala.cezaDesc,
              ),
              _sortItem(
                IdariParaCezaSirala.cezaAsc,
                'Ceza (düşük → yüksek)',
                _sirala == IdariParaCezaSirala.cezaAsc,
              ),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PoliceColors.primaryBlue),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Ceza cetveli yüklenemedi.',
            style: TextStyle(color: PoliceColors.textMuted),
          ),
        ),
        data: (set) {
          final maddeler = set.maddelerForKanun(_kanun);
          final items = set.filtrele(
            query: _query,
            kanun: _kanun,
            madde: _madde,
            yalnizFavoriler: _yalnizFavoriler,
            favoriIds: favoriler,
            sirala: _sirala,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              _HeroCard(yil: set.yil, kaynak: set.kaynak),
              const SizedBox(height: 14),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: PoliceColors.titleOnDark),
                decoration: InputDecoration(
                  hintText: 'Kabahat, kanun veya madde ara',
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
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              _FilterRow(
                label: 'Kanun',
                value: _kanun,
                options: set.kanunlar,
                onChanged: _onKanunChanged,
              ),
              const SizedBox(height: 8),
              _FilterRow(
                label: 'Madde',
                value: _madde,
                options: maddeler,
                onChanged: (v) => setState(() => _madde = v),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(
                      'Favoriler (${favoriler.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _yalnizFavoriler
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    selected: _yalnizFavoriler,
                    onSelected: (v) => setState(() => _yalnizFavoriler = v),
                    selectedColor: const Color(0xFFFCD34D).withValues(alpha: 0.22),
                    checkmarkColor: const Color(0xFFFCD34D),
                    backgroundColor: PoliceColors.surfaceDark,
                    side: BorderSide(
                      color: _yalnizFavoriler
                          ? const Color(0xFFFCD34D).withValues(alpha: 0.55)
                          : PoliceColors.outlineMuted.withValues(alpha: 0.4),
                    ),
                  ),
                  if (_kanun != null || _madde != null || _yalnizFavoriler)
                    ActionChip(
                      label: const Text('Filtreleri temizle', style: TextStyle(fontSize: 12)),
                      onPressed: () => setState(() {
                        _kanun = null;
                        _madde = null;
                        _yalnizFavoriler = false;
                      }),
                      backgroundColor: PoliceColors.surfaceDark,
                      side: BorderSide(
                        color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${items.length} kayıt',
                    style: const TextStyle(
                      color: PoliceColors.titleOnDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${set.kayitlar.length} toplam · ${set.yil}',
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    _yalnizFavoriler
                        ? 'Henüz favori ceza eklemediniz.'
                        : 'Aramanızla eşleşen kayıt bulunamadı.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    ),
                  ),
                )
              else
                for (final kayit in items) ...[
                  IdariParaCezaCard(
                    kayit: kayit,
                    favori: favoriler.contains(kayit.id),
                    onFavoriteToggle: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(idariParaCezaFavoritesProvider.notifier)
                          .toggle(kayit.id);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              const _DisclaimerCard(),
            ],
          );
        },
      ),
    );
  }

  PopupMenuItem<IdariParaCezaSirala> _sortItem(
    IdariParaCezaSirala value,
    String label,
    bool selected,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (selected)
            const PhosphorIcon(
              PhosphorIconsFill.check,
              size: 16,
              color: Color(0xFFFCD34D),
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: PoliceColors.titleOnDark,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.yil, required this.kaynak});

  final int yil;
  final String kaynak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PoliceColors.navy.withValues(alpha: 0.95),
            PoliceColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PoliceColors.accentMix(0.32)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCD34D).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFCD34D).withValues(alpha: 0.4),
              ),
            ),
            child: const PhosphorIcon(
              PhosphorIconsRegular.coins,
              color: Color(0xFFFCD34D),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$yil İdari Para Cezaları',
                  style: const TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kaynak.isEmpty
                      ? 'Kabahatler ve ilgili kanunlara göre güncel tutarlar.'
                      : kaynak,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: value,
            isExpanded: true,
            dropdownColor: PoliceColors.surfaceDarkElevated,
            decoration: InputDecoration(
              filled: true,
              fillColor: PoliceColors.surfaceDark,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
            hint: Text(
              'Tümü',
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            style: const TextStyle(
              color: PoliceColors.titleOnDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.9),
                  ),
                ),
              ),
              for (final o in options)
                DropdownMenuItem(
                  value: o,
                  child: Text(
                    o,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PoliceColors.surfaceDark.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PoliceColors.outlineMuted.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        '2026 yılı idari para ceza miktarları referans amaçlıdır. '
        'Resmî tebliğ ve güncel mevzuat esas alınmalıdır.',
        style: TextStyle(
          color: PoliceColors.textMuted.withValues(alpha: 0.88),
          fontSize: 11.5,
          height: 1.4,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
