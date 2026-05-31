import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../common/text/tr_text.dart';
import '../../common/theme/police_colors.dart';
import 'telsiz_kodlari_data.dart';

class TelsizKodlariPage extends StatefulWidget {
  const TelsizKodlariPage({super.key});

  @override
  State<TelsizKodlariPage> createState() => _TelsizKodlariPageState();
}

class _TelsizKodlariPageState extends State<TelsizKodlariPage> {
  final _searchCtrl = TextEditingController();
  TelsizKodKategori? _kategori;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TelsizKod> get _filtered {
    final q = trFold(_query.trim());
    return kTelsizKodlari.where((kod) {
      if (_kategori != null && kod.kategori != _kategori) return false;
      if (q.isEmpty) return true;
      return trFold(kod.kod).contains(q) ||
          trFold(kod.anlam).contains(q) ||
          trFold(kod.kategori.label).contains(q) ||
          trFold(kod.not ?? '').contains(q);
    }).toList();
  }

  Future<void> _copy(TelsizKod kod) async {
    await Clipboard.setData(ClipboardData(text: '${kod.kod} - ${kod.anlam}'));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${kod.kod} kopyalandı.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Telsiz Kodları'),
        shape: Border(
          bottom: BorderSide(color: PoliceColors.accentMix(0.34), width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          const _HeroCard(),
          const SizedBox(height: 14),
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: InputDecoration(
              hintText: 'Kod veya anlam ara (ör. 33-10, trafik)',
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
          _CategoryChips(
            selected: _kategori,
            onChanged: (v) => setState(() => _kategori = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _query.trim().isEmpty && _kategori == null
                    ? 'Tüm kodlar'
                    : '${items.length} sonuç',
                style: const TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '${kTelsizKodlari.length} kayıt',
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
                'Eşleşen telsiz kodu bulunamadı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PoliceColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
            )
          else
            for (final kod in items) _TelsizCodeCard(kod: kod, onCopy: _copy),
          const SizedBox(height: 8),
          const _DisclaimerCard(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PoliceColors.primaryBlue.withValues(alpha: 0.26),
            PoliceColors.surfaceDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PoliceColors.primaryBlue.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const PhosphorIcon(
              PhosphorIconsRegular.broadcast,
              color: PoliceColors.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sabit saha kodları',
                  style: TextStyle(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '33-10 İl Emniyet Müdürü gibi protokol ve birim çağrı kodlarını hızlı ara.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.94),
                    fontSize: 12.8,
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.onChanged,
  });

  final TelsizKodKategori? selected;
  final ValueChanged<TelsizKodKategori?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              showCheckmark: false,
              selected: selected == null,
              label: const Text('Tümü'),
              onSelected: (_) => onChanged(null),
              visualDensity: VisualDensity.compact,
            ),
          ),
          for (final kategori in TelsizKodKategori.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                showCheckmark: false,
                selected: selected == kategori,
                label: Text(kategori.label),
                onSelected: (_) => onChanged(kategori),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

class _TelsizCodeCard extends StatelessWidget {
  const _TelsizCodeCard({
    required this.kod,
    required this.onCopy,
  });

  final TelsizKod kod;
  final ValueChanged<TelsizKod> onCopy;

  Color get _accent => switch (kod.kategori) {
        TelsizKodKategori.protokol => PoliceColors.gold,
        TelsizKodKategori.birim => const Color(0xFF94A3B8),
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: PoliceColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onCopy(kod),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent.withValues(alpha: 0.34),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 78,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.28)),
                  ),
                  child: Text(
                    kod.kod,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kod.anlam,
                        style: const TextStyle(
                          color: PoliceColors.titleOnDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _SmallBadge(text: kod.kategori.label, color: accent),
                          if (kod.not case final note?)
                            Text(
                              note,
                              style: TextStyle(
                                color: PoliceColors.textMuted
                                    .withValues(alpha: 0.9),
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Kopyala',
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: PoliceColors.textMuted,
                  onPressed: () => onCopy(kod),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Not: Telsiz çağrı kodları kurum içi talimatlarla güncellenebilir. '
        'Bu liste hızlı saha hafızası içindir; görevde güncel kurum talimatı esastır.',
        style: TextStyle(
          color: Colors.orange.shade100,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}
