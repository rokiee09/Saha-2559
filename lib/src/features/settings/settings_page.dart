import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/offline_import_service.dart';
import 'theme_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Gizlilik Politikası'),
            subtitle: Text('Kişisel verilerin işlenmesine dair bilgiler'),
          ),
          const Divider(height: 0),
          const ListTile(
            title: Text('Disclaimer'),
            subtitle:
                Text('Uygulama bilgilendirme amaçlıdır, resmî mevzuat önceliklidir.'),
          ),
          const Divider(height: 0),
          SwitchListTile(
            title: const Text('Koyu tema'),
            subtitle: const Text('Lacivert-beyaz-altın palet ile koyu görünüm'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).state =
                  val ? ThemeMode.dark : ThemeMode.system;
            },
          ),
          const Divider(height: 0),
          ListTile(
            title: const Text('Offline paket indir / güncelle'),
            subtitle: const Text('Mevzuat ve diğer içerikleri cihaza kaydet'),
            trailing: const Icon(Icons.download),
            onTap: () async {
              await OfflineImportService.importAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Offline paket güncellendi.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

