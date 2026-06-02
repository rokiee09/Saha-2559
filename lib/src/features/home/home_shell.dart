import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants/app_branding.dart';
import '../../common/routing/transitions.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/app_legal_strip.dart';
import '../../common/widgets/polis_main_navigation_bar.dart';
import '../../common/widgets/police_filigran_layer.dart';
import '../settings/settings_page.dart';
import '../mevzuat/mevzuat_article_detail_page.dart';
import '../mevzuat/mevzuat_favorites_page.dart';
import '../mevzuat/mevzuat_provider.dart';
import '../mevzuat/mevzuat_page.dart';
import '../haklar/vardiya/vardiya_hesaplama_page.dart';
import '../asistan/asistan_page.dart';
import '../gorevlerim/gorevlerim_page.dart';
import '../gorevlerim/izin/izin_page.dart';
import '../araclar/araclar_page.dart';
import 'dashboard_page.dart';
import 'root_drawer_scope.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  /// Sadece ziyaret edilen sekmeler kurulur; açılış ve bellek (mobil) için.
  /// 0: Ana Sayfa, 1: Asistan, 2: Profilim, 3: Mevzuat, 4: Araçlar.
  final List<Widget?> _tabPages = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _tabPages[0] = _tabWithRepaint(_buildDashboardPage());
  }

  static Widget _tabWithRepaint(Widget child) {
    return RepaintBoundary(child: child);
  }

  Widget _buildLazyTab(int i) {
    return switch (i) {
      0 => _tabWithRepaint(_buildDashboardPage()),
      1 => _tabWithRepaint(const AsistanPage()),
      2 => _tabWithRepaint(const GorevlerimPage()),
      3 => _tabWithRepaint(const MevzuatPage()),
      4 => _tabWithRepaint(const AraclarPage()),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildDashboardPage() {
    return DashboardPage(
      onContinueReading: () async {
        final nav = Navigator.of(context);
        final list = await ref.read(mevzuatRecentItemsProvider.future);
        if (!mounted || list.isEmpty) return;
        final r = list.first;
        nav.push(
          fadeRoute(MevzuatArticleDetailPage(entryId: r.entry.id)),
        );
      },
      onOpenAsistan: () => _goToTab(1),
      onOpenMevzuat: () => _goToTab(3),
      onOpenProfilim: () => _goToTab(2),
      onOpenIzin: () {
        Navigator.of(context).push(fadeRoute(const IzinPage()));
      },
      onOpenVardiya: () {
        Navigator.of(context).push(fadeRoute(const VardiyaHesaplamaPage()));
      },
      onOpenGununMaddesi: (id, {sectionId}) {
        Navigator.of(context).push(
          fadeRoute(
            MevzuatArticleDetailPage(entryId: id, focusSectionId: sectionId),
          ),
        );
      },
      onOpenFavorites: () {
        Navigator.of(context).push(
          fadeRoute(const MevzuatFavoritesPage()),
        );
      },
    );
  }

  void _openMainMenu() {
    final nav = Navigator.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.58,
          minChildSize: 0.38,
          maxChildSize: 0.93,
          builder: (ctx, scrollController) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: PoliceColors.surfaceDark,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(
                  top: BorderSide(
                    color: PoliceColors.outlineMuted.withValues(alpha: 0.48),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PoliceColors.textMuted.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _HomeMainMenuBody(
                      scrollController: scrollController,
                      selectedIndex: _index,
                      onSelect: (i) {
                        Navigator.of(sheetCtx).pop();
                        _goToTab(i);
                      },
                      onOpenSettings: () {
                        Navigator.of(sheetCtx).pop();
                        nav.push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                      onOpenMevzuatEntry: (entryId) {
                        Navigator.of(sheetCtx).pop();
                        _goToTab(3);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          nav.push(
                            fadeRoute(
                              MevzuatArticleDetailPage(entryId: entryId),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _goToTab(int i) {
    if (i < 0 || i > 4) return;
    setState(() {
      _index = i;
      _tabPages[i] ??= _buildLazyTab(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RootDrawerIntent(
      openMainMenu: _openMainMenu,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: PoliceColors.backgroundDark),
                  const PoliceFiligranLayer(),
                  IndexedStack(
                    index: _index,
                    children: List<Widget>.generate(5, (i) {
                      return _tabPages[i] ?? const SizedBox.shrink();
                    }),
                  ),
                ],
              ),
            ),
            const AppLegalStrip(),
          ],
        ),
        bottomNavigationBar: PolisMainNavigationBar(
          currentIndex: _index,
          onDestinationSelected: _goToTab,
        ),
      ),
    );
  }
}

class _HomeMainMenuBody extends StatelessWidget {
  const _HomeMainMenuBody({
    required this.scrollController,
    required this.selectedIndex,
    required this.onSelect,
    required this.onOpenSettings,
    required this.onOpenMevzuatEntry,
  });

  final ScrollController scrollController;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onOpenMevzuatEntry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bright = Theme.of(context).brightness;
    const headerNavy = PoliceColors.navy;
    final headerEnd = Color.lerp(
      headerNavy,
      bright == Brightness.light
          ? const Color(0xFF152A55)
          : PoliceColors.surfaceDark,
      0.4,
    )!;

    return SafeArea(
      top: false,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // DrawerHeader sabit ~160 px; logo + iki satır metni sigdirmiyor — taşıma yapar.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [headerNavy, headerEnd],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/app_icon.png',
                  height: 52,
                  width: 52,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.shield_outlined,
                    size: 46,
                    color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  kAppDisplayName,
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  kDrawerIntroParagraph,
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: PoliceColors.outlineMuted.withValues(alpha: 0.5),
          ),
          DrawerMevzuatShortcuts(onOpenEntry: onOpenMevzuatEntry),
          _DrawerTile(
            selected: selectedIndex == 0,
            icon: Icons.home_outlined,
            title: kNavHomeLabel,
            subtitle: 'Özet ekran ve sık kullanılanlar',
            onTap: () => onSelect(0),
          ),
          _DrawerTile(
            selected: selectedIndex == 1,
            icon: PhosphorIconsRegular.brain,
            title: 'Polis Asistanı',
            subtitle: 'Soru yaz, ilgili kanun maddesini bul (offline)',
            onTap: () => onSelect(1),
          ),
          _DrawerTile(
            selected: selectedIndex == 2,
            icon: Icons.checklist_rounded,
            title: 'Profilim',
            subtitle: 'İzin, kariyer, disiplin ve kişisel kayıtların',
            onTap: () => onSelect(2),
          ),
          _DrawerTile(
            selected: selectedIndex == 3,
            icon: Icons.menu_book_outlined,
            title: 'Mevzuat',
            subtitle: 'Kanunlar, yönetmelikler, arama ve favoriler',
            onTap: () => onSelect(3),
          ),
          _DrawerTile(
            selected: selectedIndex == 4,
            icon: Icons.handyman_outlined,
            title: 'Araçlar',
            subtitle: 'Hesaplayıcılar, saha defteri, teşkilat ve kültür',
            onTap: () => onSelect(4),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 12,
            endIndent: 12,
            color: PoliceColors.outlineMuted.withValues(alpha: 0.52),
          ),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: cs.onSurfaceVariant,
            ),
            title: Text(
              'Ayarlar',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Tema, gizlilik ve offline içerik',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.88),
              ),
            ),
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      selected: selected,
      leading: Icon(
        icon,
        color: selected ? cs.primary : cs.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.92),
              height: 1.3,
            ),
      ),
      onTap: onTap,
    );
  }
}

