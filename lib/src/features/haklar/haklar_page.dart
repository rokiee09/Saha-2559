import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../home/root_drawer_scope.dart';
import 'haklar_data.dart';
import 'haklar_detail_page.dart';
import 'haklar_provider.dart';
import 'maas_hesaplama_page.dart';
const _haklarDisclaimer =
    'Aşağıdaki başlıklar yürürlükteki kanun ve yönetmeliklere dayalı özetlerdir; güncel metin, resmî kaynak, Emniyet duyuruları ve kurum işlemi esas alınır.';

class HaklarPage extends ConsumerWidget {
  const HaklarPage({super.key});

  static IconData _iconFor(String key) {
    switch (key) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'calendar':
        return Icons.calendar_today_outlined;
      case 'health':
        return Icons.health_and_safety;
      case 'gavel':
        return Icons.gavel;
      case 'citizen':
        return Icons.groups_2_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(haklarCategoryProvider);
    final query = ref.watch(haklarSearchQueryProvider);
    final items = ref.watch(haklarFilteredProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const HomeDrawerButton(),
        automaticallyImplyLeading: false,
        title: const Text(
          'Haklar',
          style: TextStyle(
            color: PoliceColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Material(
            color: cs.surface,
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final c in HaklarCategory.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            showCheckmark: false,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            label: Text(
                              c.chipLabel,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: tab == c ? FontWeight.w600 : FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            selected: tab == c,
                            selectedColor: cs.primary.withValues(alpha: 0.22),
                            backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.85),
                            side: BorderSide(
                              color: tab == c ? cs.primary : cs.outline.withValues(alpha: 0.35),
                              width: tab == c ? 1.5 : 1,
                            ),
                            onSelected: (_) => ref
                                .read(haklarCategoryProvider.notifier)
                                .state = c,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                  child: TextField(
                    onChanged: (v) =>
                        ref.read(haklarSearchQueryProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Başlık, özet veya mevzuat ara',
                      prefixIcon: Icon(Icons.search, color: cs.primary.withValues(alpha: 0.85)),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverToBoxAdapter(
              child: const _HaklarFrameworkCard(
                disclaimer: _haklarDisclaimer,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            sliver: SliverToBoxAdapter(
              child: _MaasEntryCard(
                onTap: () => Navigator.of(context).push(
                  fadeRoute(const MaasHesaplamaPage()),
                ),
              ),
            ),
          ),
          if (items.isEmpty && query.trim().isNotEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _HaklarEmptyState(
                icon: Icons.search_off_rounded,
                title: 'Sonuç bulunamadı',
                message: 'Farklı bir kelime deneyin veya üstteki filtreden Tümü seçeneğini seçin.',
                colorScheme: cs,
              ),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _HaklarEmptyState(
                icon: Icons.folder_open_rounded,
                title: 'Bu kategoride kayıt yok',
                message: 'Başka bir kategori seçerek devam edebilirsiniz.',
                colorScheme: cs,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final right = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 3,
                        shadowColor: cs.primary.withValues(alpha: 0.12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _HaklarIconBadge(
                                    icon: _iconFor(right.iconKey),
                                    colorScheme: cs,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          right.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: PoliceColors.gold,
                                                fontWeight: FontWeight.w700,
                                                height: 1.25,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        _CategoryPill(
                                          label: right.category.listSubtitle,
                                          colorScheme: cs,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          right.shortDescription,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                height: 1.42,
                                                color: cs.onSurface
                                                    .withValues(alpha: 0.88),
                                              ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () => Navigator.of(context).push(
                                              fadeRoute(
                                                HaklarDetailPage(item: right),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.open_in_full,
                                              size: 18,
                                            ),
                                            label: const Text('Tam ekran oku'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HaklarEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final ColorScheme colorScheme;

  const _HaklarEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HaklarIconBadge extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;

  const _HaklarIconBadge({
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? colorScheme.primary.withValues(alpha: 0.18)
        : colorScheme.primary.withValues(alpha: 0.12);
    final fg = isDark ? colorScheme.primary : colorScheme.primary;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(icon, color: fg, size: 24),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _CategoryPill({
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
              ),
        ),
      ),
    );
  }
}

class _HaklarFrameworkCard extends StatelessWidget {
  final String disclaimer;

  const _HaklarFrameworkCard({required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.balance, color: cs.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'İzin hakları, disiplin ve savunma hakkı ile vatandaşlık haklarına ilişkin özetler yer alır. Her başlıkta ilgili kanun ve yönetmeliklere atıf ve pratik maddeler bulunur.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.48,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        disclaimer,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.78),
                              fontStyle: FontStyle.italic,
                              height: 1.42,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaasEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MaasEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.22)),
      ),
      child: Material(
        color: cs.primary.withValues(alpha: 0.04),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.calculate_rounded,
                    color: cs.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tahmini maaş bilgisi',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: PoliceColors.gold,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.15,
                            ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Katsayı ve parametreler güncel olmayabilir; sonuç bağlayıcı değildir. Kesin maaş kurum bordrosundadır.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.38,
                              color: cs.onSurface.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.primary.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
