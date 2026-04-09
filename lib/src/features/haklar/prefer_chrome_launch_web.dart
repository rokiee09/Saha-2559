import 'package:url_launcher/url_launcher.dart';

/// Web ortamında yeni sekme / harici açılış.
Future<void> launchUrlPreferChrome(String urlString) async {
  final uri = Uri.parse(urlString);
  try {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (ok) return;
  } catch (_) {}
  await launchUrl(uri, webOnlyWindowName: '_blank');
}
