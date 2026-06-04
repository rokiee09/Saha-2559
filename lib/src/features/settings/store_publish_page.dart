import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants/app_branding.dart';
import '../../common/constants/app_publisher_contact.dart';
import '../../common/constants/store_publish.dart';
import '../../common/theme/police_colors.dart';

/// Play Console hazırlığı: metin kopyalama, gizlilik URL, kontrol listesi.
class StorePublishPage extends StatelessWidget {
  const StorePublishPage({super.key});

  Future<void> _copy(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text.trim()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label panoya kopyalandı')),
      );
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Açılamadı: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Mağaza hazırlığı'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            'Google Play yayını için metin ve kontrol listesi. '
            'Detaylı rehber: repo içinde docs/store/',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.92),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Kimlik'),
          _CopyTile(
            title: 'Uygulama adı',
            subtitle: kAppDisplayName,
            value: 'SAHA 2559 - Polis Mevzuat',
            onCopy: (c) => _copy(c, 'SAHA 2559 - Polis Mevzuat', 'Uygulama adı'),
          ),
          _CopyTile(
            title: 'Yayın markası',
            subtitle: kMarketBrandName,
            value: kMarketBrandName,
            onCopy: (c) => _copy(c, kMarketBrandName, 'Marka'),
          ),
          _CopyTile(
            title: 'Paket kimliği',
            subtitle: 'applicationId',
            value: kPlayStorePackageId,
            onCopy: (c) => _copy(c, kPlayStorePackageId, 'Paket kimliği'),
          ),
          const SizedBox(height: 12),
          _SectionTitle('Mağaza metni'),
          _CopyTile(
            title: 'Kısa açıklama',
            subtitle: 'En fazla 80 karakter',
            value: kStoreShortDescription,
            onCopy: (c) => _copy(c, kStoreShortDescription, 'Kısa açıklama'),
          ),
          _CopyTile(
            title: 'Tam açıklama',
            subtitle: 'Play Console tam metin alanı',
            value: kStoreFullDescription,
            onCopy: (c) => _copy(c, kStoreFullDescription, 'Tam açıklama'),
          ),
          const SizedBox(height: 12),
          _SectionTitle('Gizlilik ve destek'),
          ListTile(
            tileColor: PoliceColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              'Gizlilik politikası URL',
              style: TextStyle(color: PoliceColors.titleOnDark),
            ),
            subtitle: Text(
              kPrivacyPolicyUrl,
              style: TextStyle(
                color: PoliceColors.primaryBlue.withValues(alpha: 0.95),
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () => _copy(context, kPrivacyPolicyUrl, 'URL'),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new_rounded),
                  onPressed: () => _openUrl(context, kPrivacyPolicyUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _CopyTile(
            title: 'Destek e-postası',
            subtitle: kSupportEmail.isEmpty ? 'Tanımlı değil' : kSupportEmail,
            value: kSupportEmail,
            onCopy: kSupportEmail.isEmpty
                ? null
                : (c) => _copy(c, kSupportEmail, 'E-posta'),
          ),
          const SizedBox(height: 12),
          _SectionTitle('Ekran görüntüleri (öneri)'),
          Text(
            'docs/store/screenshots/ altına 1080×1920 dikey PNG kaydedin.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          for (final h in kStoreScreenshotHints)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                tileColor: PoliceColors.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Text(
                  h.fileName,
                  style: TextStyle(
                    color: PoliceColors.gold.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                title: Text(
                  h.caption,
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.92),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          _SectionTitle('Yayın öncesi kontrol'),
          const _CheckItem('CI yeşil (analyze + test + mevzuat doğrulama)'),
          const _CheckItem('Gizlilik URL Play Console\'a girildi'),
          const _CheckItem('Veri güvenliği: veri toplanmıyor'),
          const _CheckItem('Release AAB imzalı (key.properties)'),
          const _CheckItem('Feature graphic 1024×500 yüklendi'),
          const SizedBox(height: 12),
          Text(
            'Resmî kurum uygulaması izlenimi vermeyin; bağımsız bilgilendirme '
            'uygulaması olduğunu açıklamada belirtin.',
            style: TextStyle(
              color: PoliceColors.textMuted.withValues(alpha: 0.75),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: PoliceColors.gold,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CopyTile extends StatelessWidget {
  const _CopyTile({
    required this.title,
    required this.subtitle,
    required this.value,
    this.onCopy,
  });

  final String title;
  final String subtitle;
  final String value;
  final void Function(BuildContext)? onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        tileColor: PoliceColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: const TextStyle(
            color: PoliceColors.titleOnDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.88),
            fontSize: 12,
          ),
        ),
        trailing: onCopy == null
            ? null
            : IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => onCopy!(context),
              ),
        onTap: onCopy == null ? null : () => onCopy!(context),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: PoliceColors.primaryBlue.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: PoliceColors.textMuted.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
