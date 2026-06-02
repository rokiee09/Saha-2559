/// `assets/kultur/tesekkur_vefa.txt` dosyasından okunan yapılandırılmış metin.
class TesekkurVefaContent {
  const TesekkurVefaContent({
    required this.title,
    this.subtitle,
    required this.paragraphs,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final List<String> paragraphs;
  final String? footer;

  static TesekkurVefaContent parse(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    String? title;
    String? subtitle;
    final bodyLines = <String>[];
    final footerLines = <String>[];

    var inFooter = false;
    for (final line in lines) {
      final t = line.trim();
      if (t == '---') {
        inFooter = true;
        continue;
      }
      if (inFooter) {
        if (t.isNotEmpty) footerLines.add(t);
        continue;
      }
      if (t.startsWith('# ')) {
        title = t.substring(2).trim();
        continue;
      }
      if (t.startsWith('## ')) {
        subtitle = t.substring(3).trim();
        continue;
      }
      bodyLines.add(line);
    }

    final body = bodyLines.join('\n').trim();
    final paragraphs = body
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return TesekkurVefaContent(
      title: title?.isNotEmpty == true ? title! : 'Teşekkür ve Vefa',
      subtitle: subtitle,
      paragraphs: paragraphs,
      footer: footerLines.isEmpty ? null : footerLines.join('\n'),
    );
  }
}