class DrawerMevzuatShortcuts extends ConsumerWidget {
  const DrawerMevzuatShortcuts({super.key, required this.onOpenEntry});

  final ValueChanged<String> onOpenEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final catalogAsync = ref.watch(mevzuatCatalogProvider);

    return catalogAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cat) {
        final all = [...cat.kanunlar, ...cat.yonetmelikler];
        final idToEntry = {for (final e in all) e.id: e};

        final recentAsync = ref.watch(mevzuatRecentItemsProvider);
        final favAsync = ref.watch(mevzuatFavoritesProvider);

        return recentAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (recentItems) {
            return favAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (favIds) {
                final children = <Widget>[];

                if (recentItems.isNotEmpty) {
                  final r = recentItems.first;
                  children.add(
                    ListTile(
                      leading: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        'Devam et',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${r.entry.displayTitle}\n${r.maddeLabel}',
                        maxLines: 3,
                        style: tt.bodySmall?.copyWith(height: 1.35),
                      ),
                      isThreeLine: true,
                      onTap: () => onOpenEntry(r.entry.id),
                    ),
                  );
                }

                final favEntries = favIds
                    .map((id) => idToEntry[id])
                    .whereType<MevzuatEntry>()
                    .toList()
                  ..sort(
                    (a, b) => a.displayTitle.compareTo(b.displayTitle),
                  );
                final topFav = favEntries.take(5).toList();

                if (topFav.isNotEmpty) {
                  if (children.isNotEmpty) {
                    children.add(
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 12,
                        endIndent: 12,
                        color: PoliceColors.outlineMuted.withValues(alpha: 0.4),
                      ),
                    );
                  }
                  children.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Favori kısayollar',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                  for (final e in topFav) {
                    children.add(
                      ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.bookmark_rounded,
                          color:
                              PoliceColors.primaryBlue.withValues(alpha: 0.95),
                        ),
                        title: Text(
                          e.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => onOpenEntry(e.id),
                      ),
                    );
                  }
                }

                if (children.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                );
              },
            );
          },
        );
      },
    );
  }
}
