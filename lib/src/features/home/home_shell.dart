import 'package:flutter/material.dart';

import '../../common/constants/app_disclaimer.dart';
import '../../common/theme/police_colors.dart';
import '../../common/widgets/polis_main_navigation_bar.dart';
import '../../common/widgets/police_filigran_layer.dart';
import '../settings/settings_page.dart';
import '../mevzuat/mevzuat_page.dart';
import '../haklar/haklar_page.dart';
import '../teskilat/teskilat_page.dart';
import '../kultur/kultur_page.dart';
import 'root_drawer_scope.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final GlobalKey<ScaffoldState> _shellKey = GlobalKey<ScaffoldState>();

  /// Sadece ziyaret edilen sekmeler kurulur; açılış ve bellek (mobil) için.
  final List<Widget?> _tabPages = List<Widget?>.filled(4, null);

  @override
  void initState() {
    super.initState();
    _tabPages[0] = _tabWithRepaint(const MevzuatPage());
  }

  static Widget _tabWithRepaint(Widget child) {
    return RepaintBoundary(child: child);
  }

  static Widget _buildLazyTab(int i) {
    return switch (i) {
      0 => _tabWithRepaint(const MevzuatPage()),
      1 => _tabWithRepaint(const TeskilatPage()),
      2 => _tabWithRepaint(const HaklarPage()),
      3 => _tabWithRepaint(const KulturPage()),
      _ => const SizedBox.shrink(),
    };
  }

  void _goToTab(int i) {
    if (i < 0 || i > 3) return;
    setState(() {
      _index = i;
      _tabPages[i] ??= _buildLazyTab(i);
    });
  }

  void _openDrawer() => _shellKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    return RootDrawerIntent(
      openDrawer: _openDrawer,
      child: Scaffold(
        key: _shellKey,
        drawer: _HomeDrawer(
          selectedIndex: _index,
          onSelect: (i) {
            _goToTab(i);
            Navigator.of(context).pop();
          },
          onOpenSettings: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsPage(),
              ),
            );
          },
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: Theme.of(context).colorScheme.surface),
                  const PoliceFiligranLayer(),
                  IndexedStack(
                    index: _index,
                    children: List<Widget>.generate(4, (i) {
                      return _tabPages[i] ?? const SizedBox.shrink();
                    }),
                  ),
                ],
              ),
            ),
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Text(
                    kAppFullDisclaimer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          height: 1.35,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.95),
                        ),
                  ),
                ),
              ),
            ),
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

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.selectedIndex,
    required this.onSelect,
    required this.onOpenSettings,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final headerNavy = PoliceColors.navy;
    final headerEnd = Color.lerp(
      headerNavy,
      isLight ? const Color(0xFF152A55) : PoliceColors.surfaceDark,
      0.4,
    )!;

    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [headerNavy, headerEnd],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icon/app_icon.png',
                    height: 56,
                    width: 56,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.shield_outlined,
                      size: 48,
                      color: PoliceColors.gold.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SAHA 2559',
                    style: tt.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dört ana bölüm: mevzuat, teşkilat, haklar ve kültür. '
                    'Alttaki sekmelerle de geçiş yapabilirsiniz.',
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            _DrawerTile(
              selected: selectedIndex == 0,
              icon: Icons.menu_book_outlined,
              title: 'Mevzuat',
              subtitle: 'Kanunlar, yönetmelikler, arama ve favoriler',
              onTap: () => onSelect(0),
            ),
            _DrawerTile(
              selected: selectedIndex == 1,
              icon: Icons.apartment_outlined,
              title: 'Teşkilat',
              titleColor: PoliceColors.gold,
              subtitle: 'Yapı, birimler ve il listesi',
              onTap: () => onSelect(1),
            ),
            _DrawerTile(
              selected: selectedIndex == 2,
              icon: Icons.description_outlined,
              title: 'Haklar',
              titleColor: PoliceColors.gold,
              subtitle: 'Özet haklar ve tahmini maaş bilgisi',
              onTap: () => onSelect(2),
            ),
            _DrawerTile(
              selected: selectedIndex == 3,
              icon: Icons.auto_stories_outlined,
              title: 'Kültür',
              titleColor: PoliceColors.gold,
              subtitle: 'Tarih, şehitler, tören ve önemli günler',
              onTap: () => onSelect(3),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.settings_outlined,
                color: isLight ? PoliceColors.navy : PoliceColors.gold,
              ),
              title: const Text('Ayarlar'),
              subtitle: const Text('Tema, gizlilik ve offline içerik'),
              onTap: onOpenSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.selected,
    required this.icon,
    required this.title,
    this.titleColor,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: Icon(icon),
      title: Text(
        title,
        style: titleColor != null
            ? TextStyle(
                color: titleColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              )
            : null,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }
}
