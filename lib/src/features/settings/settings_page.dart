import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants/app_disclaimer.dart';
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
            title: Text('Bilgilendirme'),
            subtitle: Text(kAppFullDisclaimer),
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
          if (!kIsWeb)
            ListTile(
              title: const Text('Yerel veri içe aktar'),
              subtitle: const Text(
                'İl iletişim ve şehit listeleri JSON’dan cihaz veritabanına yazılır. '
                'Mevzuat metinleri uygulama paketindeki dosyalardan okunur.',
              ),
              trailing: const Icon(Icons.download),
              onTap: () async {
                await OfflineImportService.importAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yerel veri güncellendi.')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

