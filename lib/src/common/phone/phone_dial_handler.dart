import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String phoneDigitsForDialer(String phone) {
  return phone.replaceAll(RegExp(r'\D'), '');
}

/// Web: `tel:` çoğu tarayıcıda yeni sekme / boş sayfa açar; numarayı diyalogda gösteririz.
/// Diğer platformlarda uygulama dışı arama: `tel:`.
Future<void> dialOrShowNumberDialog(
  BuildContext context, {
  required String phone,
  String? placeName,
}) async {
  final digits = phoneDigitsForDialer(phone);
  if (digits.isEmpty) {
    return;
  }
  if (kIsWeb) {
    if (!context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(placeName ?? 'Arama numarası'),
        content: SelectableText(
          digits,
          style: const TextStyle(fontSize: 18, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Kapat'),
          ),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: digits));
              if (dialogCtx.mounted) {
                Navigator.pop(dialogCtx);
              }
              if (context.mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Numara panoya kopyalandı.')),
                );
              }
            },
            child: const Text('Kopyala'),
          ),
        ],
      ),
    );
    return;
  }
  final uri = Uri.parse('tel:$digits');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
