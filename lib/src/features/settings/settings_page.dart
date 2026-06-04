import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants/app_branding.dart';
import '../../common/constants/app_disclaimer.dart';
import '../../common/constants/app_publisher_contact.dart';
import '../../common/legal/user_agreement_sections.dart';
import '../../common/theme/police_colors.dart';
import '../../data/repositories/offline_import_service.dart';
import '../../data/repositories/preference_repository.dart';
import '../contacts/city_contacts_controller.dart';
import '../martyrs/martyrs_controller.dart';
import '../legal/user_agreement_viewer_page.dart';
import 'data_freshness_page.dart';
import 'reading_scale_controller.dart';
import 'theme_controller.dart';
import '../asistan/settings/asistan_llm_settings_page.dart';
import 'security_center_page.dart';
import 'store_publish_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final readingScale = ref.watch(readingScaleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.text_fields_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Okuma boyutu',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Mevzuat ve genel metin ölçüsü (${(readingScale * 100).round()}%). '
                      'Erişilebilirlikte sistem yazı boyutu ile birlikte uygulanır.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:
                            Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.65),
                        thumbColor: PoliceColors.gold.withValues(alpha: 0.95),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                      ),
                      child: Slider(
                        value: readingScale,
                        min: readingScaleMin,
                        max: readingScaleMax,
                        divisions: 17,
                        label: '${(readingScale * 100).round()}%',
                        onChanged: (v) =>
                            ref.read(readingScaleProvider.notifier).setScale(v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 0),
          const ListTile(
            title: Text('Veri ve gizlilik özeti'),
            subtitle: Text(kAppOfflineDataSummary),
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(
              Icons.psychology_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Mevzuat asistanı — AI özeti (RAG)'),
            subtitle: const Text(
              'İsteğe bağlı: bulunan maddelere dayalı LLM özeti (API anahtarı)',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const AsistanLlmSettingsPage(),
                ),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(
              Icons.enhanced_encryption_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Güvenlik merkezi'),
            subtitle: const Text(
              'Şifreli veriler, yedekleme, PIN ve cihaz uyarıları',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const SecurityCenterPage(),
                ),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(
              Icons.update_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Veri güncelliği'),
            subtitle: const Text(
              'Kaynak, son içerik kontrol tarihleri ve resmî kaynağa erişim',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const DataFreshnessPage(),
                ),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(
              Icons.article_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Kullanıcı sözleşmesi'),
            subtitle: Text(
              'Tam metin · Geçerli sürüm $kUserAgreementVersion '
                  '($kUserAgreementEffectiveLabel)',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const UserAgreementViewerPage(),
                ),
              );
            },
          ),
          if (kSupportEmail.trim().isNotEmpty) ...[
            const Divider(height: 0),
            ListTile(
              leading: Icon(
                Icons.mail_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Destek e-postası'),
              subtitle: Text(kSupportEmail.trim()),
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
              onTap: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: kSupportEmail.trim(),
                );
                await launchUrl(uri);
              },
            ),
          ],
          const Divider(height: 0),
          FutureBuilder<DateTime?>(
            future: getUserAgreementAcceptedAt(),
            builder: (context, snap) {
              final at = snap.data;
              final label = at == null
                  ? 'Bu cihazda henüz tam onay kaydı yok veya güncelleme sonrası yenilenmelidir.'
                  : 'Son dijital onay (yalnızca bu cihazda): '
                      '${at.day.toString().padLeft(2, '0')}.${at.month.toString().padLeft(2, '0')}.${at.year} '
                      '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
              return ListTile(
                leading: Icon(
                  Icons.verified_user_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text('Onay kaydı'),
                subtitle: Text(label),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: Icon(
              Icons.person_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Geliştirici'),
            subtitle: Text(kLegalPublisherDisplayName),
          ),
          ListTile(
            leading: Icon(
              Icons.storefront_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Mağaza hazırlığı'),
            subtitle: Text(
              'Play metinleri, gizlilik URL, ekran görüntüsü rehberi · '
              '$kMarketBrandName / $kAppDisplayName',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const StorePublishPage(),
                ),
              );
            },
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
                ref.invalidate(cityContactsProvider);
                ref.invalidate(cityContactPlateCodesProvider);
                ref.invalidate(martyrsCatalogProvider);
                ref.invalidate(martyrsFilteredProvider);
                ref.invalidate(martyrCitiesProvider);
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

