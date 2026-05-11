/// `assets/kultur/polis_p*.txt` birleşimi biçimi:
/// Her blok: ilk satır başlık, sonraki satırlar gövde (paragraflar boş satırla ayrılır).
/// Bloklar arasında tek satırda `---`.
library polis_tarihi_parser;

class PolisTarihiBlock {
  final String title;
  final List<String> paragraphs;

  const PolisTarihiBlock({
    required this.title,
    required this.paragraphs,
  });
}

/// Metni blok listesine çevirir (trim, boş paragrafları atar).
List<PolisTarihiBlock> parsePolisTarihiRaw(String raw) {
  final blocks = <PolisTarihiBlock>[];
  final chunks = raw.split(RegExp(r'^\s*---\s*$', multiLine: true));
  for (final chunk in chunks) {
    final t = chunk.trim();
    if (t.isEmpty) continue;
    final lines = t.split('\n');
    final title = lines.first.trim();
    final body = lines.skip(1).join('\n').trim();
    if (title.isEmpty) continue;
    final paras = body
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    blocks.add(PolisTarihiBlock(title: title, paragraphs: paras));
  }
  return blocks;
}
