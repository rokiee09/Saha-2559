import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Mümkünse Google Chrome ile açar; olmazsa sistem varsayılan tarayıcısına düşer.
Future<void> launchUrlPreferChrome(String urlString) async {
  final uri = Uri.parse(urlString);

  if (Platform.isWindows) {
    final opened = await _windowsTryChrome(urlString);
    if (opened) return;
  } else if (Platform.isMacOS) {
    try {
      final r = await Process.run(
        'open',
        ['-a', 'Google Chrome', urlString],
        runInShell: false,
      );
      if (r.exitCode == 0) return;
    } catch (_) {}
  } else if (Platform.isLinux) {
    for (final name in [
      'google-chrome-stable',
      'google-chrome',
      'chromium-browser',
      'chromium',
    ]) {
      try {
        final r = await Process.run(
          name,
          [urlString],
          runInShell: false,
        );
        if (r.exitCode == 0) return;
      } catch (_) {}
    }
  }

  await _launchInBrowser(uri);
}

/// Windows: önce chrome.exe yolu, sonra `start chrome`, en sonda url_launcher.
/// `canLaunchUrl` güvenilmez (çoğu kurulumda false döner); doğrudan [launchUrl] kullanılır.
Future<bool> _windowsTryChrome(String urlString) async {
  final candidates = <String>[
    r'C:\Program Files\Google\Chrome\Application\chrome.exe',
    r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
  ];
  final local = Platform.environment['LOCALAPPDATA'];
  if (local != null && local.isNotEmpty) {
    candidates.add('$local\\Google\\Chrome\\Application\\chrome.exe');
  }

  for (final exe in candidates) {
    if (!File(exe).existsSync()) continue;
    try {
      // start "" "path\to\chrome.exe" "url" — ilk boş argüman pencere başlığı (start kuralı)
      final r = await Process.run(
        'cmd.exe',
        ['/c', 'start', '', exe, urlString],
        runInShell: false,
      );
      if (r.exitCode == 0) return true;
    } catch (_) {}
  }

  try {
    final r = await Process.run(
      'cmd.exe',
      ['/c', 'start', 'chrome', urlString],
      runInShell: false,
    );
    if (r.exitCode == 0) return true;
  } catch (_) {}

  return false;
}

Future<void> _launchInBrowser(Uri uri) async {
  try {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (ok) return;
  } catch (_) {}

  try {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (_) {}

  // Son çare: Windows’ta varsayıcı ile protokol işleyicisi
  if (Platform.isWindows) {
    try {
      await Process.run(
        'cmd.exe',
        ['/c', 'start', '', uri.toString()],
        runInShell: false,
      );
    } catch (_) {}
  }
}
