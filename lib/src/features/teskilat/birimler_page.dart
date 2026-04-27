import 'package:flutter/material.dart';

/// EGM merkez teşkilatı daire başkanlıkları (listeleme; güncel teşkilat EGM’ye tabidir).
class BirimlerPage extends StatefulWidget {
  const BirimlerPage({super.key});

  @override
  State<BirimlerPage> createState() => _BirimlerPageState();
}

class _BirimlerPageState extends State<BirimlerPage> {
  String _search = '';
  String? _letterFilter;

  static const _letterChips = <String>['A', 'B', 'D', 'G', 'H', 'İ', 'K', 'M', 'S', 'T'];

  static const _daireler = <String>[
    'Asayiş Daire Başkanlığı',
    'Belge Yönetimi ve Koordinasyon Daire Başkanlığı',
    'Bilgi Teknolojileri ve Haberleşme Daire Başkanlığı',
    'Destek Hizmetleri Daire Başkanlığı',
    'Dış İlişkiler Daire Başkanlığı',
    'Göçmen Kaçakçılığıyla Mücadele ve Hudut Kapıları Daire Başkanlığı',
    'Güvenlik Daire Başkanlığı',
    'Havacılık Daire Başkanlığı',
    'İnşaat Emlak Daire Başkanlığı',
    'İnterpol-Europol Daire Başkanlığı',
    'Koruma Daire Başkanlığı',
    'Kriminal Daire Başkanlığı',
    'Medya-Halkla İlişkiler ve Protokol Daire Başkanlığı',
    'Siber Suçlarla Mücadele Daire Başkanlığı',
    'Sosyal Hizmetler ve Sağlık Daire Başkanlığı',
    'Strateji Geliştirme Daire Başkanlığı',
    'Tanık Koruma Dairesi Başkanlığı',
    'TBMM Koruma Dairesi Başkanlığı',
    'Terörle Mücadele Dairesi Başkanlığı',
  ];

  bool _nameMatchesQuery(String n) {
    final q = _search.trim();
    if (q.isEmpty) return true;
    return n.toLowerCase().contains(q.toLowerCase());
  }

  List<String> _filteredList() {
    return _daireler.where((n) {
      if (!_nameMatchesQuery(n)) return false;
      if (_letterFilter == null) return true;
      if (n.isEmpty) return false;
      return n[0] == _letterFilter;
    }).toList()..sort((a, b) => a.compareTo(b));
  }

  bool get _useGroupedView =>
      _search.trim().isEmpty && _letterFilter == null;

  Map<String, List<String>> _groupedForDisplay() {
    final m = <String, List<String>>{};
    for (final n in _daireler) {
      if (n.isEmpty) continue;
      final L = n[0];
      m.putIfAbsent(L, () => []).add(n);
    }
    for (final e in m.values) {
      e.sort((a, b) => a.compareTo(b));
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daire Başkanlıkları'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Emniyet Genel Müdürlüğü merkez teşkilatı daire başkanlıkları (güncel teşkilat değişiklikleri resmî kaynaklara tabidir).',
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Arama',
                prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    showCheckmark: false,
                    label: const Text('Tümü'),
                    selected: _letterFilter == null,
                    onSelected: (_) => setState(() => _letterFilter = null),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                for (final L in _letterChips)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      showCheckmark: false,
                      label: Text(L),
                      selected: _letterFilter == L,
                      onSelected: (v) => setState(() => _letterFilter = v ? L : null),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _useGroupedView
                ? _GroupedList(
                    letterOrder: _letterChips,
                    grouped: _groupedForDisplay(),
                    colorScheme: cs,
                    textTheme: textTheme,
                  )
                : _buildFlatList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatList(BuildContext context) {
    final list = _filteredList();
    final cs = Theme.of(context).colorScheme;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Sonuç yok. Aramayı veya harf filtresini değiştirin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Icon(
              Icons.apartment_outlined,
              size: 22,
              color: cs.onSurfaceVariant,
            ),
            title: Text(
              list[i],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
  }
}

class _GroupedList extends StatelessWidget {
  final List<String> letterOrder;
  final Map<String, List<String>> grouped;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _GroupedList({
    required this.letterOrder,
    required this.grouped,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final L in letterOrder) {
      final items = grouped[L];
      if (items == null || items.isEmpty) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            L,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      for (final name in items) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: Icon(
                  Icons.apartment_outlined,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}
